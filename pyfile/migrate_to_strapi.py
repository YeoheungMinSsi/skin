import csv
import requests
import time
import os

# Strapi API Configuration
STRAPI_API_URL = "http://localhost:1337/api/cosmetics"

# Path to the finalized CSV file
CSV_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "result", "result.csv"))

def classify_product(product_name):
    name = str(product_name).lower()
    
    # 1. 립밤 / 립케어
    if any(k in name for k in ['립밤', '립케어', '립에센스', '립오일', '글로이 밤', '멜팅 립', 'lip balm', 'lip care']):
        return '립케어'
    # 2. 마스크 / 팩 / 패드
    if any(k in name for k in ['마스크', '팩', '패드', '마스크팩', '시트', '패치', 'mask', 'pack', 'pad']):
        return '마스크/팩'
    # 3. 클렌징
    if any(k in name for k in ['클렌징', '클렌저', '폼', '필링', '스크럽', 'cleansing', 'cleanser', 'foam', '워시']):
        return '클렌징'
    # 4. 선케어
    if any(k in name for k in ['선크림', '선블록', '선스틱', '선에센스', '선로션', '선겔', 'sunscreen', 'sunblock', 'sun']):
        return '선케어'
    # 5. 로션 / 에멀젼
    if any(k in name for k in ['로션', '에멀젼', '에멀전', 'lotion', 'emulsion']):
        return '로션/에멀젼'
    # 6. 스킨 / 토너
    if any(k in name for k in ['스킨', '토너', '토닉', '스킨부스터', '워터 에센스', 'skin', 'toner', 'tonic']):
        return '스킨/토너'
    # 7. 에센스 / 세럼 / 앰플
    if any(k in name for k in ['에센스', '세럼', '앰플', '부스터', '오일', 'essence', 'serum', 'ampoule', 'oil']):
        return '에센스/세럼/앰플'
    # 8. 크림
    if any(k in name for k in ['크림', '밤', '수딩젤', '젤', '크림미스트', 'cream', 'balm', 'gel']):
        return '크림'
        
    return '기타'

def migrate_data():
    if not os.path.exists(CSV_PATH):
        print(f"CSV file not found at: {CSV_PATH}")
        return

    print(f"Reading CSV from: {CSV_PATH}")
    success_count = 0
    fail_count = 0

    with open(CSV_PATH, mode='r', encoding='utf-8-sig') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        
        # We read all rows to process
        rows = list(csv_reader)
        total_rows = len(rows)
        print(f"Found {total_rows} rows. Starting migration to Strapi ({STRAPI_API_URL})...")

        for index, row in enumerate(rows):
            brand = row.get('브랜드', '').strip()
            name = row.get('제품명', '').strip()
            ingredients_raw = row.get('주요성분', '').strip()
            goods_id_str = row.get('goods_id', '').strip()
            
            # Skip rows with no product name
            if not name:
                continue

            # Handle ingredients string parsing to list (comma separated or semicolon separated)
            # Typically separated by comma or semicolon
            ingredients_list = []
            if ingredients_raw:
                # split by semicolon or comma
                delimiters = [';', ',']
                temp_list = [ingredients_raw]
                for delimiter in delimiters:
                    new_temp = []
                    for item in temp_list:
                        new_temp.extend(item.split(delimiter))
                    temp_list = new_temp
                ingredients_list = [ing.strip() for ing in temp_list if ing.strip()]

            # Goods ID as integer
            goods_id = None
            if goods_id_str:
                try:
                    goods_id = int(float(goods_id_str))
                except ValueError:
                    pass

            category = classify_product(name)

            # Strapi V4 Request Body Structure
            payload = {
                "data": {
                    "brand": brand,
                    "name": name,
                    "ingredients": ingredients_list, # Strapi JSON type or Text type
                    "category": category,
                    "goodsId": goods_id
                }
            }

            try:
                response = requests.post(STRAPI_API_URL, json=payload, headers={"Content-Type": "application/json"})
                if response.status_code in [200, 201]:
                    success_count += 1
                    print(f"[{index + 1}/{total_rows}] Successfully uploaded: {brand} - {name}")
                else:
                    fail_count += 1
                    print(f"[{index + 1}/{total_rows}] Failed to upload {name}. Status code: {response.status_code}. Response: {response.text}")
            except Exception as e:
                fail_count += 1
                print(f"[{index + 1}/{total_rows}] Error sending request for {name}: {e}")
            
            # Simple rate limiting to prevent overwhelming local server
            time.sleep(0.05)

    print(f"\nMigration finished!")
    print(f"Total Rows: {total_rows}")
    print(f"Success: {success_count}")
    print(f"Failed: {fail_count}")

if __name__ == "__main__":
    # If Strapi auth is required, you can add Authorization headers here.
    # By default, if the POST /api/cosmetics endpoint is open to 'Public' role, no token is needed.
    migrate_data()
