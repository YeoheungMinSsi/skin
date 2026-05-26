from services.brand_loader import BrandLoader
from services.hwahae_searcher import HwahaeSearcher
from services.product_saver import ProductSaver


class TestPipeline:


    def run(self):


        reader = BrandLoader(

            "data/cosmetics_brand.csv"

        )


        searcher = HwahaeSearcher()


        saver = ProductSaver(

            "data/test_products.csv"

        )


        brands = reader.load()


        total_saved = 0


        ##################################
        # 브랜드 반복
        ##################################

        for _, row in brands.iterrows():


            country = row["나라"]

            company = row["회사"]

            brand = row["브랜드"]


            print(
                "\n================"
            )

            print(
                "브랜드:",

                brand
            )


            try:


                products = (

                    searcher.search(
                        brand
                    )

                )


                for p in products:


                    saver.add(

                        country,

                        company,

                        brand,

                        p["productName"],

                        p["id"]

                    )


                    total_saved += 1


                    ##################################
                    # 테스트 종료
                    ##################################

                    if total_saved >= 100:


                        print(
                            "\n100개 도달"
                        )


                        saver.save()


                        return


            except Exception as e:


                print(
                    "\nERROR"
                )

                print(e)


        saver.save()