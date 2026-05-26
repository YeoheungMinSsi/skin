import pandas as pd
import os


class IngredientSaver:


    def __init__(

            self,

            path

    ):


        self.rows=[]

        self.path=path


        os.makedirs(

            "result",

            exist_ok=True

        )


    ##################################
    # 추가
    ##################################

    def add(

            self,

            row

    ):


        self.rows.append(

            row

        )


    ##################################
    # 저장
    ##################################

    def save(self):


        if len(

                self.rows

        )==0:


            print(

                "\n저장할 데이터 없음"

            )


            return


        new_df=(

            pd.DataFrame(

                self.rows

            )

        )


        ##################################
        # 기존 파일 존재
        ##################################

        if os.path.exists(

                self.path

        ):


            old_df=(

                pd.read_csv(

                    self.path,

                    encoding="utf-8-sig"

                )

            )


            df=(

                pd.concat(

                    [

                        old_df,

                        new_df

                    ],

                    ignore_index=True

                )

            )


            ##################################
            # 중복 제거
            ##################################

            df=(

                df.drop_duplicates(

                    subset=[

                        "goods_id"

                    ]

                )

            )


        else:


            df=new_df


        df.to_csv(

            self.path,

            index=False,

            encoding="utf-8-sig"

        )


        print(

            "\n저장:",

            self.path

        )


        print(

            "총:",

            len(df)

        )


        self.rows=[]