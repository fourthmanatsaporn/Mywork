// lib/pages/home.dart
import 'package:flutter/material.dart';
import '../products/list.dart';

/// ---------- Cute Pink Palette ----------
const _pink = Color(0xFFF48FB1);
const _pinkDark = Color(0xFFD81B60);
const _pinkLight = Color(0xFFFFC1E3);
const _rose = Color(0xFFFFEBEE);
const _lavender = Color(0xFFF3E5F5);
const _chipText = Color(0xFF6B4C6C);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_rose, _lavender],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_rounded, color: _pinkDark),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'E-Commerce',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _chipText,
                            letterSpacing: .2,
                          ),
                        ),
                      ),
                      const Icon(Icons.favorite, color: _pinkDark),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _GradientButton.icon(
                  icon: Icons.list_alt_rounded,
                  label: 'ดูสินค้าทั้งหมด',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProductsListPage()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const _SectionHeader(
                  title: 'Top Shops',
                  subtitle: 'ร้านแนะนำสำหรับคุณ',
                  icon: Icons.local_mall_rounded,
                ),
                const SizedBox(height: 8),
                const TopShopsWidget(),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Top Products',
                  subtitle: 'สินค้ายอดนิยม เลื่อนซ้าย-ขวาได้',
                  icon: Icons.star_rounded,
                ),
                const SizedBox(height: 8),
                TopProductsWidget(),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Popular Reviews',
                  subtitle: 'เสียงจากผู้ใช้จริง',
                  icon: Icons.reviews_rounded,
                ),
                const SizedBox(height: 8),
                const PopularReviewsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------- Section Header ----------
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _pinkLight,
          ),
          child: Icon(icon, color: _pinkDark, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _chipText,
                  )),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _chipText.withOpacity(.7),
                  )),
            ],
          ),
        ),
        const _CuteChip(text: 'New'),
      ],
    );
  }
}

