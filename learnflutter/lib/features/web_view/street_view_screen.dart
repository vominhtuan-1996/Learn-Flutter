import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StreetViewScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final bool isEmbed;
  const StreetViewScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.isEmbed = false,
  });

  @override
  State<StreetViewScreen> createState() => _StreetViewScreenState();
}

class _StreetViewScreenState extends State<StreetViewScreen> {
  late final WebViewController _controller;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Inject CSS to hide Google logo and "Open in App" buttons
            _controller.runJavaScript('''
              (function() {
                var style = document.createElement('style');
                style.innerHTML = `
                  /* Hàng dưới cùng chứa logo và bản quyền */
                  .gm-style-cc, 
                  .gmnoprint, 
                  .gm-bundle-container,
                  .gm-iv-address,
                  .gm-iv-address-link,
                  /* Nút Mở trong ứng dụng và banner quảng cáo */
                  .L8S70c, 
                  .S67S8c, 
                  .V67S8c,
                  .app-promo,
                  .app-banner,
                  #consent-bump,
                  /* Các phần tử link điều hướng ra ngoài */
                  a[href*="maps.google.com/maps"],
                  button[title*="Google Maps"],
                  /* Chặn overlay z-index cao */
                  div[style*="z-index: 1000001"],
                  div[style*="z-index: 1000000"] { 
                    display: none !important; 
                    visibility: hidden !important;
                    height: 0 !important;
                    width: 0 !important;
                    opacity: 0 !important;
                    pointer-events: none !important;
                  }
                `;
                document.head.appendChild(style);

                // Dùng thêm MutationObserver để đảm bảo các phần tử load động sau này cũng bị ẩn
                var observer = new MutationObserver(function(mutations) {
                  style.innerHTML += ''; // Kích hoạt render lại nếu cần
                });
                observer.observe(document.body, { childList: true, subtree: true });
              })();
            ''');
          },
        ),
      )
      ..loadRequest(_getStreetViewUri());
  }

  Uri _getStreetViewUri() {
    final lat = widget.initialLat ?? 21.0285;
    final lng = widget.initialLng ?? 105.8542;
    // Sử dụng URL của Google Maps Street View nhúng qua iframe trick hoặc URL trực tiếp
    // Ở đây dùng URL maps.google.com với tham số cbll (vị trí) và layer=c (street view)
    return Uri.parse(
      'https://www.google.com/maps/@$lat,$lng,3a,75y,0h,90t/data=!3m6!1e1!3m4!1s!2e0!7i13312!8i6656',
    );
  }

  void _onReload() {
    _controller.loadRequest(_getStreetViewUri());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEmbed) {
      return _buildBody();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Street View 360'),
        actions: [
          IconButton(
            onPressed: _onReload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
