import time

from selenium.webdriver.common.by import By


class ImageScraper:


    def __init__(

            self,

            driver

    ):


        self.driver=driver


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


        result=list(

            set(

                result

            )

        )


        print(

            "이미지:",

            len(result)

        )


        return result