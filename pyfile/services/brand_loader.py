import pandas as pd
import os


class BrandLoader:


    def __init__(

            self,

            base_path,

            extra_path=None

    ):

        self.base_path = base_path
        self.extra_path = extra_path


    ##################################
    # 여러 인코딩 시도
    ##################################

    def read_csv(

            self,

            path

    ):


        encodings = [

            "utf-8-sig",

            "cp949",

            "euc-kr"

        ]


        for enc in encodings:


            try:


                df = pd.read_csv(

                    path,

                    encoding=enc

                )


                print(

                    f"인코딩 성공: {enc}"

                )


                return df


            except Exception:


                print(

                    f"실패: {enc}"

                )


        ##################################
        # 모두 실패
        ##################################

        raise Exception(

            f"\n읽기 실패:\n{path}"

        )


    ##################################
    # 브랜드 불러오기
    ##################################

    def load(self):


        print(
            "\n기존 브랜드 로드"
        )


        ##################################
        # 기존 브랜드
        ##################################

        base = (

            self.read_csv(

                self.base_path

            )

        )


        ##################################
        # 추가 브랜드 존재
        ##################################

        if (

                self.extra_path

                and

                os.path.exists(

                    self.extra_path

                )

        ):


            print(
                "추가 브랜드 병합"
            )


            new = (

                self.read_csv(

                    self.extra_path

                )

            )


            df = pd.concat(

                [

                    base,

                    new

                ],

                ignore_index=True

            )


            ##################################
            # 브랜드 중복 제거
            ##################################

            df = (

                df.drop_duplicates(

                    subset=["브랜드"]

                )

            )


        else:


            df = base


        print(

            "총 브랜드:",

            len(df)

        )


        print(

            "컬럼:",

            df.columns.tolist()

        )


        return df