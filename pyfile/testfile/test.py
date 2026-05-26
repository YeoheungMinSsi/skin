# import requests
#
# url = 'http://apis.data.go.kr/1471000/FtnltCosmRptPrdlstInfoService/getRptPrdlstInq'
# params ={
#     'serviceKey' : 'a037e6d62cded0f4e2082f45dd0fbd5f0ec5459795085b86e012d1d037e18604',
#     'pageNo' : '1',
#     'numOfRows' : '10',
#     'type' : 'xml',
#     'item_seq' : '',
#     'item_name' : '',
#     'cosmetic_report_seq' : ''
# }
#
# response = requests.get(url, params=params)
# # print(response.content)
# print(response.text)


# XML방식
# import requests
# import xml.etree.ElementTree as ET
#
# url = 'http://apis.data.go.kr/1471000/FtnltCosmRptPrdlstInfoService/getRptPrdlstInq'
# params = {
#     'serviceKey': 'a037e6d62cded0f4e2082f45dd0fbd5f0ec5459795085b86e012d1d037e18604',
#     'pageNo': '1',
#     'numOfRows': '10',
#     'type': 'xml',
#     'item_seq': '',
#     'item_name': '',
#     'cosmetic_report_seq': ''
# }
#
# response = requests.get(url, params=params)
#
# # 1. XML 텍스트를 파이썬이 이해할 수 있는 트리 객체로 변환합니다.
# root = ET.fromstring(response.text)
#
# # 2. XML 트리 안에서 모든 <item> 태그를 찾아 순회합니다.
# for item in root.findall('.//item'):
#     # 3. 각 아이템 안에서 원하는 데이터(태그)의 텍스트를 추출합니다.
#     item_name = item.findtext('ITEM_NAME')
#     entp_name = item.findtext('ENTP_NAME')
#     item_ph = item.findtext('ITEM_PH')
#
#     print(f"제품명: {item_name} / 업체명: {entp_name} / pH: {item_ph}")


# json방식
import requests
#
# url = 'http://apis.data.go.kr/1471000/FtnltCosmRptPrdlstInfoService/getRptPrdlstInq'
# params ={
#     'serviceKey' : 'a037e6d62cded0f4e2082f45dd0fbd5f0ec5459795085b86e012d1d037e18604',
#     'pageNo' : '1',
#     'numOfRows' : '10',
#     'type' : 'json',
#     'item_seq' : '',
#     'item_name' : '',
#     'cosmetic_report_seq' : ''
# }
#


import requests
import pandas as pd

url = 'http://apis.data.go.kr/1471000/FtnltCosmRptPrdlstInfoService/getRptPrdlstInq'
apiKey = 'a037e6d62cded0f4e2082f45dd0fbd5f0ec5459795085b86e012d1d037e18604'

products = []

for page in range(1, 10):

    params ={
        'serviceKey' : apiKey,
        'pageNo' : page,
        'numOfRows' : '1',
        'type' : 'json',
    }

    response = requests.get(url, params=params)
    data = response.json()

    # body에서 필수 데이터 가지고 오는 부분
    item = data['body']['items'][0]


    products.append({
        "품목일련번호" : item.get('COSMETIC_REPORT_SEQ'),
        "품목명" : item.get('ITEM_NAME'),
        "제조국가명" : item.get('MANUF_COUNTRY_NAME'),
        "PH 등급" : item.get('ITEM_PH')
    })

    # print(products)

print(products)