class _CuteChip extends StatelessWidget {
  final String text;
  const _CuteChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _pink.withOpacity(.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _pinkDark.withOpacity(.25), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _chipText,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: .2,
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.8)),
        boxShadow: [
          BoxShadow(
            color: _pink.withOpacity(.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// ---------- Top Shops ----------
class TopShopsWidget extends StatelessWidget {
  const TopShopsWidget({super.key});

  final List<Map<String, String>> shops = const [
    {'name': 'Luxe Lane', 'image': 'https://picsum.photos/seed/shopA/120'},
    {'name': 'Urban Vogue', 'image': 'https://picsum.photos/seed/shopB/120'},
    {'name': 'Cosmo Corner', 'image': 'https://picsum.photos/seed/shopC/120'},
    {'name': 'Trend Hive', 'image': 'https://picsum.photos/seed/shopD/120'},
    {'name': 'joney larin', 'image': 'https://picsum.photos/seed/shopD/120'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: shops.length,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final shop = shops[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [_pinkLight, _pink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _pink.withOpacity(.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.network(
                      shop['image']!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 76,
                child: Text(
                  shop['name']!,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _chipText,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ---------- Top Products ----------
class TopProductsWidget extends StatelessWidget {
  TopProductsWidget({super.key});

  final List<Map<String, String>> products = List.generate(23, (i) => {
        'name': 'Product ${i + 1}',
        'image': 'https://picsum.photos/seed/${i + 2}/400/400',
        'price': '฿${(i + 1) * 10 + 89}',
      });

  @override
  Widget build(BuildContext context) {
    return _AnimatedProductSlider(products: products);
  }
}

class _AnimatedProductSlider extends StatefulWidget {
  final List<Map<String, String>> products;
  const _AnimatedProductSlider({required this.products});

  @override
  State<_AnimatedProductSlider> createState() => _AnimatedProductSliderState();
}

class _AnimatedProductSliderState extends State<_AnimatedProductSlider> {
  final PageController _controller = PageController(viewportFraction: 0.38);
  int _currentPage = 0;

  void _animateToPage(int page) {
    if (page >= 0 && page < widget.products.length) {
      _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage = page);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final page = _controller.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.products.length;

    return Column(
      children: [
        SizedBox(
          height: 240, // เผื่อ text-scale / ฟอนต์ต่างเครื่อง
          child: Row(
            children: [
              _RoundIconButton(
                icon: Icons.chevron_left,
                enabled: _currentPage > 0,
                onTap: () => _animateToPage(_currentPage - 1),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: total,
                  itemBuilder: (context, index) {
                    final p = widget.products[index];
                    final isCurrent = index == _currentPage;

                    return AnimatedPadding(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: isCurrent ? 6 : 16,
                      ),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        scale: isCurrent ? 1.0 : 0.94,
                        curve: Curves.easeOut,
                        child: _GlassCard(
                          // แก้ overflow โดยคุม layout จาก constraint จริงของการ์ด
                          child: LayoutBuilder(
                            builder: (context, c) {
                              // คิดพื้นที่ข้อความตาม text scale ของระบบ
                              final scale =
                                  MediaQuery.of(context).textScaler.scale(1.0);
                              // เผื่อพื้นที่ (ชื่อ + ระยะห่าง + ป้ายราคา)
                              // base ~62px แล้วบวกเผื่ออีก 8px
                              final reserved = (62.0 * scale) + 8.0;

                              // รูป = min(ความสูงที่เหลือ, ความกว้างการ์ด-ขอบ) ในช่วง 72..160
                              final maxImgByHeight =
                                  (c.maxHeight - reserved).clamp(72.0, 160.0);
                              final maxImgByWidth =
                                  (c.maxWidth - 32.0).clamp(72.0, 160.0);
                              final imgSize = maxImgByHeight < maxImgByWidth
                                  ? maxImgByHeight
                                  : maxImgByWidth;

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: imgSize,
                                    width: imgSize,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        p['image']!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // กันชื่อยาว/ตัวอักษรใหญ่
                                  Text(
                                    p['name']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: _chipText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _pinkLight.withOpacity(.55),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      p['price']!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: _pinkDark,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  onPageChanged: (page) => setState(() => _currentPage = page),
                ),
              ),
              _RoundIconButton(
                icon: Icons.chevron_right,
                enabled: _currentPage < total - 1,
                onTap: () => _animateToPage(_currentPage + 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // ตัวชี้หน้าสไลด์ (dots)
        SizedBox(
          height: 12,
          child: Center(
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: total,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? _pinkDark : _pink.withOpacity(.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _RoundIconButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enabled ? onTap : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [_pink, _pinkDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _pink.withOpacity(.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

/// ---------- Gradient Button ----------
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const _GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  factory _GradientButton.icon({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) =>
      _GradientButton(label: label, icon: icon, onPressed: onPressed);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onPressed,
      child: Ink(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [_pink, _pinkDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _pink.withOpacity(.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16.5,
                  letterSpacing: .2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// ---------- Reviews ----------
class PopularReviewsWidget extends StatelessWidget {
  const PopularReviewsWidget({super.key});

  final List<Map<String, String>> reviews = const [
    {'user': 'Alice', 'review': 'Great product!'},
    {'user': 'Bob', 'review': 'Fast delivery and good quality.'},
    {'user': 'Charlie', 'review': 'Highly recommend this shop.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reviews
          .map(
            (review) => _GlassCard(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _pinkLight,
                  child: Text(
                    review['user']![0],
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _chipText,
                    ),
                  ),
                ),
                title: Text(
                  review['user']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _chipText,
                  ),
                ),
                subtitle: Text(
                  review['review']!,
                  style: TextStyle(color: _chipText.withOpacity(.8)),
                ),
                trailing: const Icon(Icons.favorite, color: _pinkDark),
              ),
            ),
          )
          .toList(),
    );
  }
}
