/// Các loại hiệu ứng chuyển trang khả dụng cho `TransformerPage`.
///
/// Mỗi giá trị tương ứng 1:1 với một class `PageTransformer` trong
/// `transformers/`. Dùng [transformerFor] để lấy instance:
/// ```dart
/// final t = transformerFor(TransformerType.cubeOut);
/// ```
enum TransformerType {
  /// Co giãn như đàn accordion — scale dựa trên position âm/dương.
  accordion,

  /// Xoay 3D quanh trục Y, pivot theo chiều rộng trang.
  threeD,

  /// Kết hợp scale + opacity, mượt và tinh tế.
  scaleAndFade,

  /// Phóng to trang mới khi tiến vào vùng hiển thị.
  zoomIn,

  /// Thu nhỏ + làm mờ trang cũ khi rời tâm.
  zoomOut,

  /// Trang xếp chồng có chiều sâu, dùng `reverse: true`.
  depth,

  /// Lật mặt trong khối lập phương (90° quanh Y).
  cubeIn,

  /// Lật mặt ngoài khối lập phương — phong cách rubik kinh điển.
  cubeOut,

  /// Lật thẻ 180° quanh trục Y (ngang).
  flipHorizontal,

  /// Lật thẻ 180° quanh trục X (dọc, kiểu lịch).
  flipVertical,

  /// Parallax — nội dung dịch chậm hơn page.
  parallax,

  /// Xoay nghiêng xuống, pivot ở cạnh dưới.
  rotateDown,

  /// Xoay nghiêng lên, pivot ở cạnh trên.
  rotateUp,

  /// Trang cũ đứng yên, trang mới trượt đè.
  stack,

  /// Lật nhẹ kiểu tablet (xoay Y góc nhỏ).
  tablet,

  /// Thấu kính lồi — cong ra phía người dùng.
  convex,

  /// Thấu kính lõm — cong vào trong.
  concave,

  /// Phong cách CoverFlow của Apple — nghiêng + scale + dịch.
  coverFlow,

  /// Bay xuyên đường hầm — scale cực mạnh + opacity.
  tunnel,

  /// Xoay tròn như đĩa nhạc.
  spin,

  /// Trượt + cắt (wipe).
  wipe,

  /// Rèm sân khấu tách đôi hai bên.
  curtain,

  /// Lật trang sách quanh cạnh trái.
  bookFlip,

  /// Bung kiểu quạt giấy, pivot ở góc dưới.
  fan,

  /// Xoay + nảy — năng động, phá cách.
  scaleRotate,
}
