import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// ويدجت محسن لعرض صور المنتجات مع التخزين المؤقت
class ProductImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool enableHero;
  final String? heroTag;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.enableHero = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    // إعداد مدير التخزين المؤقت المخصص
    final cacheManager = CacheManager(
      Config(
        'product_images',
        stalePeriod: const Duration(days: 7), // حفظ الصور لأسبوع
        maxNrOfCacheObjects: 500, // حد أقصى 500 صورة
        repo: JsonCacheInfoRepository(databaseName: 'product_images'),
        fileService: HttpFileService(),
      ),
    );

    Widget imageWidget = ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              width: width,
              height: height,
              fit: fit,
              cacheManager: cacheManager,

              // شاشة التحميل
              placeholder: (context, url) => Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: borderRadius ?? BorderRadius.circular(8),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1976D2),
                    ),
                  ),
                ),
              ),

              // شاشة الخطأ
              errorWidget: (context, url, error) => Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: borderRadius ?? BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'لا توجد صورة',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // تحسين الذاكرة
              memCacheWidth: width?.toInt(),
              memCacheHeight: height?.toInt(),
              maxWidthDiskCache: 600, // حد أقصى للعرض في التخزين
              maxHeightDiskCache: 600, // حد أقصى للارتفاع في التخزين
            )
          : _buildPlaceholder(),
    );

    // إضافة Hero animation إذا كان مطلوباً
    if (enableHero && heroTag != null) {
      return Hero(tag: heroTag!, child: imageWidget);
    }

    return imageWidget;
  }

  /// بناء العنصر النائب عند عدم وجود صورة
  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 32, color: Colors.grey[400]),
          const SizedBox(height: 4),
          Text(
            'لا توجد صورة',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// ويدجت محسن لعرض قائمة الصور مع التحميل التدريجي
class ProductImageGallery extends StatelessWidget {
  final List<String> imageUrls;
  final double itemHeight;
  final double itemWidth;
  final EdgeInsets? padding;
  final Function(int index)? onImageTap;

  const ProductImageGallery({
    super.key,
    required this.imageUrls,
    this.itemHeight = 120,
    this.itemWidth = 120,
    this.padding,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: itemHeight,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onImageTap?.call(index),
              child: ProductImageWidget(
                imageUrl: imageUrls[index],
                width: itemWidth,
                height: itemHeight,
                enableHero: true,
                heroTag: 'gallery_image_$index',
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ويدجت محسن لعرض صورة المنتج الرئيسية
class MainProductImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final Function()? onTap;

  const MainProductImage({
    super.key,
    required this.imageUrl,
    this.height = 300,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ProductImageWidget(
          imageUrl: imageUrl,
          width: double.infinity,
          height: height,
          enableHero: true,
          heroTag: 'main_product_image',
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// مدير صور مخصص للمنتجات
class ProductImageCacheManager {
  static final _instance = CacheManager(
    Config(
      'product_images_cache',
      stalePeriod: const Duration(days: 30), // الاحتفاظ بالصور لشهر
      maxNrOfCacheObjects: 1000, // حد أقصى 1000 صورة
      repo: JsonCacheInfoRepository(databaseName: 'product_images_cache'),
      fileService: HttpFileService(),
    ),
  );

  static CacheManager get instance => _instance;

  /// مسح ذاكرة التخزين المؤقت للصور
  static Future<void> clearCache() async {
    await _instance.emptyCache();
  }

  /// تحميل صورة مسبقاً
  static Future<void> preloadImage(String imageUrl) async {
    try {
      await _instance.downloadFile(imageUrl);
    } catch (e) {
      debugPrint('❌ Error preloading image: $e');
    }
  }

  /// تحميل قائمة من الصور مسبقاً
  static Future<void> preloadImages(List<String> imageUrls) async {
    await Future.wait(
      imageUrls.map((url) => preloadImage(url)),
      eagerError: false,
    );
  }

  /// الحصول على حجم ذاكرة التخزين المؤقت
  static Future<int> getCacheSize() async {
    final files = await _instance.getCachedFileInfos();
    return files.fold<int>(0, (total, file) => total + (file.size ?? 0));
  }

  /// تنظيف الملفات القديمة
  static Future<void> cleanupOldFiles() async {
    final files = await _instance.getCachedFileInfos();
    final now = DateTime.now();

    for (final file in files) {
      if (file.validTill.isBefore(now)) {
        await _instance.removeFile(file.key);
      }
    }
  }
}
