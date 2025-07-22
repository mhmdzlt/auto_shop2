import 'package:flutter/material.dart';

/// ويدجت للتحميل التدريجي للقوائم الطويلة
class LazyLoadingList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Future<List<T>> Function()? onLoadMore;
  final int pageSize;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;
  final int? initialItemCount;

  const LazyLoadingList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.onLoadMore,
    this.pageSize = 20,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.initialItemCount,
  });

  @override
  State<LazyLoadingList<T>> createState() => _LazyLoadingListState<T>();
}

class _LazyLoadingListState<T> extends State<LazyLoadingList<T>> {
  final ScrollController _scrollController = ScrollController();
  List<T> _displayedItems = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _initializeItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(LazyLoadingList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _initializeItems();
    }
  }

  void _initializeItems() {
    final initialCount = widget.initialItemCount ?? widget.pageSize;
    _displayedItems = widget.items.take(initialCount).toList();
    _hasMore = widget.items.length > initialCount || widget.onLoadMore != null;
    _error = null;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<T> newItems;

      if (widget.onLoadMore != null) {
        // تحميل من مصدر خارجي
        newItems = await widget.onLoadMore!();
      } else {
        // تحميل من القائمة الموجودة
        final startIndex = _displayedItems.length;
        final endIndex = (startIndex + widget.pageSize).clamp(
          0,
          widget.items.length,
        );
        newItems = widget.items.sublist(startIndex, endIndex);
      }

      if (mounted) {
        setState(() {
          _displayedItems.addAll(newItems);
          _hasMore = widget.onLoadMore != null
              ? newItems.isNotEmpty
              : _displayedItems.length < widget.items.length;
          _isLoading = false;
          _currentPage++;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_displayedItems.isEmpty && !_isLoading) {
      return widget.emptyBuilder?.call(context) ?? _buildDefaultEmpty();
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _displayedItems.length + (_hasMore ? 1 : 0),
      padding: widget.padding,
      physics: widget.physics ?? const BouncingScrollPhysics(),
      shrinkWrap: widget.shrinkWrap,
      scrollDirection: widget.scrollDirection,
      itemBuilder: (context, index) {
        // عرض العناصر العادية
        if (index < _displayedItems.length) {
          return widget.itemBuilder(context, _displayedItems[index], index);
        }

        // عرض مؤشر التحميل أو الخطأ
        if (_error != null) {
          return widget.errorBuilder?.call(context, _error!) ??
              _buildDefaultError(_error!);
        }

        return widget.loadingBuilder?.call(context) ?? _buildDefaultLoading();
      },
    );
  }

  Widget _buildDefaultEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'لا توجد عناصر',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLoading() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
        ),
      ),
    );
  }

  Widget _buildDefaultError(String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          Text(
            'حدث خطأ: $error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadMore,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

/// ويدجت للتحميل التدريجي للشبكة
class LazyLoadingGrid<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Future<List<T>> Function()? onLoadMore;
  final int pageSize;
  final EdgeInsets? padding;

  const LazyLoadingGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.loadingBuilder,
    this.emptyBuilder,
    this.onLoadMore,
    this.pageSize = 20,
    this.padding,
  });

  @override
  State<LazyLoadingGrid<T>> createState() => _LazyLoadingGridState<T>();
}

class _LazyLoadingGridState<T> extends State<LazyLoadingGrid<T>> {
  final ScrollController _scrollController = ScrollController();
  List<T> _displayedItems = [];
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _displayedItems = widget.items.take(widget.pageSize).toList();
    _hasMore = widget.items.length > widget.pageSize;
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      List<T> newItems;

      if (widget.onLoadMore != null) {
        newItems = await widget.onLoadMore!();
      } else {
        final startIndex = _displayedItems.length;
        final endIndex = (startIndex + widget.pageSize).clamp(
          0,
          widget.items.length,
        );
        newItems = widget.items.sublist(startIndex, endIndex);
      }

      if (mounted) {
        setState(() {
          _displayedItems.addAll(newItems);
          _hasMore = widget.onLoadMore != null
              ? newItems.isNotEmpty
              : _displayedItems.length < widget.items.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_displayedItems.isEmpty && !_isLoading) {
      return widget.emptyBuilder?.call(context) ??
          const Center(child: Text('لا توجد عناصر'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: widget.padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: _displayedItems.length + (_hasMore && _isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _displayedItems.length) {
          return widget.itemBuilder(context, _displayedItems[index], index);
        }

        return widget.loadingBuilder?.call(context) ??
            const Center(child: CircularProgressIndicator());
      },
    );
  }
}

/// مؤشر تحميل مخصص للقوائم
class CustomLoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;

  const CustomLoadingIndicator({super.key, this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? const Color(0xFF1976D2),
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}
