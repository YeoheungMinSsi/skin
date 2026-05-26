import pandas as pd
import glob

from services.detail_scraper import DetailScraper
from services.image_scraper import ImageScraper
from services.image_downloader import ImageDownloader
from services.ingredient_parser import IngredientParser
from services.ingredient_saver import IngredientSaver


class IngredientPipeline:


    def run(

            self,

            start=0,

            limit=None

    ):


        scraper=DetailScraper()

        image_scraper=(

            ImageScraper(

                scraper.driver

            )

        )

        downloader=(

            ImageDownloader()

        )

        parser=(

            IngredientParser()

        )

        saver=(

            IngredientSaver(

                "result/ingredients.csv"

            )

        )


        count=0


        files=(

            glob.glob(

                "data/products_*.csv"

            )

        )


        for file in files:


            df=(

                pd.read_csv(

                    file,

                    encoding="utf-8-sig"

                )

            )


            df=df[

                df["has_goods"]

                ==

                True

            ]


            df=df.iloc[

                start:

            ]

            for _, row in df.iterrows():

                ##################################
                # limit
                ##################################

                if (

                        limit is not None

                        and

                        count >= limit

                ):
                    print(

                        "\nlimit 도달"

                    )

                    scraper.close()

                    saver.save()

                    return

                goods_id = (

                    int(row["goods_id"])

                )

                print(

                    "\n================"

                )

                print(

                    f"[{count + 1}/{limit}]"

                )

                print(

                    "브랜드:",

                    row["브랜드"]

                )

                print(

                    "제품:",

                    row["제품명"]

                )

                print(

                    "search_id:",

                    row["search_id"]

                )

                print(

                    "goods_id:",

                    goods_id

                )

                ##################################
                # 제공고시
                ##################################

                html = (

                    scraper.get_provision(

                        goods_id

                    )

                )

                if html is None:
                    print(

                        "제공고시 실패"

                    )

                    continue

                ##################################
                # 파싱
                ##################################

                data = (

                    parser.parse(

                        html

                    )

                )

                ingredient = (

                    data.get(

                        "주요성분",

                        ""

                    )

                )

                print(

                    "\n주요성분:",

                    ingredient[:100]

                )

                ##################################
                # 이미지 필요
                ##################################

                need_image = (

                        ingredient == ""

                        or

                        ingredient == "상품상세참조"

                )

                print(

                    "이미지 필요:",

                    need_image

                )


                data=(

                    parser.parse(

                        html

                    )

                )


                ingredient=(

                    data.get(

                        "주요성분",

                        ""

                    )

                )


                ##################################
                # 이미지 필요
                ##################################

                need_image=(

                    ingredient==""

                    or

                    ingredient=="상품상세참조"

                )


                if need_image:


                    print(

                        "\n이미지 필요"

                    )


                    imgs=(

                        image_scraper.get_images(

                            goods_id

                        )

                    )


                    paths=[]


                    for idx,url in enumerate(

                            imgs

                    ):


                        path=(

                            downloader.save(

                                url,

                                row["제품명"],

                                idx

                            )

                        )


                        if path:

                            paths.append(

                                path

                            )


                    data["이미지"]=(
                        ";".join(paths)
                    )


                ##################################
                # 상태 저장
                ##################################

                if ingredient=="":

                    state="missing"

                elif ingredient=="상품상세참조":

                    state="detail"

                else:

                    state="normal"


                data["ingredient_state"]=state


                data["브랜드"]=(
                    row["브랜드"]
                )

                data["제품명"]=(
                    row["제품명"]
                )

                data["search_id"]=(
                    int(
                        row["search_id"]
                    )
                )

                data["goods_id"]=(
                    int(
                        goods_id
                    )
                )


                saver.add(

                    data

                )


                count += 1


        scraper.close()

        saver.save()