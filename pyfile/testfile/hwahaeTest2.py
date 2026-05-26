import requests

url = (
'https://www.hwahae.co.kr/goods/'
'토리든-only화해-다이브인-저분자-히알루론산-세럼-100ml-PLUS수딩크림-20ml-3/'
'54413/provision-notice'
)

headers = {
    "User-Agent":
        "Mozilla/5.0",

    "Referer":
        "https://www.hwahae.co.kr/",

    "Accept":
        "text/html"
}


response = requests.get(
    url,
    headers=headers
)

print("상태코드:", response.status_code)

print(response.text[:500])