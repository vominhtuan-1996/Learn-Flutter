import pandas as pd

file_path = '/Users/tuanios_su12/learn_flutter/learnflutter/379201_CheckinLocation_16072026151309959.xlsx'
df = pd.read_excel(file_path)

# Lấy dữ liệu cột 'Địa chỉ' và bỏ 3 ký tự đầu
df['Địa chỉ mới'] = df['Địa chỉ'].astype(str).apply(lambda x: x[3:].strip() if len(x) > 3 else x)

# Chỉ lưu cột địa chỉ nếu cần hoặc lưu toàn bộ, ở đây sẽ xuất ra một file mới chỉ gồm cột địa chỉ.
output_df = df[['Địa chỉ mới']]

output_path = '/Users/tuanios_su12/learn_flutter/learnflutter/Extracted_Address.xlsx'
output_df.to_excel(output_path, index=False)
print("Saved to", output_path)
