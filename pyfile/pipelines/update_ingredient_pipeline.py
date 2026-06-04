import os
import sys
import pandas as pd
from services.ocr_reader import OCRReader
from services.ingredient_extractor import IngredientExtractor


class UpdateIngredientPipeline:

    def run(self, limit=None):
        # Windows 콘솔에서 한글이 깨지는 것을 방지하기 위해 stdout 인코딩을 UTF-8로 설정
        if sys.platform == "win32":
            try:
                sys.stdout.reconfigure(encoding="utf-8")
            except Exception:
                pass

        csv_path = "result/ingredients.csv"
        filter_dir = "filter_img"

        if not os.path.exists(csv_path):
            print(f"CSV 파일을 찾을 수 없습니다: {csv_path}", flush=True)
            return

        df = pd.read_csv(csv_path, encoding="utf-8-sig")
        reader = OCRReader()
        extractor = IngredientExtractor()

        # 전체 데이터 상태 요약 출력
        print("=== CSV 데이터 요약 ===", flush=True)
        if "ingredient_state" in df.columns:
            print(df["ingredient_state"].value_counts(), flush=True)
        else:
            print("ingredient_state 컬럼이 존재하지 않습니다!", flush=True)
            return

        # 업데이트 대상: '이미지' 열에 값이 있는 모든 제품
        target_mask = df["이미지"].notna() & (df["이미지"].astype(str).str.strip() != "")
        target_indices = df[target_mask].index

        print(f"\n[대상 추출 완료] 총 {len(target_indices)}개의 대상 제품을 발견했습니다.", flush=True)

        count = 0
        updated_count = 0

        for idx in target_indices:
            if limit and count >= limit:
                break

            product_name = str(df.loc[idx, "제품명"])
            current_ingredients = str(df.loc[idx, "주요성분"]).strip() if pd.notna(df.loc[idx, "주요성분"]) else ""

            # 파일명 정리 (특수문자 제거)
            safe_name = product_name.replace("/", "").replace("\\", "").replace(":", "").replace("*", "").replace("?",
                                                                                                                  "").replace(
                "\"", "").replace("<", "").replace(">", "").replace("|", "")
            img_filename = f"{safe_name}_ingredient.jpg"
            img_path = os.path.join(filter_dir, img_filename)

            # 정확한 제품명 기반 매칭도 시도
            if not os.path.exists(img_path):
                img_path = os.path.join(filter_dir, f"{product_name}_ingredient.jpg")

            print(f"\n[{count + 1}/{limit if limit else len(target_indices)}] 제품명: {product_name}", flush=True)

            needs_ocr = True

            # 기존 주요성분이 있다면 정제(refine) 시도
            if current_ingredients and current_ingredients.lower() not in ["nan", "none"]:
                cleaned_existing = extractor.extract(current_ingredients)
                # 추출된 성분이 3개 이상이면(쉼표 기준) 정상 데이터로 간주
                if cleaned_existing and len(cleaned_existing.split(",")) >= 3:
                    df.loc[idx, "주요성분"] = cleaned_existing
                    df.loc[idx, "ingredient_state"] = "refined_existing"
                    updated_count += 1
                    needs_ocr = False
                    print("  -> [기존 데이터 정제 성공] 이미지 OCR을 생략하고 텍스트를 정제했습니다.", flush=True)
                    print(f"     정제 결과: {cleaned_existing[:150]}...", flush=True)
                else:
                    print("  -> [기존 데이터 부실/비정상] OCR 추출로 덮어씁니다.", flush=True)

            if needs_ocr:
                if os.path.exists(img_path):
                    print(f"  -> [이미지 발견] {img_path}", flush=True)

                    try:
                        # OCR 수행
                        raw_text = reader.read(img_path)

                        if raw_text:
                            # 텍스트 정제하여 전성분만 추출
                            cleaned_ingredients = extractor.extract(raw_text)

                            if cleaned_ingredients:
                                df.loc[idx, "주요성분"] = cleaned_ingredients
                                df.loc[idx, "ingredient_state"] = "ocr_completed"
                                updated_count += 1

                                print("  -> [성공] 전성분 추출 완료!", flush=True)
                                print(f"     추출 결과: {cleaned_ingredients[:150]}...", flush=True)
                            else:
                                print("  -> [실패] 텍스트를 추출했으나 전성분 내용이 비어있습니다.", flush=True)
                        else:
                            print("  -> [실패] OCR 텍스트를 읽지 못했습니다.", flush=True)

                    except Exception as e:
                        print(f"  -> [에러] OCR 처리 중 오류 발생: {e}", flush=True)
                else:
                    print(f"  -> [이미지 없음] {img_path}", flush=True)

            count += 1

        out_csv_path = "result/ingredients_filter.csv"

        if updated_count > 0 or len(target_indices) > 0:
            print(f"\n[완료] 총 {updated_count}개의 제품 전성분을 업데이트했습니다. {out_csv_path}로 저장합니다...", flush=True)
            df.to_csv(out_csv_path, index=False, encoding="utf-8-sig")
            print("저장 완료!", flush=True)
        else:
            print(f"\n[완료] 처리할 대상이 없습니다. {out_csv_path}로 원본을 복사하여 저장합니다...", flush=True)
            df.to_csv(out_csv_path, index=False, encoding="utf-8-sig")
