import json

with open('./assets/json/boudery_hcm.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

names = set()
for item in data['data']['data']:
    for k, v in item.items():
        if isinstance(v, str) and not v.startswith('('):
            names.add(v)

print(list(names)[:50])
