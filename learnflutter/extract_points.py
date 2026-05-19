import json
import random

with open('./assets/json/boudery_hcm.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

for item in data['data']['data']:
    for k, v in item.items():
        if isinstance(v, str):
            if 'tân thuận' in v.lower() or 'tân thuận' in v.lower():
                latlng_str = item.get('latlng', '')
                parts = [p.strip().replace('(', '').replace(')', '') for p in latlng_str.split(';') if p.strip()]
                
                dart_code = []
                for part in parts:
                    if ',' not in part:
                        continue
                    lat, lng = part.split(',')
                    weight = random.randint(1, 5)
                    dart_code.append(f"      WeightedLatLng(LatLng({lat.strip()}, {lng.strip()}), weight: {weight}),")
                
                print("Found {} points for Tân Thuận".format(len(dart_code)))
                
                with open('tan_thuan_points.txt', 'w') as out:
                    out.write("\n".join(dart_code))
                
                import sys
                sys.exit(0)
