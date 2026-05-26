from services.brand_loader import BrandLoader
from services.hwahae_searcher import HwahaeSearcher
from services.product_saver import ProductSaver


class ProductPipeline:


    ##################################
    # 전체
    ##################################

    def run(self):


        loader=(

            BrandLoader(

                "data/cosmetics_brand.csv"

            )

        )


        brands=(

            loader.load()

        )


        self.process(

            brands,

            clear_old=True,

            prefix="products"

        )


    ##################################
    # 테스트
    ##################################

    def run_test(

            self,

            start=0,

            limit=10

    ):


        loader=(

            BrandLoader(

                "data/cosmetics_brand.csv"

            )

        )


        brands=(

            loader.load()

        )


        total=len(

            brands

        )


        brands=(

            brands.iloc[

                start:

            ]

        )


        brands=(

            brands.head(

                limit

            )

        )


        print(

            "\n===== TEST ====="

        )


        print(

            "전체:",

            total

        )


        print(

            "시작:",

            start

        )


        print(

            "실행:",

            len(brands)

        )


        self.process(

            brands,

            clear_old=True,

            prefix="test_products"

        )


    ##################################
    # 공통
    ##################################

    def process(

            self,

            brands,

            clear_old=False,

            prefix="products"

    ):


        searcher=(

            HwahaeSearcher()

        )


        saver=(

            ProductSaver(

                save_dir="data",

                max_rows=100000,

                clear_old=clear_old,

                prefix=prefix

            )

        )


        total=len(

            brands

        )


        for idx,row in (

                brands.iterrows()

        ):


            print(

                "\n================"

            )


            print(

                f"[{idx+1}/"

                f"{total}]"

            )


            brand=row["브랜드"]


            print(

                "브랜드:",

                brand

            )


            try:


                products=(

                    searcher.search(

                        brand

                    )

                )


                for p in products:


                    goods_id=None
                    has_goods=False


                    if (

                            len(

                                p["goods"]

                            )

                            >0

                    ):


                        goods_id=(

                            p["goods"]

                            [0]

                            ["id"]

                        )


                        has_goods=True


                    saver.add(

                        row["나라"],

                        row["회사"],

                        brand,

                        p["productName"],

                        p["id"],

                        goods_id,

                        p["encryptedProductId"],

                        p["uid"],

                        has_goods

                    )


            except Exception as e:


                print(

                    "\nERROR"

                )


                print(e)


        saver.save()


        print(

            "\n종료"

        )