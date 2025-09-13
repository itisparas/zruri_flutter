// lib/views/categories_page/components/category_search_bar.dart
import 'package:flutter/material.dart';

class CategorySearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onClear;

  const CategorySearchBar({
    super.key,
    required this.onSearch,
    required this.onClear,
  });

  @override
  State<CategorySearchBar> createState() => _CategorySearchBarState();
}

class _CategorySearchBarState extends State<CategorySearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearch,
        decoration: InputDecoration(
          hintText: 'Search categories...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: _hasText
              ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onClear();
                  },
                  icon: Icon(Icons.clear, color: Colors.grey[500]),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
