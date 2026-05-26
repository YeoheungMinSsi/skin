import pandas as pd
import glob

from services.hwahae_searcher import HwahaeSearcher


class UpdateGoodsPipeline:


    def run(self):


        files=(

            glob.glob(

                "data/products_*.csv"

            )

        )


        searcher=(

            HwahaeSearcher()

        )


        for file in files:


            df=(

                pd.read_csv(

                    file,

                    encoding="utf-8-sig"

                )

            )


            goods_ids=[]
            has_goods=[]


            for _,row in df.iterrows():


                brand=row["브랜드"]
                pname=row["제품명"]


                products=(

                    searcher.search(

                        brand

                    )

                )


                gid=None
                flag=False


                for p in products:


                    if (

                            p["productName"]

                            ==

                            pname

                    ):


                        if (

                                len(

                                    p["goods"]

                                )

                                >0

                        ):


                            gid=(

                                p["goods"]

                                [0]

                                ["id"]

                            )


                            flag=True


                        break


                goods_ids.append(

                    gid

                )


                has_goods.append(

                    flag

                )


            df["goods_id"]=goods_ids
            df["has_goods"]=has_goods


            df.to_csv(

                file,

                index=False,

                encoding="utf-8-sig"

            )


            print(

                "완료:",

                file

            )