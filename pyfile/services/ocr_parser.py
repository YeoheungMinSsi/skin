import re


class OCRParser:


    def parse(

            self,

            text

    ):


        pattern = (

            r"(전성분.*)"

        )


        m = (

            re.search(

                pattern,

                text,

                re.S

            )

        )


        if m:


            return (

                m.group(

                    1

                )

            )


        return text