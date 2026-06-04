import re


class ImageFilter:

    def score(self, text):

        text = str(
            text
        ).lower()

        score = 0


        keywords = [
            "전성분",
            "ingredient",
            "ingredients",
            "성분",
            "원료"
        ]

        for k in keywords:
            if k in text:
                score += 20


        ing = [
            "정제수",
            "글리세린",
            "부틸렌글라이콜",
            "추출물",
            "향료"
        ]

        for k in ing:
            if k in text:
                score += 10


        score += text.count(",")

        score += text.count(";")



        found = re.findall(
            r"[가-힣]+추출물",
            text
        )

        score += len(found) * 5


        ads = [
            "how to use",
            "피부",
            "저자극",
            "효과",
            "추천"
        ]

        for a in ads:
            if a in text:
                score -= 5


        return score