import glob
import pandas as pd

from services.detail_scraper import DetailScraper
from services.ingredient_parser import IngredientParser
from services.ingredient_saver import IngredientSaver

from services.image_scraper import ImageScraper
from services.image_downloader import ImageDownloader


class IngredientPipeline:


    ##################################
    # 전체 수집
    ##################################

    def run(

            self,

            start=0,

            limit=None

    ):


        scraper=(

            DetailScraper()

        )


        parser=(

            IngredientParser()

        )


        saver=(

            IngredientSaver(

                "result/ingredients.csv"

            )

        )


        image_scraper=(

            ImageScraper(

                scraper.driver

            )

        )


        downloader=(

            ImageDownloader()

        )


        count=0


        files=(

            glob.glob(

                "data/products_*.csv"

            )

        )


        for file in files:


            print(

                "\n파일:",

                file

            )


            df=(

                pd.read_csv(

                    file,

                    encoding="utf-8-sig"

                )

            )


            ##################################
            # goods 있는 것만
            ##################################

            df=(

                df[

                    df["has_goods"]

                    ==

                    True

                ]

            )


            df=(

                df.iloc[

                    start:

                ]

            )


            for _,row in df.iterrows():


                ##################################
                # limit
                ##################################

                if (

                        limit is not None

                        and

                        count>=limit

                ):


                    print(

                        "\nlimit 도달"

                    )


                    scraper.close()

                    saver.save()

                    return


                goods_id=(

                    int(row["goods_id"])

                )


                print(

                    "\n================"

                )


                print(

                    f"[{count+1}/{limit}]"

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

                html=(

                    scraper.get_provision(

                        goods_id

                    )

                )


                ##################################
                # blocked
                ##################################

                if html is None:


                    data={


                        "브랜드":
                            row["브랜드"],


                        "제품명":
                            row["제품명"],


                        "goods_id":
                            goods_id,


                        "search_id":
                            row["search_id"],


                        "ingredient_state":
                            "blocked"

                    }


                    saver.add(

                        data

                    )


                    count += 1


                    continue


                ##################################
                # 파싱
                ##################################

                data=(

                    parser.parse(

                        html

                    )

                )


                ingredient=(

                    str(

                        data.get(

                            "주요성분",

                            ""

                        )

                    )

                    .strip()

                )


                print(

                    "\n주요성분:",

                    ingredient[:100]

                )


                ##################################
                # 이미지 필요 판단
                ##################################

                keywords=[

                    "상세",

                    "참조",

                    "참고",

                    "페이지"

                ]


                need_image=(

                        ingredient==""

                        or

                        any(

                            k in ingredient

                            for k in keywords

                        )

                )


                print(

                    "이미지 필요:",

                    need_image

                )


                ##################################
                # 이미지 저장
                ##################################

                if need_image:


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


                            print(

                                "저장:",

                                path

                            )


                            paths.append(

                                path

                            )


                    data["이미지"]=(

                        ";".join(

                            paths

                        )

                    )


                ##################################
                # 상태
                ##################################

                if ingredient=="":


                    state="missing"


                elif any(

                        k in ingredient

                        for k in keywords

                ):


                    state="detail"


                else:


                    state="normal"


                data[

                    "ingredient_state"

                ]=state


                ##################################
                # 공통값
                ##################################

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


    ##################################
    # 실패 재시도
    ##################################

    def run_retry(

            self,

            limit=None

    ):


        df=(

            pd.read_csv(

                "result/ingredients.csv",

                encoding="utf-8-sig"

            )

        )


        retry_idx=(

            df[

                (

                    df["ingredient_state"]

                    ==

                    "blocked"

                )

                |

                (

                    df["ingredient_state"]

                    ==

                    "missing"

                )

            ]

            .index

        )


        print(

            "\n재시도:",

            len(

                retry_idx

            )

        )


        scraper=(

            DetailScraper()

        )


        parser=(

            IngredientParser()

        )


        count=0


        for idx in retry_idx:


            if (

                    limit

                    and

                    count>=limit

            ):


                break


            goods_id=(

                df.loc[

                    idx,

                    "goods_id"

                ]

            )


            print(

                "\n재시도:",

                df.loc[

                    idx,

                    "제품명"

                ]

            )


            html=(

                scraper.get_provision(

                    goods_id

                )

            )


            if html is None:

                continue


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


            if ingredient:


                df.loc[
                    idx,
                    "주요성분"
                ]=ingredient


                df.loc[
                    idx,
                    "ingredient_state"
                ]="normal"


                print(

                    "업데이트 성공"

                )


            count += 1


        scraper.close()


        df.to_csv(

            "result/ingredients.csv",

            index=False,

            encoding="utf-8-sig"

        )


        print(

            "\n저장 완료"

        )