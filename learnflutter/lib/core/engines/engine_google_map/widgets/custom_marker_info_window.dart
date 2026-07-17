import 'package:flutter/material.dart';
import 'package:learnflutter/core/engines/engine_google_map/models/map_overlay_models.dart';

/// Custom info window widget hiển thị marker info với actions.
/// Dùng Positioned overlay trên GoogleMap widget.
class CustomMarkerInfoWindow extends StatelessWidget {
  final CustomMarkerData markerData;
  final VoidCallback onClose;
  final Offset position; // Vị trí hiển thị trên màn hình (convert từ lat/lng)

  const CustomMarkerInfoWindow({
    Key? key,
    required this.markerData,
    required this.onClose,
    required this.position,
  }) : super(key: key);

  Color _getStatusColor(MarkerStatus status) {
    switch (status) {
      case MarkerStatus.online:
        return const Color(0xFF10B981);
      case MarkerStatus.offline:
        return const Color(0xFF6B7280);
      case MarkerStatus.busy:
        return const Color(0xFFF59E0B);
      case MarkerStatus.idle:
        return const Color(0xFF3B82F6);
      case MarkerStatus.warning:
        return const Color(0xFFEF4444);
      case MarkerStatus.error:
        return const Color(0xFFDC2626);
    }
  }

  String _getStatusLabel(MarkerStatus status) {
    switch (status) {
      case MarkerStatus.online:
        return 'Online';
      case MarkerStatus.offline:
        return 'Offline';
      case MarkerStatus.busy:
        return 'Busy';
      case MarkerStatus.idle:
        return 'Idle';
      case MarkerStatus.warning:
        return 'Warning';
      case MarkerStatus.error:
        return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 120, // Center horizontally (card width ~240)
      top: position.dy - 270, // Above marker
      child: GestureDetector(
        onTap: () {}, // Prevent closing when tapping inside card
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with image & close button
          Stack(
            children: [
              // Image or placeholder
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  image: markerData.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(markerData.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: markerData.imageUrl == null
                    ? Center(
                        child: Icon(
                          Icons.location_on,
                          size: 48,
                          color: const Color(0xFF9CA3AF),
                        ),
                      )
                    : null,
              ),
              // Close button
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.6),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              // Status badge
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(markerData.status),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusLabel(markerData.status),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  markerData.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                // Subtitle
                if (markerData.subtitle != null)
                  Text(
                    markerData.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                const SizedBox(height: 6),
                // Description
                Text(
                  markerData.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
                // Actions
                if (markerData.actions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildActionButtons(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: const Color(0xFFE5E7EB), height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: markerData.actions.map((action) {
            return SizedBox(
              height: 28,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: action.onPressed,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: action.color.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(action.icon, size: 12, color: action.color),
                        const SizedBox(width: 3),
                        Text(
                          action.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: action.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Overlay backdrop để close info window khi tap outside
class CustomMarkerInfoOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const CustomMarkerInfoOverlay({
    Key? key,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.transparent,
      ),
    );
  }
}
