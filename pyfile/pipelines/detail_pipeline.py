import pandas as pd

from services.detail_scraper import DetailScraper
from services.provision_parser import ProvisionParser
from services.provision_saver import ProvisionSaver


class DetailPipeline:


    def run(

            self,

            start=0,

            limit=None

    ):


        ##################################
        # 제품 csv 읽기
        ##################################

        df = pd.read_csv(

            "data/hwahae_products.csv",

            encoding="utf-8-sig"

        )


        total = len(df)


        ##################################
        # 시작 위치
        ##################################

        if start:


            df = df.iloc[start:]


        ##################################
        # 개수 제한
        ##################################

        if limit:


            df = df.head(limit)


        print(
            "\n전체:",
            total
        )

        print(
            "시작:",
            start
        )

        print(
            "실행:",
            len(df)
        )


        scraper = DetailScraper()

        parser = ProvisionParser()

        saver = ProvisionSaver()


        ##################################
        # 반복
        ##################################

        for count, (_, row) in enumerate(

                df.iterrows(),

                start=1

        ):


            current = start + count


            pid = row["product_id"]

            pname = row["제품명"]


            print(

                f"\n[{current}/{total}]"

            )


            print(

                "제품:",

                pname

            )


            ##################################
            # 제공고시 html
            ##################################

            html = (

                scraper.get_provision(

                    pid

                )

            )


            ##################################
            # 성분 파싱
            ##################################

            data = (

                parser.parse(

                    html

                )

            )


            print(

                "상태:",

                data.get(

                    "상태"

                )

            )


            ##################################
            # 추가 정보
            ##################################

            data["product_id"] = pid

            data["제품명"] = pname

            data["브랜드"] = row["브랜드"]

            data["회사"] = row["회사"]


            saver.add(

                data

            )


            ##################################
            # 중간 저장
            ##################################

            if count % 20 == 0:


                saver.save()


                print(

                    "\n중간 저장"

                )


        saver.save()


        print(

            "\n종료"

        )