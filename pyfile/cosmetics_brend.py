import requests
import pandas as pd
from bs4 import BeautifulSoup


url = (
    "https://ko.wikipedia.org/wiki/"
    "틀:대한민국의_화장품_브랜드"
)

headers = {
    "User-Agent":
    "Mozilla/5.0"
}


response = requests.get(
    url,
    headers=headers
)

soup = BeautifulSoup(
    response.text,
    "html.parser"
)


results = []


##########################################
# 회사(그룹) 찾기
##########################################

groups = soup.find_all("tr")


for group in groups:

    company = group.find("th")

    brands = group.find_all("li")


    if company is None:
        continue


    company_name = company.get_text(
        strip=True
    )


    # 회사명 정제
    company_name = company_name.replace(
        "[편집]",
        ""
    )


    ##################################
    # 브랜드 추출
    ##################################

    for brand in brands:

        brand_name = brand.get_text(
            strip=True
        )


        # 너무 긴 설명 제거
        if len(brand_name) > 30:
            continue


        # 공백 제거
        if brand_name == "":
            continue


        results.append({

            "나라":
            "대한민국",

            "회사":
            company_name,

            "브랜드":
            brand_name
        })



##########################################
# DataFrame 생성
##########################################

df = pd.DataFrame(
    results
)


##########################################
# 중복 제거
##########################################

df = df.drop_duplicates(
    subset=["브랜드"]
)


##########################################
# CSV 저장
##########################################

df.to_csv(

    "cosmetics_companies.csv",

    index=False,

    encoding="utf-8-sig"
)


print(df.head())

print(
    "\n총 브랜드:",
    len(df)
)