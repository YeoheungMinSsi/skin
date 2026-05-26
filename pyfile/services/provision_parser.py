from bs4 import BeautifulSoup


class ProvisionParser:


    def parse(

            self,

            html

    ):


        ##################################
        # 제공고시 없음
        ##################################

        if html is None:


            return {

                "상태":

                    "제공고시없음"

            }


        soup = BeautifulSoup(

            html,

            "html.parser"

        )


        result = {}


        ##################################
        # 항목명
        ##################################

        titles = (

            soup.select(

                "dt"

            )

        )


        ##################################
        # 값
        ##################################

        values = (

            soup.select(

                "dd"

            )

        )


        ##################################
        # 모든 항목 저장
        ##################################

        for t,v in zip(

                titles,

                values

        ):


            key = (

                t.get_text(
                    strip=True
                )

            )


            value = (

                v.get_text(
                    strip=True
                )

            )


            result[key] = value


        ##################################
        # 주요성분 없음
        ##################################

        if (

                "주요성분"

                not in result

        ):


            result["상태"]=(

                "성분없음"

            )


            return result


        ingredient=(

            result["주요성분"]

        )


        ##################################
        # 이미지 필요
        ##################################

        if (

                "상품상세참조"

                in ingredient

        ):


            result["상태"]=(

                "이미지필요"

            )


            return result


        ##################################
        # 텍스트 성분 존재
        ##################################

        result["상태"]=(

            "성분텍스트"

        )


        return result