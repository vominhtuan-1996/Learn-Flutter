# Pagination System Component

Hệ thống phân trang cao cấp được thiết kế để xử lý các danh sách dữ liệu lớn với hiệu ứng mượt mà (TikTok-style) và tối ưu hiệu năng.

## 📁 Cấu trúc thư mục
- `pagination_controller.dart`: Quản lý trạng thái, dữ liệu và logic tự động load thêm.
- `pagination_scaffold.dart`: Widget khung chia layout thành Header, Content (PageView) và Footer.
- `pagination_layout.dart`: Thư viện các hiệu ứng hoạt họa cao cấp (3D Cube, Depth, Stack, ZoomRotate, v.v.).
- `pagination_page.dart`: Widget bao bọc hỗ trợ phát hiện hiển thị (Visibility Detection).

## 🚀 Cách sử dụng cơ bản

### 1. Khởi tạo Controller
```dart
final _controller = PaginationController<MyData>(
  onLoad: (page) async {
    // Gọi API của bạn tại đây
    return await apiService.getData(page: page);
  },
);
```

### 2. Sử dụng BasePaginationScaffold
```dart
BasePaginationScaffold<MyData>(
  controller: _controller,
  headerBuilder: (context, index) => MyHeader(index: index),
  contentBuilder: (context, item, index) => MyContent(item: item),
  footerBuilder: (context, index) => MyFooter(index: index),
)
```

## ✨ Hiệu ứng nâng cao (Advanced Scroll Engine)
Hệ thống cung cấp sẵn các "Engine" hoạt họa trong `PaginationLayout`:

1. **`cube3D`**: Hiệu ứng khối lập phương xoay (Phù hợp cho cuộn ngang).
2. **`depthEffect`**: Hiệu ứng chiều sâu, trang cũ thu nhỏ và mờ dần.
3. **`stackEffect`**: Hiệu ứng xếp chồng, trang mới trượt đè lên trang cũ.
4. **`zoomRotate`**: Kết hợp thu phóng và xoay góc.
5. **`parallaxItem`**: Hiệu ứng di chuyển lệch pha.
6. **`wheel`**: Hiệu ứng vòng quay hình trụ (Cylindrical wheel).
7. **`flip`**: Hiệu ứng lật thẻ 3D (3D Card Flip).
8. **`skew`**: Hiệu ứng nghiêng phối cảnh (Perspective Skew).
9. **`coverFlow`**: Phong cách Apple Cover Flow cổ điển.
10. **`accordion`**: Hiệu ứng gấp nếp như đàn phong cầm.
11. **`door3D`**: Hiệu ứng cánh cửa xoay 3D (Door transition).
12. **`perspectiveVertical`**: Hiệu ứng nghiêng dọc trên trục ngang.
13. **`fan3D`**: Hiệu ứng xòe quạt 3D từ cạnh dưới.
14. **`tunnel3D`**: Hiệu ứng di chuyển trong đường hầm 3D.
15. **`animatedItem`**: Hiệu ứng Scale & Opacity cơ bản.

### Ví dụ triển khai:
```dart
contentBuilder: (context, item, index) {
  return AnimatedBuilder(
    animation: _controller.pageController,
    builder: (context, child) {
      double offset = 0;
      if (_controller.pageController.hasClients) {
        offset = (_controller.pageController.page ?? 0) - index;
      }
      return PaginationLayout.cube3D( // Sử dụng Engine mong muốn
        offset: offset,
        child: MyFeedItem(item: item),
      );
    },
  );
}
```

## 🛠 Quy tắc bảo trì
1. **Zero Rebuild**: Luôn sử dụng `AnimatedBuilder` với `pageController` để chỉ rebuild phần cần thiết khi cuộn.
2. **Preloading**: Mặc định hệ thống load trước 2 item cuối. Có thể chỉnh sửa trong `_onScroll` của controller.
3. **Memory Management**: Luôn gọi `controller.dispose()` khi widget bị hủy.
