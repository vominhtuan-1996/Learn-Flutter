# Hướng dẫn sử dụng MultiSelect & ShowSelector Component

Tài liệu này hướng dẫn cách sử dụng các component chọn dữ liệu (Select/MultiSelect) dùng chung trong dự án. Các component này hỗ trợ tính năng chọn nhiều/chọn một, tìm kiếm, phân trang (Load More) và tích hợp sẵn Bottom Sheet giao diện mới chuẩn `AppBottomSheetEngine`.

---

## 1. ShowSelector Component

`ShowSelector<T>` là widget đóng vai trò như một Dropdown/Select Field thực thụ. Khi nhấn vào, nó sẽ bật lên một Bottom Sheet chứa danh sách dữ liệu có thể tìm kiếm, phân trang (Load More) và xác nhận chọn.

**Vị trí:** `lib/shared/components/show_selector_widget/show_selector.dart`

### Đặc điểm nổi bật
- Mặc định hiển thị dưới dạng khung viền (có chữ, mũi tên chĩa xuống).
- Hỗ trợ gọi API lấy dữ liệu phân trang, tự động hiển thị `CircularProgressIndicator`.
- Hỗ trợ nhập Text tìm kiếm (kèm debounce và minTextLength).
- Tương thích 100% với cấu trúc Bottom Sheet mới của hệ thống.
- Cấu hình có Nút xác nhận hay tự động đóng sau khi chọn.

### Cách sử dụng cơ bản

```dart
ShowSelector<MyOptionModel>(
  title: 'Chọn danh mục',
  hint: 'Tìm kiếm danh mục...',
  selectedItems: selectedCategories, // Danh sách các item đang chọn ban đầu
  selectedLength: 1, // Số lượng tối đa được chọn (1 = Chọn đơn, >1 = Chọn nhiều)
  showSelectedConfirm: true, // true: Hiển thị nút "Xác nhận" để chốt, false: Tự đóng ngay sau khi chọn
  
  // Hàm tải dữ liệu (có hỗ trợ từ khóa tìm kiếm và phân trang)
  getListFunction: (pageSize, pageNumber, keyword) async {
    // Gọi API của bạn ở đây và trả về LoadMoreModel
    return await myRepository.getCategories(
      page: pageNumber,
      size: pageSize,
      search: keyword,
    );
  },
  
  // Lắng nghe sự kiện sau khi người dùng thay đổi dữ liệu
  onChanged: (List<MyOptionModel> newSelected) {
    setState(() {
      selectedCategories = newSelected;
    });
  },
  
  // (Optional) Ghi đè giao diện nút bấm bên ngoài (Dropdown input)
  displayBuilder: (enable, value) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Text(value.isEmpty ? 'Vui lòng chọn' : value.first.name),
    );
  },
  
  // (Optional) Ghi đè giao diện từng Item bên trong danh sách
  itemBuilder: (item, isSelected) {
    return ListTile(
      title: Text(item.name),
      trailing: isSelected ? Icon(Icons.check, color: Colors.blue) : null,
    );
  },
)
```

---

## 2. MultiSelector Component

`MultiSelector<T>` là Widget tĩnh (chỉ dùng render trên layout, không pop-up BottomSheet) cho phép tạo ra danh sách check box / radio đa năng.

**Vị trí:** `lib/shared/components/multi_select/multi_selector.dart`

### Cách sử dụng cơ bản

```dart
MultiSelector<MyOptionModel>(
  items: availableOptions, // Dữ liệu danh sách
  initialSelectedItems: selectedOptions, // Dữ liệu đang chọn
  selectLength: 2, // Giới hạn số lượng được phép chọn (ví dụ: tối đa 2 cái)
  type: MultiSelectorType.replace, // Chiến lược chọn khi vượt quá giới hạn
  
  // Lắng nghe sự kiện
  onSelectItem: (List<MyOptionModel> currentSelectedItems) {
    print('Người dùng đang chọn: \$currentSelectedItems');
  },
)
```

### Các chiến lược chọn (`MultiSelectorType`)
- **`MultiSelectorType.limit`**: Chọn đủ số lượng `selectLength` thì không cho phép tick thêm nữa (khóa các item chưa chọn). Muốn chọn mục khác phải bỏ tick mục cũ đi.
- **`MultiSelectorType.replace`**: Chọn đủ số lượng, nếu tiếp tục chọn mục mới, hệ thống tự động đẩy (xóa) mục cũ nhất ra khỏi danh sách và thay thế bằng mục mới.
- **`MultiSelectorType.unLimit`**: Chọn thoải mái không giới hạn (phớt lờ thuộc tính `selectLength`).

---

## 3. Selector Component & LoadMoreSelector

Hai thành phần lõi này thường được sử dụng bên trong các Bottom Sheet, Dialog, hoặc màn hình riêng biệt. Nếu bạn không muốn dùng giao diện Dropdown `ShowSelector` mà muốn tự xây dựng luồng UI của riêng mình, bạn có thể gọi trực tiếp chúng.

- **`Selector<T>`**: Phục vụ danh sách dữ liệu cố định có sẵn (`List<T> items`). Hỗ trợ thanh tìm kiếm nội bộ.
- **`LoadMoreSelector<T>`**: Kế thừa `Selector`, bổ sung tính năng tự động gọi hàm fetch data, phân trang.

```dart
LoadMoreSelector<MyOptionModel>(
  title: 'Danh sách Sản phẩm',
  hasSearchBar: true, // Bật thanh tìm kiếm
  selectedItems: selectedItems,
  selectLength: 5, // Chọn tối đa 5 sản phẩm
  getItemsFunction: (pageSize, pageNumber, keyword) async {
    return await api.getProducts(page: pageNumber, keyword: keyword);
  },
  onChanged: (value) {
    // Kích hoạt khi có thay đổi (Nếu không tự đóng Bottom Sheet)
  },
  onItemTap: (value) {
    // Được kích hoạt ngay khi một dòng bị bấm vào
  },
)
```

## Các Lưu Ý Chung Khi Implement 💡
1. **Kiểu dữ liệu generic (`<T>`)**: Các model (ví dụ: `MyOptionModel`) truyền vào các Component này cần phải extend từ lớp `OptionModel` hoặc ghi đè (override) toán tử `==` và hàm `hashCode` để thuật toán nhận diện trùng lặp/selected hoạt động chính xác.
2. **Kích thước BottomSheet**: Đối với `ShowSelector`, mặc định nó chiếm 60% chiều cao màn hình (`heightRatio: 0.6`). Có thể tùy chỉnh chỉ số này tùy khối lượng dữ liệu thực tế.
3. **Màu sắc giao diện**: Component mặc định tuân thủ hệ màu dự án thông qua `getThemeBloc(context).state.tokens.colors`. Không can thiệp mã màu cứng (hard code) trừ phi thật cần thiết để tương thích tốt với Dark/Light Mode.
