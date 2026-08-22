import pandas as pd
import requests
import time

file_path = '/Users/tuanios_su12/learn_flutter/learnflutter/location_address_catalog.csv'
df = pd.read_csv(file_path)

api_key = 'pk.46df609a2693074d755d10cec72bb399'
url_template = "https://us1.locationiq.com/v1/search?key={}&q={}&format=json"

lats = []
lngs = []

print(f"Bắt đầu lấy tọa độ cho {len(df)} địa chỉ...")

for index, row in df.iterrows():
    address = row['name']
    if pd.isna(address) or str(address).strip() == "":
        lats.append("")
        lngs.append("")
        continue
    
    url = url_template.format(api_key, address)
    try:
        response = requests.get(url)
        if response.status_code == 200:
            data = response.json()
            if len(data) > 0:
                lats.append(data[0].get('lat', ''))
                lngs.append(data[0].get('lon', ''))
                print(f"[{index+1}/{len(df)}] Thành công: {address} -> lat: {data[0].get('lat')}, lng: {data[0].get('lon')}")
            else:
                lats.append("")
                lngs.append("")
                print(f"[{index+1}/{len(df)}] Không tìm thấy tọa độ cho: {address}")
        elif response.status_code == 429:
            print(f"[{index+1}/{len(df)}] Rate limit exceeded. Chờ 5s...")
            time.sleep(5)
            # Thử lại 1 lần
            response = requests.get(url)
            if response.status_code == 200:
                data = response.json()
                if len(data) > 0:
                    lats.append(data[0].get('lat', ''))
                    lngs.append(data[0].get('lon', ''))
                    print(f"[{index+1}/{len(df)}] Thành công (sau khi thử lại): {address}")
                else:
                    lats.append("")
                    lngs.append("")
            else:
                lats.append("")
                lngs.append("")
        else:
            print(f"[{index+1}/{len(df)}] Lỗi {response.status_code} cho địa chỉ: {address}")
            lats.append("")
            lngs.append("")
    except Exception as e:
        print(f"[{index+1}/{len(df)}] Exception cho địa chỉ {address}: {e}")
        lats.append("")
        lngs.append("")
    
    # LocationIQ giới hạn số request/giây đối với bản free, nên cần sleep 1s
    time.sleep(1)

df['lat'] = lats
df['lng'] = lngs

df.to_csv(file_path, index=False)
print("Hoàn tất! Đã cập nhật file CSV với cột lat và lng.")
