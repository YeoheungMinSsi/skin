import pandas as pd
import os
import glob


class ProductSaver:


    def __init__(

            self,

            save_dir="data",

            max_rows=100000,

            clear_old=False,

            prefix="products"

    ):


        self.rows = []

        self.save_dir = save_dir

        self.max_rows = max_rows

        self.prefix = prefix


        os.makedirs(

            save_dir,

            exist_ok=True

        )


        ##################################
        # 기존 제거
        ##################################

        if clear_old:


            files = (

                glob.glob(

                    f"{save_dir}/"

                    f"{prefix}_*.csv"

                )

            )


            for f in files:

                os.remove(

                    f

                )


            print(

                "\n기존 삭제 완료"

            )


    ##################################
    # 추가
    ##################################

    def add(

            self,

            country,

            company,

            brand,

            product,

            search_id,

            goods_id,

            encrypted_id,

            uid,

            has_goods

    ):


        self.rows.append({

            "나라":
                country,

            "회사":
                company,

            "브랜드":
                brand,

            "제품명":
                product,

            "search_id":
                search_id,

            "goods_id":
                goods_id,

            "encrypted_id":
                encrypted_id,

            "uid":
                uid,

            "has_goods":
                has_goods

        })


        if (

                len(

                    self.rows

                )

                >=

                self.max_rows

        ):


            self.save()


    ##################################
    # 파일 번호
    ##################################

    def next_num(self):


        nums=[]


        files=(

            glob.glob(

                f"{self.save_dir}/"

                f"{self.prefix}_*.csv"

            )

        )


        for f in files:


            try:


                n=int(

                    f.split(

                        "_"

                    )[-1]

                    .replace(

                        ".csv",

                        ""

                    )

                )


                nums.append(

                    n

                )


            except:

                pass


        if len(nums)==0:

            return 1


        return max(nums)+1


    ##################################
    # 저장
    ##################################

    def save(self):

        if len(self.rows) == 0:
            return

        num = (

            self.next_num()

        )

        path = (

            f"{self.save_dir}/"

            f"{self.prefix}_"

            f"{num}.csv"

        )

        df = (

            pd.DataFrame(

                self.rows

            )

        )

        ##################################
        # goods_id 정수 유지
        ##################################

        if "goods_id" in df.columns:
            df["goods_id"] = (

                df["goods_id"]

                .astype("Int64")

            )

        if "search_id" in df.columns:
            df["search_id"] = (

                df["search_id"]

                .astype("Int64")

            )

        df.to_csv(

            path,

            index=False,

            encoding="utf-8-sig"

        )

        print(

            "\n저장 완료"

        )

        print(

            "파일:",

            path

        )

        print(

            "행:",

            len(df)

        )

        self.rows = []