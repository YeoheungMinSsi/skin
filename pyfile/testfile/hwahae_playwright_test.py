from playwright.sync_api import sync_playwright


url = (
'https://www.hwahae.co.kr/goods/'
'토리든-only화해-다이브인-저분자-히알루론산-세럼-100ml-PLUS수딩크림-20ml-3/'
'54413/provision-notice'
)


with sync_playwright() as p:

    browser = p.chromium.launch(

        channel="chrome",

        headless=False,

        args=[
            "--disable-blink-features=AutomationControlled"
        ]
    )


    context = browser.new_context(

        user_agent=(
            "Mozilla/5.0 "
            "(Windows NT 10.0; Win64; x64)"
        )
    )


    page = context.new_page()

    page.goto(url)

    page.wait_for_timeout(
        5000
    )


    html = page.content()


    with open(
            "../hwahae.html",
        "w",
        encoding="utf-8"
    ) as f:

        f.write(html)


    print("저장 완료")


    page.wait_for_timeout(
        10000
    )


    browser.close()