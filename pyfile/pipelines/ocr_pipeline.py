import os
import shutil
import pandas as pd

from services.ocr_reader import OCRReader
from services.image_filter import ImageFilter


class OCRPipeline:

    def run(
            self,
            limit=None
    ):

        df = pd.read_csv(
            "result/ingredients.csv",
            encoding="utf-8-sig"
        )


        df = df[
            df["이미지"]
            .notna()
        ]


        reader = OCRReader()

        filterer = ImageFilter()


        os.makedirs(
            "filter_img",
            exist_ok=True
        )


        count = 0


        for _, row in df.iterrows():

            if (
                limit
                and
                count >= limit
            ):
                break


            print(
                "\n================"
            )

            print(
                "제품:",
                row["제품명"]
            )


            imgs = [

                x

                for x

                in str(
                    row["이미지"]
                ).split(";")

                if x.strip()

            ]


            scores = []


            ##################################
            # OCR
            ##################################

            for img in imgs:

                text = reader.read(
                    img
                )

                score = filterer.score(
                    text
                )

                print(
                    "\n이미지:",
                    img
                )

                print(
                    "점수:",
                    score
                )

                scores.append(
                    (
                        score,
                        img,
                        text
                    )
                )


            if len(scores) == 0:
                continue


            scores.sort(
                reverse=True
            )


            best = scores[0]


            ##################################
            # 대표 이미지 저장
            ##################################

            try:

                main = reader.find_image(
                    imgs[0]
                )

                if main:

                    dst = os.path.join(

                        "filter_img",

                        row["제품명"]

                        +

                        "_main.jpg"

                    )


                    if not os.path.exists(
                        dst
                    ):

                        shutil.copy(
                            main,
                            dst
                        )


                        print(
                            "대표 저장"
                        )

            except:
                pass



            ##################################
            # 전성분 이미지 저장
            ##################################

            if best[0] >= 20:


                src = reader.find_image(
                    best[1]
                )


                if src:

                    dst = os.path.join(

                        "filter_img",

                        row["제품명"]

                        +

                        "_ingredient.jpg"

                    )


                    shutil.copy(
                        src,
                        dst
                    )


                    print(
                        "전성분 저장"
                    )


            else:

                print(
                    "전성분 없음"
                )


            count += 1