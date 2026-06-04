import time

from selenium.webdriver.common.by import By


class ImageScraper:


    def __init__(

            self,

            driver

    ):


        self.driver = driver


    ##################################
    # 상세 이미지
    ##################################

    def get_images(

            self,

            goods_id

    ):


        url=(

            "https://www.hwahae.co.kr/"

            f"goods/{int(goods_id)}"

        )


        print(

            "\n상품:",

            url

        )


        self.driver.get(

            url

        )


        time.sleep(

            5

        )


        imgs=(

            self.driver.find_elements(

                By.CSS_SELECTOR,

                "main img"

            )

        )


        result=[]


        ##################################
        # img url
        ##################################

        for img in imgs:


            src=(

                img.get_attribute(

                    "src"

                )

            )


            if (

                    src

                    and

                    "img.hwahae"

                    in src

            ):


                result.append(

                    src

                )


        ##################################
        # 중복 제거
        ##################################

        result=list(

            dict.fromkeys(

                result

            )

        )


        print(

            "전체 이미지:",

            len(result)

        )


        ##################################
        # 앞 2개
        ##################################

        first=(

            result[:2]

        )


        ##################################
        # 뒤 3개
        ##################################

        last=(

            result[-3:]

        )


        ##################################
        # 합치기 + 중복 제거
        ##################################

        selected=(

            list(

                dict.fromkeys(

                    first + last

                )

            )

        )


        print(

            "사용 이미지:",

            len(selected)

        )


        print(

            "선택:",

            range(

                len(selected)

            )

        )


        return selected