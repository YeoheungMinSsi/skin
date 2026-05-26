import pandas as pd
import os


class ProvisionSaver:


    def __init__(self):

        self.rows=[]


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


        os.makedirs(

            "result",

            exist_ok=True

        )


        df=(

            pd.DataFrame(

                self.rows

            )

        )


        df.to_csv(

            "result/provision_result.csv",

            index=False,

            encoding="utf-8-sig"

        )


        print(
            "\n저장 완료"
        )


        print(
            "행:",
            len(df)
        )