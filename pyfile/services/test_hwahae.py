# import requests
#
#
# # 브랜드명을 통해 화해 검색
# class HwahaeSearcher:
#     BUILD_ID = ("m7nVa-Zqug9nw672Xp5NJ")
#     BASE_URL = (
#         "https://www.hwahae.co.kr/"
#         "_next/data/"
#     )
#
#     # 검색 함수
#     def search(self, keyword):
#         page = 1
#         all_products = []
#         seen_ids = set()
#
#         while True:
#             print("\n=================")
#             print("[검색 시작]")
#             print("브랜드:", keyword)
#             print("페이지:", page)
#
#             # URL 생성
#             url = (
#                 self.BASE_URL
#                 + self.BUILD_ID
#                 + "/search.json"
#                 + f"?q={keyword}"
#                 + "&type=products"
#                 + f"&pageNum={page}"
#             )
#
#             print("URL:")
#             print(url)
#
#             headers = {
#                 "User-Agent":
#                 "Mozilla/5.0"
#             }
#
#             try:
#                 # 요청
#                 response = requests.get(url, headers=headers)
#
#                 print("\n[응답]")
#                 print("상태코드:", response.status_code)
#
#                 # 403
#                 if response.status_code == 403:
#                     print("[ERROR] 403 차단")
#                     break
#
#                 # 404
#                 if response.status_code == 404:
#                     print("[ERROR] BUILD_ID 확인")
#                     break
#
#                 # JSON 변환
#                 data = (response.json())
#
#                 # 제품 리스트
#                 products = (data["pageProps"]["products"]["products"])
#
#                 # meta 정보
#                 meta = (data["pageProps"]["products"]["meta"])
#
#                 print("전체 검색 결과:", meta["totalResultCount"])
#                 print("현재 페이지 수집:", len(products))
#
#                 before_count = len(all_products)
#
#                 ##################################
#                 # 중복 제거 저장
#                 ##################################
#
#                 for product in products:
#                     pid = product["id"]
#                     if pid not in seen_ids:
#                         seen_ids.add(pid)
#                         all_products.append(product)
#
#                 added = (len(all_products) - before_count)
#                 print("이번 페이지 신규:", added)
#                 print("누적 제품 수:", len(all_products))
#
#                 # 새로 추가된 게 없으면 종료
#                 if len(all_products) <= before_count:
#                     print("\n중복 페이지만 반복됨")
#                     print("검색 종료")
#                     break
#
#                 # 전체 수집 완료
#                 if (len(all_products) >= meta["totalResultCount"]):
#                     print("\n전체 수집 완료")
#                     break
#
#                 page += 1
#
#             except Exception as e:
#                 print("\n[예외 발생]")
#                 print(type(e))
#                 print(e)
#                 break
#
#         # 최종 반환
#         print("\n===== 검색 종료 =====")
#         print("총 수집:", len(all_products))
#
#         return all_products

import requests


class HwahaeSearcher:


    #################################
    # search.json
    #################################

    BUILD_ID = (
        "m7nVa-Zqug9nw672Xp5NJ"
    )


    SEARCH_URL = (

        "https://www.hwahae.co.kr/"
        "_next/data/"

        + BUILD_ID

        +

        "/search.json"

    )


    #################################
    # gateway
    #################################

    GATEWAY_URL = (

        "https://gateway.hwahae.co.kr/"

        "v14/search/products/text"

    )



    #################################
    # 첫 20개
    #################################

    def search_first_page(

            self,

            keyword

    ):


        print(
            "\n[1단계]"
            " search.json"
        )


        params = {

            "q":
                keyword

        }


        headers = {

            "User-Agent":
                "Mozilla/5.0"

        }


        response = requests.get(

            self.SEARCH_URL,

            params=params,

            headers=headers

        )


        print(
            "상태:",
            response.status_code
        )


        data = response.json()


        products = (

            data["pageProps"]

            ["products"]

            ["products"]

        )


        print(

            "초기 수집:",

            len(products)

        )


        return products



    #################################
    # 이후 페이지
    #################################

    def search_more(

            self,

            keyword,

            page

    ):


        print(
            f"\n[추가]"
            f" page={page}"
        )


        params = {

            "orderType":
                "ranking",

            "pageNum":
                page,

            "query":
                keyword

        }


        headers = {

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


        response = requests.get(

            self.GATEWAY_URL,

            params=params,

            headers=headers

        )


        print(
            "상태:",
            response.status_code
        )


        data = response.json()


        products = (

            data.get(

                "products",

                []

            )

        )


        print(
            "추가 수집:",
            len(products)
        )


        return products



    #################################
    # 전체
    #################################

    def search(

            self,

            keyword

    ):


        all_products=[]

        seen_ids=set()



        print(
            "\n================="
        )

        print(
            "[검색 시작]"
        )

        print(
            "브랜드:",
            keyword
        )


        #################################
        # 1.
        # search.json
        #################################

        first_products = (

            self.search_first_page(
                keyword
            )

        )


        for p in first_products:


            pid = p["id"]


            if pid not in seen_ids:


                seen_ids.add(
                    pid
                )


                all_products.append(
                    p
                )


        print(
            "\n현재 누적:",
            len(all_products)
        )



        #################################
        # 2.
        # gateway
        #################################

        page = 1


        while True:


            products = (

                self.search_more(

                    keyword,

                    page

                )

            )


            before = len(
                all_products
            )


            for p in products:


                pid = p["id"]


                if pid not in seen_ids:


                    seen_ids.add(
                        pid
                    )


                    all_products.append(
                        p
                    )


            added = (

                len(all_products)

                -

                before

            )


            print(

                "신규:",

                added
            )


            print(

                "누적:",

                len(all_products)
            )



            #################################
            # 종료
            #################################

            if added == 0:


                print(
                    "\n종료"
                )

                break


            page += 1



        print(
            "\n===== 완료 ====="
        )

        print(
            "총:",

            len(all_products)
        )


        return all_products