// lib/products/list.dart
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

/// ---- Cute Pink Palette ----
const _pink = Color(0xFFF48FB1);
const _pinkDark = Color(0xFFD81B60);
const _pinkLight = Color(0xFFFFC1E3);
const _rose = Color(0xFFFFF1F5);
const _ink = Color(0xFF6B4C6C);

class ProductsListPage extends StatefulWidget {
  const ProductsListPage({super.key});

  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  final pb = PocketBase('http://127.0.0.1:8090');

  final List<Map<String, dynamic>> _products = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  Future<UnsubscribeFunc>? _subscription;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    // real-time subscribe (คงเดิม)
    _subscription = pb.collection('products').subscribe('*', (e) {
      if (!mounted) return;
      if (e.action == 'create' && e.record?.data != null) {
        setState(() => _products.insert(0, e.record!.data));
      } else if (e.action == 'update' && e.record?.data != null) {
        final idx = _products.indexWhere((p) => p['id'] == e.record?.id);
        if (idx != -1) {
          setState(() => _products[idx] = e.record!.data);
        }
      } else if (e.action == 'delete' && e.record?.id != null) {
        setState(() => _products.removeWhere((p) => p['id'] == e.record?.id));
      }
    });
  }

  Future<void> _fetchProducts({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      if (refresh) {
        _products.clear();
        _page = 1;
        _hasMore = true;
      }
      final res = await pb.collection('products').getList(page: _page, perPage: 20);
      setState(() {
        _products.addAll(res.items.map((e) => e.data));
        _page++;
        _hasMore = res.items.length == 20;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('โหลดข้อมูลล้มเหลว: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _subscription?.then((u) => u());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar โทนชมพู + พื้นหลังหวาน ๆ
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_pinkLight, _pinkDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: _rose,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _pinkDark,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create'),
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => _ProductDialog(pb: pb),
          );
        },
      ),

      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200 &&
              _hasMore && !_isLoading) {
            _fetchProducts();
          }
          return false;
        },
        child: RefreshIndicator(
          color: _pinkDark,
          onRefresh: () => _fetchProducts(refresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
            itemCount: _products.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _products.length) {
                final p = _products[index];
                return _ProductCard(
                  product: p,
                  onEdit: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => _ProductDialog(pb: pb, product: p),
                    );
                  },
                  onDelete: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => _ConfirmDialog(
                        title: 'ลบสินค้า?',
                        message: 'คุณต้องการลบ “${p['name'] ?? ''}” ใช่ไหม',
                        confirmLabel: 'ลบ',
                      ),
                    );
                    if (ok == true) {
                      await pb.collection('products').delete(p['id']);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ลบสินค้าแล้ว')),
                        );
                      }
                    }
                  },
                );
              } else {
                // Loader แท่งชมพู น่ารัก ๆ ตอนโหลดหน้าเพิ่ม
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: _PinkLoader()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

/// ====== Widgets ตกแต่ง ======

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final img = product['imageurl']?.toString() ?? '';
    final name = product['name']?.toString() ?? '';
    final shop = product['nameshop']?.toString() ?? '';
    final price = product['price']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.85),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _pink.withOpacity(.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Row(
        children: [
          // รูปสินค้า โค้งมน + เงา
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [_pinkLight, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: img.isNotEmpty
                  ? Image.network(
                      img,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _ImageFallback(width: 84, height: 84),
                    )
                  : _ImageFallback(width: 84, height: 84),
            ),
          ),

          // ข้อมูลสินค้า
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ชื่อ + ป้ายราคา
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _PricePill(price: price),
                      const SizedBox(width: 12),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.store_mall_directory_rounded,
                          size: 16, color: _ink),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          shop,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _ink.withOpacity(.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // ปุ่มแก้ไข/ลบ โทนชมพู
                  Row(
                    children: [
                      _CuteActionButton(
                        icon: Icons.edit_rounded,
                        label: 'Edit',
                        onTap: onEdit,
                        gradient: const LinearGradient(
                          colors: [_pinkLight, _pink],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _CuteActionButton(
                        icon: Icons.delete_rounded,
                        label: 'Delete',
                        onTap: onDelete,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFA3B1), _pinkDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final String price;
  const _PricePill({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _pinkLight.withOpacity(.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _pinkDark.withOpacity(.25)),
      ),
      child: Text(
        '฿$price',
        style: const TextStyle(
          color: _pinkDark,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _CuteActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Gradient gradient;

  const _CuteActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: gradient,
            boxShadow: [
              BoxShadow(
                color: _pink.withOpacity(.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final double width;
  final double height;
  const _ImageFallback({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: _rose,
      child: const Icon(Icons.image_not_supported_outlined, color: _ink),
    );
  }
}

class _PinkLoader extends StatelessWidget {
  const _PinkLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      width: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          backgroundColor: _pinkLight.withOpacity(.5),
          color: _pinkDark,
          minHeight: 6,
        ),
      ),
    );
  }
}

/// ====== Dialogs ======

class _ProductDialog extends StatefulWidget {
  final PocketBase pb;
  final Map<String, dynamic>? product;
  const _ProductDialog({required this.pb, this.product});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _shop;
  late final TextEditingController _image;
  late final TextEditingController _price;

  @override
  void initState() {
    super.initState();
    _name  = TextEditingController(text: widget.product?['name'] ?? '');
    _shop  = TextEditingController(text: widget.product?['nameshop'] ?? '');
    _image = TextEditingController(text: widget.product?['imageurl'] ?? '');
    _price = TextEditingController(text: widget.product?['price']?.toString() ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _shop.dispose();
    _image.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.product == null;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _pinkLight, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // หัว Dialog ไล่เฉดชมพู
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                gradient: LinearGradient(
                  colors: [_pinkLight, _pinkDark],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_mall_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isCreate ? 'Create Product' : 'Update Product',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _PinkField(
                        controller: _name,
                        label: 'Name',
                        icon: Icons.tag_rounded,
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter name' : null,
                      ),
                      _PinkField(
                        controller: _shop,
                        label: 'Shop',
                        icon: Icons.storefront_rounded,
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter shop' : null,
                      ),
                      _PinkField(
                        controller: _image,
                        label: 'Image URL',
                        icon: Icons.image_rounded,
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter image URL' : null,
                      ),
                      _PinkField(
                        controller: _price,
                        label: 'Price',
                        icon: Icons.sell_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter price' : null,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: _ink),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pinkDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(isCreate ? Icons.add_rounded : Icons.save_rounded),
                    label: Text(isCreate ? 'Create' : 'Update'),
                    onPressed: () async {
                      if (!(_formKey.currentState?.validate() ?? false)) return;

                      final data = {
                        'name': _name.text.trim(),
                        'nameshop': _shop.text.trim(),
                        'imageurl': _image.text.trim(),
                        'price': int.tryParse(_price.text.trim()) ?? 0,
                      };

                      if (isCreate) {
                        await widget.pb.collection('products').create(body: data);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('สร้างสินค้าแล้ว')),
                          );
                        }
                      } else {
                        await widget.pb.collection('products')
                            .update(widget.product!['id'], body: data);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('บันทึกการแก้ไขแล้ว')),
                          );
                        }
                      }
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinkField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _PinkField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _pinkDark),
          filled: true,
          fillColor: _rose,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _pinkLight, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _pinkDark, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade300, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.red.shade300, width: 2),
          ),
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _pinkDark, foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    );
    }
}
