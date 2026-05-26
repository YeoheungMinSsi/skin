import requests
import os
import re


class ImageDownloader:


    def __init__(self):


        os.makedirs(

            "img",

            exist_ok=True

        )


    ##################################
    # 파일명 정리
    ##################################

    def clean_name(

            self,

            text

    ):


        text = re.sub(

            r'[\\/:*?"<>|]',

            "",

            str(text)

        )


        text = text.strip()


        return text


    ##################################
    # 저장
    ##################################

    def save(

            self,

            url,

            product_name,

            idx

    ):


        try:


            r = requests.get(

                url,

                timeout=30

            )


            name = (

                self.clean_name(

                    product_name

                )

            )


            path=(

                "img/"

                f"{name}_"

                f"{idx}.jpg"

            )


            with open(

                    path,

                    "wb"

            ) as f:


                f.write(

                    r.content

                )


            print(

                "저장:",

                path

            )


            return path


        except Exception as e:


            print(

                "이미지 저장 실패:",

                e

            )


            return None