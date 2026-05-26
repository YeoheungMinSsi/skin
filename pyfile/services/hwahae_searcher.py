import requests
import time


class HwahaeSearcher:


    BUILD_ID = (

        "m7nVa-Zqug9nw672Xp5NJ"

    )


    SEARCH_URL = (

        "https://www.hwahae.co.kr/"
        "_next/data/"
        + BUILD_ID
        + "/search.json"

    )


    GATEWAY_URL = (

        "https://gateway.hwahae.co.kr/"
        "v14/search/products/text"

    )


    ##################################
    # 공통 헤더
    ##################################

    def gateway_headers(self):


        return {

            "User-Agent":
                "Mozilla/5.0",

            "Authorization":
                "Bearer",

            "hwahae-device-id":
                "anonymous",

            "hwahae-user-id":
                "anonymous",

            "Referer":
                "https://www.hwahae.co.kr/"
        }


    ##################################
    # preview
    ##################################

    def search_preview(

            self,

            keyword

    ):


        response=requests.get(

            self.SEARCH_URL,

            params={

                "q":

                    keyword

            },

            headers={

                "User-Agent":

                    "Mozilla/5.0"

            }

        )


        data=response.json()


        return (

            data["pageProps"]

            ["products"]

            ["products"]

        )


    ##################################
    # products
    ##################################

    def search_products(

            self,

            keyword

    ):


        response=requests.get(

            self.SEARCH_URL,

            params={

                "q":
                    keyword,

                "type":
                    "products"

            },

            headers={

                "User-Agent":
                    "Mozilla/5.0"

            }

        )


        data=response.json()


        return (

            data["pageProps"]

            ["products"]

            ["products"]

        )


    ##################################
    # gateway
    ##################################

    def search_more(

            self,

            keyword,

            page

    ):


        response=requests.get(

            self.GATEWAY_URL,

            params={

                "orderType":

                    "ranking",

                "pageNum":

                    page,

                "query":

                    keyword

            },

            headers=self.gateway_headers()

        )


        print(

            "GW:",

            response.status_code,

            "page:",

            page

        )


        if response.status_code != 200:

            return []


        data=response.json()


        return (

            data.get(

                "products",

                []

            )

        )


    ##################################
    # 전체
    ##################################

    def search(

            self,

            keyword

    ):


        seen=set()

        result=[]


        ##################################
        # preview
        ##################################

        preview=(

            self.search_preview(

                keyword

            )

        )


        for p in preview:


            if p["id"] not in seen:


                seen.add(

                    p["id"]

                )


                result.append(

                    p

                )


        print(

            "\npreview:",

            len(result)

        )


        ##################################
        # products
        ##################################

        products=(

            self.search_products(

                keyword

            )

        )


        for p in products:


            if p["id"] not in seen:


                seen.add(

                    p["id"]

                )


                result.append(

                    p

                )


        print(

            "초기:",

            len(result)

        )


        ##################################
        # gateway 반복
        ##################################

        page=1


        while True:


            before=len(

                result

            )


            more=(

                self.search_more(

                    keyword,

                    page

                )

            )


            for p in more:


                if p["id"] not in seen:


                    seen.add(

                        p["id"]

                    )


                    result.append(

                        p

                    )


            added=(

                len(result)

                -

                before

            )


            print(

                f"page {page}",

                "신규:",

                added,

                "누적:",

                len(result)

            )


            ##################################
            # 증가 없으면 종료
            ##################################

            if added==0:

                break


            page += 1

            time.sleep(

                0.5

            )


        print(

            "\n총:",

            len(result)

        )


        return result