import os
import easyocr
import re

filter_dir = 'filter_img'
files = [f for f in os.listdir(filter_dir) if f.endswith('.jpg')]

reader = easyocr.Reader(['ko', 'en'])

def extract_ingredients(raw_text):
    text = '\n'.join(raw_text)
    
    # 1. '전성분' 키워드 추출 시도 (주의사항 전까지)
    match = re.search(r'(전\s*성\s*분|성\s*분|Ingredients?)\s*[:：]?\s*(.*)', text, re.IGNORECASE | re.DOTALL)
    if match:
        text = match.group(2)
        
    end_match = re.search(r'(사용\s*시\s*의?\s*주의\s*사항|주의\s*사항|사용\s*방법|How to use|용법\s*용량|효능\s*효과)', text, re.IGNORECASE)
    if end_match:
        text = text[:end_match.start()]

    # 2. 줄바꿈을 공백으로 합치고 콤마나 마침표로 분리
    text = text.replace('\n', ' ')
    raw_tokens = re.split(r'[,\.]+', text)
    
    cleaned = []
    for t in raw_tokens:
        t = t.strip()
        # 겉의 특수문자 제거
        t = re.sub(r'^[\'\"\-\+\*\@\:\;\·]+|[\'\"\-\+\*\@\:\;\·]+$', '', t).strip()
        if not t or len(t) < 2:
            continue
        
        # 띄어쓰기가 3개 이상이면 문장으로 간주하고 버림 (성분명은 보통 띄어쓰기가 없거나 1개)
        if len(t.split()) > 3:
            continue
            
        # 너무 긴 단어는 버림
        if len(t) > 20:
            continue
            
        cleaned.append(t)
        
    # 3. 핵심 검증: 추출된 리스트가 진짜 전성분 데이터인지 확인
    joined_text = ', '.join(cleaned)
    
    # 화장품 전성분에 거의 무조건 포함되는 단어들
    core_ingredients = ['정제수', '글리세린', '추출물', '글라이콜', '헥산다이올', '나이아신아마이드', '오일', '애씨드', '알코올', '판테놀', '세라마이드', '워터', '소듐', '디메치콘', '다이메티콘', '폴리머']
    
    has_core = any(core in joined_text for core in core_ingredients)
    comma_count = joined_text.count(',')
    
    # 성분 키워드가 있거나, 쉼표가 5개 이상 빽빽하게 있다면 실제 성분 리스트로 인정!
    if has_core or comma_count >= 5:
        final_list = []
        for c in cleaned:
            # 추가적인 잡음(마케팅, 주의사항 관련 단어) 필터링
            if re.search(r'(원한다면|선사|테스트|완료|기능성|화장품|상담실|이상이|공정거래|분쟁|보상해|사용방법|용량|효과|토너로|마스크|약\s*\d+분|떼어내고|맞추어|적당량|덜어|골고루|펴\s*바릅|사용|눈|주위)', c):
                continue
            # 순수 영어나 숫자로만 이루어진 경우 (INCI명이 아닐 확률 높음) 버림
            if re.match(r'^[a-zA-Z0-9\s\(\)]+$', c):
                continue
            final_list.append(c)
            
        if final_list:
            return ", ".join(final_list)
            
    # 조건에 부합하지 않으면 빈 문자열 반환 (마케팅 문구만 있는 이미지 방어)
    return ""

print('--- 테스트 시작 ---')
test_files = [
    '워터멜론 마스크시트_ingredient.jpg', 
    '레스온스킨 레드니스 카밍 시카 밤_ingredient.jpg', 
    '유어 프라이머 네트_ingredient.jpg',
    '올리브 비타민 E 리얼 크림_ingredient.jpg'
]

for f in test_files:
    path = os.path.join(filter_dir, f)
    if os.path.exists(path):
        res = reader.readtext(path, detail=0)
        ext = extract_ingredients(res)
        print(f'\n▶ 파일명: {f}')
        print(f'   추출결과: {ext}')
        if not ext: print('   -> ❌ 전성분이 없거나 기준 미달로 버려짐 (성공적 방어)')
