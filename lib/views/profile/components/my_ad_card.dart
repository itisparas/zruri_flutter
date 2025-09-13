// lib/views/profile/components/my_ad_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zruri/core/constants/app_colors.dart';
import 'package:zruri/core/services/firebase_storage_service.dart';
import 'package:zruri/models/my_ads_model.dart';
import 'package:share_plus/share_plus.dart';

class MyAdCard extends StatefulWidget {
  final MyAdsModel ad;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  MyAdCard({
    super.key,
    required this.ad,
    required this.onToggleActive,
    required this.onDelete,
    required this.onTap,
    this.onEdit,
  });

  @override
  State<MyAdCard> createState() => _MyAdCardState();
}

class _MyAdCardState extends State<MyAdCard> with TickerProviderStateMixin {
  bool _isPressed = false;
  bool _showActions = false;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleActions() {
    setState(() {
      _showActions = !_showActions;
    });

    if (_showActions) {
      _slideController.forward();
      _fadeController.forward();
      HapticFeedback.lightImpact();
    } else {
      _slideController.reverse();
      _fadeController.reverse();
    }
  }

  void _hideActions() {
    if (_showActions) {
      setState(() {
        _showActions = false;
      });
      _slideController.reverse();
      _fadeController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _showActions ? _hideActions : widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.99 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 95, // Reduced height to prevent overflow
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _showActions
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              width: _showActions ? 1.5 : 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_showActions ? 0.08 : 0.03),
                blurRadius: _showActions ? 12 : 4,
                offset: Offset(0, _showActions ? 4 : 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // Main Content
                Row(
                  children: [
                    // Image Section
                    _buildImageSection(),

                    // Content Section
                    Expanded(
                      child: Container(
                        height: 95, // Match container height
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize:
                              MainAxisSize.min, // Important: Use min size
                          children: [
                            // Title and Action Button Row
                            Expanded(
                              // Wrap in Expanded to prevent overflow
                              flex: 2,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          // Use Flexible instead of fixed Text
                                          child: Text(
                                            widget.ad.title,
                                            style: const TextStyle(
                                              fontSize: 15, // Reduced font size
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                              height:
                                                  1.2, // Reduced line height
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ), // Reduced spacing
                                        Text(
                                          '\$${widget.ad.price}',
                                          style: TextStyle(
                                            fontSize: 16, // Reduced font size
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Action Trigger Button
                                  _buildActionTrigger(),
                                ],
                              ),
                            ),

                            // Bottom Info Row
                            Expanded(
                              // Wrap in Expanded
                              flex: 1,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.schedule_rounded,
                                          size: 12,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            _getFormattedDate(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusBadge(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Sliding Action Panel
                if (_showActions) _buildActionPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        FutureBuilder<String?>(
          future: widget._storageService.getDownloadUrl(
            path: widget.ad.imageUrl,
          ),
          builder: (context, snapshot) {
            return Container(
              width: 95, // Match the height for square image
              height: 95,
              child:
                  snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData
                  ? CachedNetworkImage(
                      imageUrl: snapshot.data!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[50],
                        child: const Center(
                          child: SpinKitPulse(
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[50],
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: Colors.grey[300],
                          size: 24,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[50],
                      child: const Center(
                        child: SpinKitPulse(color: AppColors.primary, size: 20),
                      ),
                    ),
            );
          },
        ),

        // Status Dot
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.ad.active ? Colors.green : Colors.amber,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTrigger() {
    return GestureDetector(
      onTap: _toggleActions,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _showActions
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _showActions
                ? AppColors.primary.withOpacity(0.2)
                : Colors.transparent,
          ),
        ),
        child: AnimatedRotation(
          turns: _showActions ? 0.25 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.more_horiz_rounded,
            size: 18,
            color: _showActions ? AppColors.primary : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: widget.ad.active
            ? Colors.green.withOpacity(0.08)
            : Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: widget.ad.active
              ? Colors.green.withOpacity(0.2)
              : Colors.amber.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: widget.ad.active ? Colors.green : Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            widget.ad.active ? 'Active' : 'Hidden',
            style: TextStyle(
              color: widget.ad.active ? Colors.green[700] : Colors.amber[700],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPanel() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(_fadeAnimation.value * 0.98),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickAction(
                            icon: widget.ad.active
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            label: widget.ad.active ? 'Hide' : 'Show',
                            color: widget.ad.active
                                ? Colors.orange
                                : Colors.green,
                            onTap: () {
                              _hideActions();
                              widget.onToggleActive();
                            },
                          ),
                          const SizedBox(width: 24),
                          if (widget.onEdit != null) ...[
                            _buildQuickAction(
                              icon: Icons.edit_rounded,
                              label: 'Edit',
                              color: Colors.blue,
                              onTap: () {
                                _hideActions();
                                widget.onEdit!();
                              },
                            ),
                            const SizedBox(width: 24),
                          ],
                          _buildQuickAction(
                            icon: Icons.share_rounded,
                            label: 'Share',
                            color: Colors.purple,
                            onTap: () {
                              _hideActions();
                              _shareAd();
                            },
                          ),
                          const SizedBox(width: 24),
                          _buildQuickAction(
                            icon: Icons.delete_rounded,
                            label: 'Delete',
                            color: Colors.red,
                            onTap: () {
                              _hideActions();
                              _confirmDelete();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(0.2), width: 0.5),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final adDate = widget.ad.createdAt.toDate();
    final difference = now.difference(adDate);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return DateFormat.MMMd().format(adDate);
    }
  }

  void _shareAd() async {
    try {
      HapticFeedback.lightImpact();

      String shareUrl = 'https://app-zruri.web.app/listing/${widget.ad.id}';
      String shareText =
          '''
🏷️ Check out this amazing deal!

📱 ${widget.ad.title}
💰 \$${widget.ad.price}
⏰ Posted ${_getFormattedDate()}

View more details: $shareUrl

#Zruri #Marketplace #Deal'''
              .trim();

      final RenderBox? box = context.findRenderObject() as RenderBox?;
      final Rect sharePositionOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : Rect.zero;

      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: widget.ad.title,
          sharePositionOrigin: sharePositionOrigin,
        ),
      );

      FirebaseAnalytics.instance.logShare(
        contentType: 'listing',
        itemId: widget.ad.id,
        method: 'share_button',
      );

      HapticFeedback.selectionClick();
      Get.snackbar(
        'Shared!',
        'Ad link copied and shared successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Share Failed',
        'Unable to share right now. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        borderRadius: 8,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  void _confirmDelete() {
    HapticFeedback.mediumImpact();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete Ad?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete "${widget.ad.title}"?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      widget.onDelete();
                      HapticFeedback.heavyImpact();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
