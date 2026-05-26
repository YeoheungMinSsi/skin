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

url = 'http://apis.data.go.kr/1471000/FtnltCosmRptPrdlstInfoService/getRptPrdlstInq'
params ={
    'serviceKey' : 'a037e6d62cded0f4e2082f45dd0fbd5f0ec5459795085b86e012d1d037e18604',
    'pageNo' : '1',
    'numOfRows' : '10',
    'type' : 'json',
    'item_seq' : '',
    'item_name' : '',
    'cosmetic_report_seq' : ''
}

response = requests.get(url, params=params)

# 1. JSON 데이터를 파이썬 딕셔너리로 즉시 파싱합니다.
data = response.json()

# 2. 딕셔너리 구조를 따라 원하는 데이터가 있는 곳까지 찾아갑니다.
# (공공데이터포털 표준 JSON 구조: data['response']['body']['items'])

# print(data['body'])
print(data['body']['items'][1])
# print(data['body']['items'][0].get('COSMETIC_STD_NAME'))
# items = data['body']['items']
# print(items['COSMETIC_REPORT_SEQ'])
# print(data['body']['items']['COSMETIC_REPORT_SEQ', 'ITEM_NAME', 'ITEM_PH', 'COSMETIC_STD_CODE', 'ENTP_NAME', 'ETHANOL_OVER_YN', '효능효과 문서 데이터'])
# try:
#     items = data['response']['body']['items']
#
#     # 3. 리스트를 순회하며 딕셔너리의 키(key)를 이용해 값을 추출합니다.
#     for item in items:
#         print(f"제품명: {item.get('ITEM_NAME')} / 업체명: {item.get('ENTP_NAME')} / pH: {item.get('ITEM_PH')}")
#
# except KeyError:
#     print("데이터를 불러오지 못했거나 JSON 구조가 예상과 다릅니다.\n전체 응답:", data)