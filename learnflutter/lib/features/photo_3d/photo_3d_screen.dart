import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learnflutter/shared/widgets/photo_3d_viewer.dart';

/// [Photo3DScreen] là màn hình chức năng cho phép người dùng trải nghiệm hiệu ứng 3D
/// trên chính những bức ảnh cá nhân từ album điện thoại. Màn hình sử dụng [ImagePicker]
/// để tương tác với thư viện ảnh hệ thống và hiển thị kết quả qua [Photo3DViewer].
class Photo3DScreen extends StatefulWidget {
  const Photo3DScreen({super.key});

  @override
  State<Photo3DScreen> createState() => _Photo3DScreenState();
}

class _Photo3DScreenState extends State<Photo3DScreen> {
  /// [_pickedImage] lưu trữ đường dẫn file ảnh được chọn từ album.
  /// Nếu biến này null, màn hình sẽ hiển thị một ảnh mẫu mặc định từ network.
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  /// [_pickImage] kích hoạt luồng chọn ảnh từ thư viện (Gallery).
  /// Sau khi người dùng chọn xong, [setState] được gọi để cập nhật UI và
  /// tái tạo lại widget [Photo3DViewer] với dữ liệu mới.
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (image != null) {
        setState(() => _pickedImage = image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Photo 3D Viewer',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Widget hiển thị ảnh với hiệu ứng 3D.
            /// Nếu có ảnh chọn từ album, ưu tiên hiển thị ảnh đó (Local file).
            /// Nếu không, hiển thị ảnh trừu tượng mẫu từ Unsplash.
            Photo3DViewer(
              key: ValueKey(_pickedImage?.path ?? 'default'),
              imagePath: _pickedImage?.path ??
                  'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1000',
              isNetworkImage: _pickedImage == null,
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.55,
            ),

            const SizedBox(height: 50),

            _buildActionButtons(),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Mẹo: Chạm và kéo trên ảnh để nghiêng theo 3 chiều không gian.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [_buildActionButtons] cung cấp các nút tương tác chính: chọn ảnh mới và xóa ảnh hiện tại.
  /// Sử dụng [ElevatedButton.icon] để GUI trông hiện đại và dễ hiểu hơn.
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.photo_library),
          label: const Text('Chọn ảnh từ Album'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        if (_pickedImage != null) ...[
          const SizedBox(width: 12),
          IconButton.filledTonal(
            onPressed: () => setState(() => _pickedImage = null),
            icon: const Icon(Icons.refresh),
            tooltip: 'Đặt lại ảnh mẫu',
          ),
        ],
      ],
    );
  }
}
