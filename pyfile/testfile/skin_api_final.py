import requests
import pandas as pd
import os

from fontTools.diff import file_exists

url = 'http://apis.data.go.kr/1471000/FtnltCosmRptPrdlstInfoService/getRptPrdlstInq'
apiKey = 'a037e6d62cded0f4e2082f45dd0fbd5f0ec5459795085b86e012d1d037e18604'

products = []
count = 0

for page in range(1, 10001):

    params ={
        'serviceKey' : apiKey,
        'pageNo' : page,
        'numOfRows' : '100',
        'type' : 'json',
    }

    try:
        response = requests.get(url, params=params)
        data = response.json()
        # body에서 필수 데이터 가지고 오는 부분
        items = data['body']['items']

        if not items:
            break;

        for item in items:

            products.append({
                "품목일련번호" : item.get('COSMETIC_REPORT_SEQ'),
                "품목명" : item.get('ITEM_NAME'),
                "제조국가명" : item.get('MANUF_COUNTRY_NAME'),
                "제조원소재지" : item.get('ITEM_NAME'),
                "PH 등급" : item.get('ITEM_PH'),
                "회사(업소)명" : item.get('ENTP_NAME'),
                "회사(업소) 일련번호" : item.get('ENTP_SEQ'),
                "에탄올 4% 초과여부" : item.get('ETHANOL_OVER_YN'),
                "효능효과코드" : item.get('EE_CODE'),
                "자외선차단지수(자외선B)" : item.get('SPF'),
                "자외선차단지수(자외선A)" : item.get('PA'),
                "2호효능효과_미백": item.get('EFFECT_YN1'),
                "2호효능효과_주름개선": item.get('EFFECT_YN2'),
                "2호효능효과_자외선": item.get('EFFECT_YN3'),
                "2호효능효과_자외선_내수성": item.get('WATER_PROOFING_NAME'),
                "효능효과 문서 데이터": item.get('EE_DOC_DATA')
            })

            count += 1
            print(count)


    except Exception as e:
        print(f'오류 발생: {e}')

        continue


# 가지고 온 데이터 DataFrame 형태로 변환
df = pd.DataFrame(products)

file_exists_csv = os.path.exists('../data/cosmetics.csv')
file_path_xlsx = '../data/cosmetics.xlsx'

# csv 파일로 저장
df.to_csv(
    'cosmetics.csv',
    mode = 'a',  # 이어서 저장하기
    header=not file_exists_csv, # 파일이 없다면 헤더를 사용, 있다면 추가
    index=False,
    encoding='utf-8-sig'
)

# 엑셀 파일로 저장
new_df = pd.DataFrame(products)

if os.path.exists(file_path_xlsx):  # 기존 파일이 있다면

    # 기존파일
    old_df = pd.read_excel(file_path_xlsx)

    # 병합
    merged_df = pd.concat(
        [old_df, new_df],
        ignore_index=True
    )

    merged_df.to_excel(
        file_path_xlsx,
        index=False,
    )
else:  # 기존 파일이 없다면
    new_df.to_excel(
        file_path_xlsx,
        index=False,
    )

print("저장완료")