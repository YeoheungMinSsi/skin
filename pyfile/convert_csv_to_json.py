import csv
import json
import os

def classify_product(product_name):
    name = str(product_name).lower()
    
    # 1. 립밤 / 립케어
    if any(k in name for k in ['립밤', '립케어', '립에센스', '립오일', '글로이 밤', '멜팅 립', 'lip balm', 'lip care']):
        return '립케어'
    # 2. 마스크 / 팩 / 패드
    if any(k in name for k in ['마스크', '팩', '패드', '마스크팩', '시트', '패치', 'mask', 'pack', 'pad']):
        return '마스크/팩'
    # 3. 클렌징
    if any(k in name for k in ['클렌징', '클렌저', '폼', '필링', '스크럽', 'cleansing', 'cleanser', 'foam', '워시']):
        return '클렌징'
    # 4. 선케어
    if any(k in name for k in ['선크림', '선블록', '선스틱', '선에센스', '선로션', '선겔', 'sunscreen', 'sunblock', 'sun']):
        return '선케어'
    # 5. 로션 / 에멀젼
    if any(k in name for k in ['로션', '에멀젼', '에멀전', 'lotion', 'emulsion']):
        return '로션/에멀젼'
    # 6. 스킨 / 토너
    if any(k in name for k in ['스킨', '토너', '토닉', '스킨부스터', '워터 에센스', 'skin', 'toner', 'tonic']):
        return '스킨/토너'
    # 7. 에센스 / 세럼 / 앰플
    if any(k in name for k in ['에센스', '세럼', '앰플', '부스터', '오일', 'essence', 'serum', 'ampoule', 'oil']):
        return '에센스/세럼/앰플'
    # 8. 크림
    if any(k in name for k in ['크림', '밤', '수딩젤', '젤', '크림미스트', 'cream', 'balm', 'gel']):
        return '크림'
        
    return '기타'

def convert_csv_to_json(csv_path, json_path):
    print(f"Reading CSV from: {csv_path}")
    data = []
    
    try:
        # utf-8-sig handles potential BOM in CSV files
        with open(csv_path, mode='r', encoding='utf-8-sig') as csv_file:
            csv_reader = csv.DictReader(csv_file)
            for row in csv_reader:
                # Create a clean dict for the row, handling potential empty/null values
                clean_row = {}
                for key, value in row.items():
                    if key: # ignore empty headers
                        clean_row[key.strip()] = value.strip() if value else ""
                
                # 제품명을 기반으로 분류 추가
                product_name = clean_row.get('제품명', '')
                clean_row['분류'] = classify_product(product_name)
                
                data.append(clean_row)
                
    except Exception as e:
        print(f"Error reading CSV: {e}")
        return

    print(f"Read {len(data)} rows. Writing JSON to: {json_path}")
    
    try:
        # Create directory if it doesn't exist
        os.makedirs(os.path.dirname(json_path), exist_ok=True)
        
        with open(json_path, mode='w', encoding='utf-8') as json_file:
            json.dump(data, json_file, ensure_ascii=False, indent=2)
            
        print("Conversion successful!")
    except Exception as e:
        print(f"Error writing JSON: {e}")

if __name__ == "__main__":
    # Define absolute paths based on the project structure
    csv_file_path = r'c:\Users\301\project\capston\pyfile\result\result.csv'
    json_file_path = r'c:\Users\301\project\capston\lib\data\cosmetic.json'
    
    convert_csv_to_json(csv_file_path, json_file_path)
