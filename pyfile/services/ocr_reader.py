import easyocr
import glob
import os
import numpy as np

from PIL import Image


class OCRReader:

    def __init__(self):
        self.reader = easyocr.Reader(
            ["ko", "en"]
        )

    ##################################
    # 실제 파일 찾기
    ##################################

    def find_image(self, image_path):

        filename = os.path.basename(
            image_path
        )

        files = glob.glob(
            f"**/{filename}",
            recursive=True
        )

        if files:
            return os.path.abspath(
                files[0]
            )

        return None


    ##################################
    # OCR
    ##################################

    def read(self, image_path):

        real = self.find_image(
            image_path
        )

        if real is None:
            return ""

        if not os.path.exists(real):
            return ""

        size = os.path.getsize(real)

        print(
            "\nOCR:",
            real
        )

        print(
            "크기:",
            size
        )

        if size < 5000:
            print(
                "건너뜀"
            )
            return ""

        try:

            img = Image.open(
                real
            )

            img = img.convert(
                "RGB"
            )

            img = np.array(
                img
            )

            result = self.reader.readtext(
                img,
                detail=0
            )

            text = "\n".join(
                result
            )

            print(
                text[:200]
            )

            return text

        except Exception as e:

            print(
                "OCR 실패:",
                e
            )

            return ""