from bs4 import BeautifulSoup


class IngredientParser:


    def parse(

            self,

            html

    ):


        soup=(

            BeautifulSoup(

                html,

                "html.parser"

            )

        )


        result={}


        dt=soup.select("dt")
        dd=soup.select("dd")


        for k,v in zip(dt,dd):


            result[

                k.text.strip()

            ]=(

                v.text.strip()

            )


        print(

            "\n파싱:",

            len(result)

        )


        return result