# Shimmer — Hướng dẫn sử dụng

Module shimmer dùng để hiển thị **skeleton loading** trong khi đang tải dữ liệu, giúp UI cảm giác mượt và có phản hồi ngay cả khi mạng chậm.

📁 **Vị trí**: `lib/shared/components/shimmer/`

## Cấu trúc

```
shimmer/
├── shimmer_utils/
│   └── shimmer_utils.dart       # Gradient mặc định + SlidingGradientTransform
└── widget/
    ├── shimmer_widget.dart      # <Shimmer> root — quản lý AnimationController
    ├── shimmer_loading_widget.dart  # <ShimmerLoading> — paint gradient lên child
    ├── shimmer_box.dart         # ShimmerBox / ShimmerListTile / ShimmerCard
    └── base_shimmer_builder.dart    # BaseShimmerBuilder / BaseShimmerList
```

## Khi nào dùng widget nào?

| Tình huống | Widget khuyên dùng |
|---|---|
| Skeleton có layout **khác** UI thật (chỉ block hình + dòng) | `BaseShimmerBuilder` (truyền `shimmerContent` + `child`) |
| Skeleton trùng layout với UI thật, lười viết placeholder riêng | `BaseShimmerList` (chỉ truyền `child`) |
| Cần một block hình chữ nhật / tròn placeholder | `ShimmerBox.rect` / `.circle` |
| Skeleton dạng hàng "avatar + 2 dòng text" | `ShimmerListTile` |
| Skeleton dạng "ảnh + tiêu đề + mô tả" | `ShimmerCard` |

---

## 1. `BaseShimmerBuilder` — placeholder tách biệt khỏi UI thật

Dùng khi bạn muốn kiểm soát chính xác layout skeleton (thường khác UI thật vài chỗ).

```dart
import 'package:learnflutter/shared/components/shimmer/widget/base_shimmer_builder.dart';
import 'package:learnflutter/shared/components/shimmer/widget/shimmer_box.dart';

BaseShimmerBuilder(
  isLoading: _isLoading,
  shimmerContent: Column(
    children: const [
      ShimmerListTile(),
      ShimmerListTile(),
      ShimmerCard(),
    ],
  ),
  child: MyRealList(),  // hiển thị khi isLoading == false
);
```

**Props:**
- `isLoading` *(required)* — bật/tắt skeleton.
- `shimmerContent` *(required)* — widget placeholder khi loading.
- `child` *(required)* — UI thật.
- `gradient` *(optional)* — `LinearGradient` tuỳ chỉnh, mặc định `ShimmerUtils.shimmerGradient`.

---

## 2. `BaseShimmerList` — shimmer xuyên qua chính UI thật

Khi UI thật của bạn đã đẹp và bạn lười viết skeleton riêng, có thể wrap luôn:

```dart
BaseShimmerList(
  isLoading: _isLoading,
  child: ListView.builder(
    itemCount: 5,
    itemBuilder: (_, i) => ListTile(
      leading: CircleAvatar(child: Text('$i')),
      title: Text('Item $i'),
      subtitle: Text('Subtitle'),
    ),
  ),
);
```

Mọi pixel có màu của `child` sẽ được override bằng `baseColor` (mặc định `#E0E0E0`) và gradient shimmer chạy qua. Khi `isLoading == false` thì hiển thị child y nguyên.

**Props:**
- `isLoading`, `child` *(required)*
- `gradient` *(optional)* — gradient custom.
- `baseColor` *(default `0xFFE0E0E0`)* — màu nền của placeholder.

---

## 3. `ShimmerBox` — placeholder block đơn

```dart
// Hình chữ nhật bo góc 8
ShimmerBox.rect(width: 200, height: 14)

// Hình tròn (avatar)
ShimmerBox.circle(size: 48)

// Hình chữ nhật bo góc tuỳ chỉnh
ShimmerBox.rect(width: 120, height: 20, borderRadius: 12)
```

Tự ghép nhiều `ShimmerBox` để tạo layout phức tạp:

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: const [
    ShimmerBox.rect(width: double.infinity, height: 180, borderRadius: 12),
    SizedBox(height: 12),
    ShimmerBox.rect(width: double.infinity, height: 16),
    SizedBox(height: 8),
    ShimmerBox.rect(width: 140, height: 16),
  ],
);
```

> ⚠️ `ShimmerBox` **bắt buộc** phải nằm trong subtree của một `Shimmer` widget (qua `BaseShimmerBuilder`/`BaseShimmerList`), nếu không sẽ không có hiệu ứng.

---

## 4. `ShimmerListTile` — placeholder cho row dạng list item

```dart
ShimmerListTile()                          // avatar 48 + 2 dòng text
ShimmerListTile(lineCount: 3)              // 3 dòng text
ShimmerListTile(hasAvatar: false)          // chỉ 2 dòng, không avatar
ShimmerListTile(avatarSize: 64,            // tuỳ chỉnh chi tiết
                lineHeight: 16,
                lineSpacing: 10,
                secondLineWidthFactor: 0.5)
```

---

## 5. `ShimmerCard` — placeholder cho card có ảnh

```dart
ShimmerCard()                                // ảnh 16:9 + 2 dòng text
ShimmerCard(imageAspectRatio: 1)             // ảnh vuông
ShimmerCard(lineCount: 3, imageBorderRadius: 16)
```

---

## 6. Tuỳ chỉnh gradient

Mặc định module dùng gradient sáng (3 stop xám/trắng) ở `ShimmerUtils.shimmerGradient`. Truyền gradient riêng nếu muốn đổi tông:

```dart
BaseShimmerList(
  isLoading: _isLoading,
  gradient: const LinearGradient(
    colors: [Color(0xFF1F2937), Color(0xFF374151), Color(0xFF1F2937)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  child: MyDarkContent(),
);
```

---

## Recipe đầy đủ: gọi API + shimmer 2 giây

```dart
class _MyScreenState extends State<MyScreen> {
  bool _isLoading = true;
  List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    _articles = await api.fetchArticles();   // gọi API thật
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: BaseShimmerBuilder(
        isLoading: _isLoading,
        shimmerContent: Column(
          children: List.generate(6, (_) => const ShimmerListTile()),
        ),
        child: ListView.builder(
          itemCount: _articles.length,
          itemBuilder: (_, i) => ArticleTile(article: _articles[i]),
        ),
      ),
    );
  }
}
```

---

## Best practices

1. **Skeleton trong < 1 giây tải dữ liệu thì không cần shimmer** — flash 100ms còn khó chịu hơn không có gì. Có thể delay 200ms rồi mới bật `isLoading = true`.
2. **Skeleton phải có kích thước gần giống UI thật** để tránh hiện tượng layout shift khi data về.
3. **Tránh shimmer toàn màn hình quá nhiều block** — chia nhỏ ra theo từng section, mỗi section có skeleton riêng để UX cảm giác nhanh hơn.
4. **Dùng `BaseShimmerList`** khi đã có UI thật, không cần copy lại structure cho skeleton (nhanh hơn, ít sai sót).
5. **Dùng `BaseShimmerBuilder` + `ShimmerBox/Tile/Card`** cho skeleton custom đẹp & gọn nét hơn.

---

## Tham khảo demo

Màn hình demo trực quan ở [lib/features/test_screen/shimmer_demo_screen.dart](../../../features/test_screen/shimmer_demo_screen.dart) — vào `TestScreen` → bấm nút **"✨ Shimmer Demo"**.
