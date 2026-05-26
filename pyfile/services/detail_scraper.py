import time
import random

from selenium import webdriver
from selenium.webdriver.chrome.options import Options


class DetailScraper:


    def __init__(self):


        options = Options()


        ##################################
        # headless 끄기
        ##################################

        options.add_argument(

            "--disable-blink-features=AutomationControlled"

        )


        options.add_argument(

            "user-agent=Mozilla/5.0 "
            "(Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 "
            "(KHTML, like Gecko) "
            "Chrome/136 Safari/537.36"

        )


        self.driver = webdriver.Chrome(

            options=options

        )


    ##################################
    # 제공고시
    ##################################

    def get_provision(

            self,

            goods_id

    ):


        url=(

            "https://www.hwahae.co.kr/"

            f"goods/{int(goods_id)}"

            "/provision-notice"

        )


        print(

            "\nURL:",

            url

        )


        self.driver.get(

            url

        )


        wait=random.uniform(

            4,

            10

        )


        time.sleep(

            wait

        )


        html=(

            self.driver.page_source

        )


        ##################################
        # AWS WAF
        ##################################

        if (

                "Human Verification"

                in html

                or

                "awsWaf"

                in html

        ):


            print(

                "\n봇 차단"

            )


            rest=random.uniform(

                30,

                90

            )


            print(

                "휴식:",

                round(rest),

                "초"

            )


            time.sleep(

                rest

            )


            self.driver.get(

                url

            )


            time.sleep(

                10

            )


            html=(

                self.driver.page_source

            )


        return html


    ##################################
    # 종료
    ##################################

    def close(

            self

    ):


        self.driver.quit()