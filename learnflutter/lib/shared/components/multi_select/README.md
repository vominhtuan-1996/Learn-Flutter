# MultiSelect Component Suite

Tài liệu này hướng dẫn chi tiết cách sử dụng các component thuộc nhóm MultiSelect nằm trong thư mục `lib/shared/components/multi_select`. Nhóm này cung cấp các giải pháp chọn một/nhiều item với đầy đủ tính năng mở rộng như tìm kiếm, phân trang (Load More), và xử lý vượt mức giới hạn.

## 1. MultiSelector (`multi_selector.dart`)

`MultiSelector<T>` là Widget tĩnh cơ bản nhất. Nó sẽ render danh sách các item dưới dạng danh sách tĩnh (thường là list với checkbox/radio) trực tiếp trên giao diện màn hình hoặc bên trong dialog tùy chỉnh của bạn.

### Các thuộc tính chính:
- `items` (`List<T>`): Danh sách tất cả các options để người dùng chọn.
- `initialSelectedItems` (`List<T>`): Danh sách các options đã được chọn từ trước (thường truyền data từ API vào đây).
- `selectLength` (`int`): Giới hạn số lượng được chọn. Ví dụ bằng `1` thì giống RadioButton (chỉ chọn 1), `>1` thì là MultiSelect.
- `type` (`MultiSelectorType`): Hành vi xử lý khi người dùng chọn lố số lượng cho phép (`selectLength`). Gồm:
  - `limit`: Khóa không cho chọn thêm, phải bỏ chọn mục cũ mới được chọn mục mới.
  - `replace`: Đẩy (xóa) phần tử được chọn cũ nhất ra khỏi danh sách, nhường chỗ cho phần tử mới.
  - `unLimit`: Chọn không giới hạn, phớt lờ thuộc tính `selectLength`.
- `onSelectItem` (`ValueChanged<List<T>>`): Callback được gọi mỗi khi người dùng tick/untick một item.

### Ví dụ sử dụng cơ bản:

```dart
MultiSelector<UserModel>(
  items: userList,
  initialSelectedItems: const [],
  selectLength: 3,
  type: MultiSelectorType.limit, // Khóa khi chọn đủ 3 người
  itemBuilder: (item, isSelected) {
    return ListTile(
      title: Text(item.name),
      trailing: isSelected ? const Icon(Icons.check_box) : const Icon(Icons.check_box_outline_blank),
    );
  },
  onSelectItem: (List<UserModel> currentSelection) {
    print("Bạn đã chọn: \${currentSelection.length} người.");
  },
);
```

---

## 2. Selector (`selector.dart`)

`Selector<T>` là phiên bản đóng gói nâng cao, bao gồm cả một Box giao diện cố định và thanh tìm kiếm (Search Bar) bên trong. Dữ liệu của `Selector` cũng là dạng cố định (`items`).

### Các thuộc tính chính:
- Tất cả thuộc tính của `MultiSelector` (`itemBuilder`, `selectLength`, `selectorType`...)
- `hasSearchBar` (`bool`): Có hiển thị ô nhập từ khóa tìm kiếm hay không.
- `hint` (`String`): Chữ mờ placeholder cho thanh tìm kiếm.

### Ví dụ sử dụng:

```dart
Selector<CategoryModel>(
  title: 'Danh mục sản phẩm',
  hasSearchBar: true,
  hint: 'Nhập tên danh mục...',
  items: allCategories, // Danh sách cố định
  selectedItems: selectedCategories,
  selectLength: 1,
  itemBuilder: (item, isSelected) {
    return AppText(item.title, color: isSelected ? Colors.blue : Colors.black);
  },
  onChanged: (values) {
    // values chứa danh sách items đang được chọn
  },
);
```

---

## 3. LoadMoreSelector (`load_more_selector.dart`)

`LoadMoreSelector<T>` kế thừa `Selector`, nhưng sức mạnh lớn nhất là nó hỗ trợ gọi API phân trang (Pagination) và hiển thị biểu tượng loading một cách tự động (tích hợp LoadMoreCubit).

Nó thích hợp cho các danh sách lớn hàng ngàn phần tử (VD: Tìm kiếm người dùng, sản phẩm từ Server).

### Các thuộc tính chính:
- `getItemsFunction`: Một hàm bất đồng bộ trả về `LoadMoreModel<T>`, nhận đầu vào gồm `pageSize`, `pageNumber`, và `keyword` (nếu người dùng gõ tìm kiếm).
- `pageSize` (`int`): Số lượng phần tử mỗi trang (mặc định 10).
- `preAnalyzeSearch`: Hàm tiền xử lý trước khi thực hiện tìm kiếm. Dùng để cấu hình debounce (hoãn thời gian gọi API) hoặc chặn tìm kiếm khi chuỗi quá ngắn.

### Ví dụ sử dụng nâng cao:

```dart
LoadMoreSelector<ProductModel>(
  title: 'Sản phẩm',
  hasSearchBar: true,
  hint: 'Tìm theo mã hoặc tên...',
  selectedItems: myCart,
  selectLength: 10,
  pageSize: 20, // Load 20 phần tử mỗi lần
  
  // Hàm xử lý debounce hoặc chặn call API nếu gõ chưa đủ 3 ký tự
  preAnalyzeSearch: (searchFunction, keyword) {
    if (keyword.isEmpty) {
      debounce.runAfter(action: searchFunction, rate: 500);
      return;
    }
    if (keyword.length < 3) return; // Không gọi API nếu < 3 ký tự
    debounce.runAfter(action: searchFunction, rate: 500);
  },
  
  // Cung cấp dữ liệu từ API
  getItemsFunction: (pageSize, pageNumber, keyword) async {
    return await apiProvider.getProducts(
      page: pageNumber,
      limit: pageSize,
      search: keyword,
    );
  },
  
  // Cung cấp giao diện từng dòng
  itemBuilder: (item, isSelected) {
    return ListTile(
      title: Text(item.productName),
      subtitle: Text('Giá: \${item.price}'),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
    );
  },
  
  onItemTap: (selectedList) {
    // Được gọi khi item vừa bị nhấp chuột vào
  },
);
```

## Các Lưu Ý Khi Triển Khai
1. **Generic Type (`<T>`)**: Mọi model truyền vào bắt buộc phải là dạng class kế thừa từ `OptionModel` HOẶC bạn phải tự `override operator ==` và `hashCode` trong model của mình. Điều này giúp `LoadMoreCubit` so sánh đúng trạng thái đã chọn khi danh sách load trang mới.
2. Nhanh chóng tích hợp vào Dialog/BottomSheet: Thay vì tự viết BottomSheet từ đầu, bạn có thể tham khảo dùng `ShowSelector` (tại `shared/components/show_selector_widget/show_selector.dart`) là Widget đã bọc sẵn `LoadMoreSelector` bên trong Bottom Sheet chuẩn của dự án.
