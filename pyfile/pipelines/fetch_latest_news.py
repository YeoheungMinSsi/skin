import os
import json
import requests
import xml.etree.ElementTree as ET
from datetime import datetime

try:
    from deep_translator import GoogleTranslator
    translator = GoogleTranslator(source='auto', target='ko')
except ImportError:
    translator = None
    print("Warning: deep-translator not installed. Papers will not be translated to Korean.")

# Top Dermatology & Cosmetic Journals
PRESTIGIOUS_JOURNALS = [
    '"Journal of the American Academy of Dermatology"[Journal]',
    '"JAMA Dermatology"[Journal]',
    '"British Journal of Dermatology"[Journal]',
    '"Journal of Investigative Dermatology"[Journal]',
    '"Plastic and Reconstructive Surgery"[Journal]',
    '"Journal of the European Academy of Dermatology and Venereology"[Journal]',
    '"Journal of Cosmetic Dermatology"[Journal]',
    '"Dermatologic Surgery"[Journal]',
    '"Aesthetic Surgery Journal"[Journal]'
]

def fetch_latest_papers(max_results=10):
    journals_query = " OR ".join(PRESTIGIOUS_JOURNALS)
    keywords_query = '("cosmetics"[MeSH Terms] OR "skin care"[MeSH Terms] OR "anti-aging"[Title/Abstract] OR "hyaluronic acid"[Title/Abstract])'
    
    # Complete query: Journals AND Keywords
    query = f"({journals_query}) AND {keywords_query}"
    
    # 1. eSearch to get IDs
    search_url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
    search_params = {
        "db": "pubmed",
        "term": query,
        "retmode": "json",
        "retmax": max_results,
        "sort": "date"
    }
    
    print("Searching PubMed for prestigious journals...")
    search_response = requests.get(search_url, params=search_params)
    search_response.raise_for_status()
    search_data = search_response.json()
    
    id_list = search_data.get("esearchresult", {}).get("idlist", [])
    if not id_list:
        print("No papers found.")
        return []
    
    print(f"Found {len(id_list)} papers. Fetching details...")
    
    # 2. eFetch to get details (XML format gives abstracts and better structured data)
    fetch_url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
    fetch_params = {
        "db": "pubmed",
        "id": ",".join(id_list),
        "retmode": "xml"
    }
    
    fetch_response = requests.get(fetch_url, params=fetch_params)
    fetch_response.raise_for_status()
    
    # Parse XML
    root = ET.fromstring(fetch_response.content)
    papers = []
    
    for i, article in enumerate(root.findall(".//PubmedArticle")):
        pmid = article.find(".//PMID").text if article.find(".//PMID") is not None else ""
        
        # Title
        title_element = article.find(".//ArticleTitle")
        title = "".join(title_element.itertext()) if title_element is not None else "No Title"
        
        # Abstract
        abstract_element = article.find(".//AbstractText")
        abstract = "".join(abstract_element.itertext()) if abstract_element is not None else "Abstract not available."
        
        # Journal
        journal_element = article.find(".//Journal/Title")
        journal = journal_element.text if journal_element is not None else "Unknown Journal"
        
        # Year
        pub_date = article.find(".//PubDate/Year")
        if pub_date is not None:
            year = pub_date.text
        else:
            medline_date = article.find(".//PubDate/MedlineDate")
            year = medline_date.text[:4] if medline_date is not None else "2026"
        
        link = f"https://pubmed.ncbi.nlm.nih.gov/{pmid}/"
        
        print(f"Processing paper {i+1}: {title[:50]}...")
        
        # Translate to Korean if possible
        kr_title = title
        kr_abstract = abstract
        if translator:
            try:
                kr_title = translator.translate(title)
                if abstract != "Abstract not available.":
                    kr_abstract = translator.translate(abstract)
                    # Shorten abstract to summary (first 3 sentences)
                    sentences = kr_abstract.split(". ")
                    kr_abstract = ". ".join(sentences[:3]) + ("." if len(sentences) >= 3 else "")
            except Exception as e:
                print(f"Translation failed for PMID {pmid}: {e}")
        
        # Extract some mock keywords from English or Korean
        keywords = ["피부과학", "권위학회지"]
        if "anti-aging" in abstract.lower() or "aging" in abstract.lower():
            keywords.append("항노화")
        if "cosmetic" in abstract.lower() or "cosmetics" in abstract.lower():
            keywords.append("코스메틱")
        if "barrier" in abstract.lower():
            keywords.append("피부장벽")
        if "hyaluronic" in abstract.lower():
            keywords.append("히알루론산")
        if "botulinum" in abstract.lower():
            keywords.append("보톡스")
            
        paper_data = {
            "id": i + 1,
            "date": datetime.now().strftime("%Y-%m-%d"),
            "paper_year": year,
            "paper_link": link,
            "journal": journal,
            "headline": kr_title,
            "summary": kr_abstract,
            "keywords": keywords
        }
        papers.append(paper_data)
        
    return papers

if __name__ == "__main__":
    result = fetch_latest_papers(10)
    
    if result:
        # Save to lib/data/latest_news.json
        output_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'lib', 'data', 'latest_news.json'))
        # Ensure directory exists
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(result, f, ensure_ascii=False, indent=4)
            
        print(f"\nSuccessfully fetched {len(result)} papers and updated {output_path}!")
    else:
        print("\nNo data fetched. JSON file not updated.")
