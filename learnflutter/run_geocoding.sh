#!/bin/bash

cd /Users/tuanios_su12/learn_flutter/learnflutter

# Kích hoạt virtual environment đã tạo ở bước trước
source .venv/bin/activate

# Cài đặt thư viện requests nếu chưa có
pip install requests pandas openpyxl

# Chạy script python để gọi API và cập nhật file Excel
python3 fetch_lat_lng.py
