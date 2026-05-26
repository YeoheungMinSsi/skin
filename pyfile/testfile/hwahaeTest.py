import requests

keyword = "다이브인"

url = (
    "https://www.hwahae.co.kr/"
    "_next/data/"
    "ozrdCJzki5iKOBI4oNXnB/"
    f"search.json?q={keyword}"
)

headers = {
    "User-Agent":
    "Mozilla/5.0"
}

response = requests.get(
    url,
    headers=headers
)

print(response.status_code)
print(response.text[:300])   # 먼저 확인


data = response.json()

products = (
    data['pageProps']
        ['goods']
        ['data']
)

for product in products:

    print(
        product['name'],
        product['index']
    )