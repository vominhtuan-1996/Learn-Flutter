import json

with open('./assets/json/boudery_hcm.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

for item in data['data']['data']:
    name = item.get('areaName', '') or item.get('name', '') or str(item)
    if 'tân thuận' in name.lower() or 'tan thuan' in name.lower():
        print("Found:", name)
        coords = item.get('latlng', '')
        print("Points count:", len(coords.split(';')))
        # print first 5 points
        print("Sample points:", coords.split(';')[:5])
        break
else:
    print("Not found in normal name fields. Searching all...")
    for item in data['data']['data']:
        if 'tân thuận' in str(item).lower():
            print("Found in item keys:", item.keys())
            print("Name field might be:", [(k, v) for k,v in item.items() if isinstance(v, str) and 'tân thuận' in v.lower()])
            break
