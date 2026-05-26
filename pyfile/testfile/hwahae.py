# import requests
#
# keyword = "독도토너"
#
# url = (
#     "https://www.hwahae.co.kr/"
#     "_next/data/koNrZGigg6B9NxD1p9its/"
#     f"search.json?q={keyword}"
# )
#
# headers = {
#     "User-Agent":
#     "Mozilla/5.0"
# }
#
# response = requests.get(
#     url,
#     headers=headers
# )
#
# data = response.json()
#
# # print(data.keys())
# print(data)
# # goods_id = (
# #     data['pageProps']
# #         ['products'][0]
# #         ['goods']
# #         ['id']
# # )
# #
# # print(goods_id)

import requests

keyword = "다이브인"

url = (
    "https://www.hwahae.co.kr/"
    "_next/data/koNrZGigg6B9NxD1p9its/"
    f"search.json?q={keyword}"
)

# response = requests.get(url)
#
# data = response.json()

response = requests.get(url)

print(response.status_code)
print(response.text[:500])

#
# products = (
#     data['pageProps']
#         ['goods']
#         ['data']
# )
#
# for product in products:
#
#     goods_id = product['index']
#
#     print(
#         product['name'],
#         goods_id
#     )