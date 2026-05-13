import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/section_card.dart';
import '../widgets/status_chip.dart';
import 'asset_detail_screen.dart';

class AssetSearchScreen extends StatefulWidget {
  const AssetSearchScreen({super.key});

  @override
  State<AssetSearchScreen> createState() => _AssetSearchScreenState();
}

class _AssetSearchScreenState extends State<AssetSearchScreen> {
  String _query = '';
  String _kind = 'ALL';

  @override
  Widget build(BuildContext context) {
    debugPrint('🟠 AssetSearchScreen building - Asset registry list screen');
    final list = DummyData.assets.where((a) {
      if (_kind == 'BRIDGE' && a.kind != AssetKind.bridge) return false;
      if (_kind == 'CULVERT' && a.kind != AssetKind.culvert) return false;
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return a.name.toLowerCase().contains(q) ||
          a.id.toLowerCase().contains(q) ||
          a.city.toLowerCase().contains(q);
    }).toList();

    final pad = Responsive.isTablet(context) ? 32.0 : 16.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.fromLTRB(pad, 12, pad, 16),
              child: const StepHeader(
                title: 'Asset registry',
                subtitle: 'Step 1 of 2 · Select asset',
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(pad),
                child: ContentColumn(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        onChanged: (v) => setState(() => _query = v),
                        decoration: const InputDecoration(
                          hintText: 'Asset ID, name or city',
                          prefixIcon: Icon(Icons.search,
                              color: AppColors.textTertiary, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        for (final f in const ['ALL', 'BRIDGE', 'CULVERT'])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _kind = f),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _kind == f
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: _kind == f
                                          ? Colors.transparent
                                          : AppColors.border),
                                ),
                                child: Text(
                                  f,
                                  style: TextStyle(
                                    color: _kind == f
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ]),
                      const SizedBox(height: 18),
                      for (final a in list) ...[
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AssetDetailScreen(asset: a)),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(children: [
                              AssetThumbnail(tag: a.kind.tag),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(a.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${a.id} · ${a.region} · ${a.city}',
                                      style: const TextStyle(
                                          color: AppColors.textTertiary,
                                          fontSize: 12.5),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.textTertiary),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
