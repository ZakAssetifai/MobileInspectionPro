import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import '../widgets/primary_button.dart';

/// "New asset on the field" modal — matches the tablet design video.
///
/// Opens as a centred bottom-sheet (mobile) or centred dialog (tablet),
/// drops a pin at the inspector's current coords, and lets them fill in
/// asset type, name, location, attributes, and photos before creating +
/// immediately starting an inspection.
class NewAssetDialog extends StatefulWidget {
  const NewAssetDialog({super.key, required this.pinLat, required this.pinLng});
  final double pinLat;
  final double pinLng;

  /// Convenience launcher. Returns the newly-created [Asset] or `null`.
  static Future<Asset?> show(BuildContext context,
      {required double lat, required double lng}) {
    final isTablet = Responsive.isTablet(context);
    if (isTablet) {
      return showDialog<Asset>(
        context: context,
        barrierColor: Colors.black54,
        builder: (_) => Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 700),
            child: NewAssetDialog(pinLat: lat, pinLng: lng),
          ),
        ),
      );
    }
    return showModalBottomSheet<Asset>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.6,
        maxChildSize: 0.96,
        builder: (_, controller) => Material(
          color: AppColors.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: NewAssetDialog(pinLat: lat, pinLng: lng),
        ),
      ),
    );
  }

  @override
  State<NewAssetDialog> createState() => _NewAssetDialogState();
}

enum _AssetType { bridge, culvert, tunnel, underpass, footbridge }

extension _AssetTypeX on _AssetType {
  String get tag {
    switch (this) {
      case _AssetType.bridge:     return 'BR';
      case _AssetType.culvert:    return 'CV';
      case _AssetType.tunnel:     return 'TN';
      case _AssetType.underpass:  return 'UP';
      case _AssetType.footbridge: return 'FB';
    }
  }

  String get label {
    switch (this) {
      case _AssetType.bridge:     return 'Bridge';
      case _AssetType.culvert:    return 'Culvert';
      case _AssetType.tunnel:     return 'Tunnel';
      case _AssetType.underpass:  return 'Underpass';
      case _AssetType.footbridge: return 'Footbridge';
    }
  }

  AssetKind get kind => this == _AssetType.culvert
      ? AssetKind.culvert
      : AssetKind.bridge;
}

class _NewAssetDialogState extends State<NewAssetDialog> {
  _AssetType _type = _AssetType.bridge;
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _province = TextEditingController();
  final _yearBuilt = TextEditingController();
  String? _primaryMaterial;
  final _length = TextEditingController();
  final _width = TextEditingController();
  final _height = TextEditingController();
  final _lanes = TextEditingController();
  String? _deckSurface;
  final _traffic = TextEditingController();
  final _skew = TextEditingController();
  int _photoCount = 0;

  static const _materials = ['Reinforced concrete', 'Pre-stressed concrete',
      'Steel girder', 'Steel-concrete composite', 'Masonry', 'Timber'];
  static const _surfaces = ['Asphalt Concrete', 'Concrete', 'Steel deck',
      'Timber', 'Gravel', 'Composite'];

  void _submit() {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }
    final id =
        '${_type.tag}-NEW-${DateTime.now().millisecondsSinceEpoch % 1000}';
    final asset = Asset(
      id: id,
      name: _name.text.trim(),
      kind: _type.kind,
      region: _province.text.trim().isEmpty ? 'Riyadh' : _province.text.trim(),
      city: _location.text.trim().isEmpty ? 'Field' : _location.text.trim(),
      yearBuilt: int.tryParse(_yearBuilt.text.trim()) ?? DateTime.now().year,
      length: double.tryParse(_length.text.trim()) ?? 0,
      material: _primaryMaterial ?? '—',
      lat: widget.pinLat,
      lng: widget.pinLng,
    );
    Navigator.pop(context, asset);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ---- Header (title + close) ----
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('New asset on the field',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 17)),
                  const SizedBox(height: 2),
                  Text(
                    'Pin placed at ${widget.pinLat.toStringAsFixed(4)}, '
                    '${widget.pinLng.toStringAsFixed(4)}. '
                    'A new Asset ID will be generated automatically.',
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
            ),
          ]),
        ),
        const Divider(height: 1, color: AppColors.border),

        // ---- Scrolling body ----
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('ASSET TYPE'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    for (final t in _AssetType.values)
                      _TypeCard(
                        tag: t.tag,
                        label: t.label,
                        selected: _type == t,
                        onTap: () => setState(() => _type = t),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                const _FieldLabel('Name *'),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(hintText: 'Bridge name'),
                ),
                const SizedBox(height: 12),

                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Location'),
                        TextField(
                          controller: _location,
                          decoration:
                              const InputDecoration(hintText: 'e.g. Ring Road'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Province'),
                        TextField(
                          controller: _province,
                          decoration:
                              const InputDecoration(hintText: 'e.g. Riyadh'),
                        ),
                      ],
                    ),
                  ),
                ]),

                const SizedBox(height: 18),
                const _SectionLabel('ATTRIBUTES'),
                const SizedBox(height: 8),
                const _FieldLabel('Year built'),
                TextField(
                  controller: _yearBuilt,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),

                const _FieldLabel('Primary material'),
                _Dropdown<String>(
                  value: _primaryMaterial,
                  hint: 'Choose…',
                  items: _materials,
                  onChanged: (v) => setState(() => _primaryMaterial = v),
                ),
                const SizedBox(height: 10),

                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Length (m)'),
                            TextField(
                                controller: _length,
                                keyboardType: TextInputType.number),
                          ])),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Width (m)'),
                            TextField(
                                controller: _width,
                                keyboardType: TextInputType.number),
                          ])),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Height / clearance (m)'),
                            TextField(
                                controller: _height,
                                keyboardType: TextInputType.number),
                          ])),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Lanes'),
                            TextField(
                                controller: _lanes,
                                keyboardType: TextInputType.number),
                          ])),
                ]),
                const SizedBox(height: 10),

                const _FieldLabel('Deck / surface'),
                _Dropdown<String>(
                  value: _deckSurface,
                  hint: 'Choose…',
                  items: _surfaces,
                  onChanged: (v) => setState(() => _deckSurface = v),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Traffic (AADT)'),
                            TextField(
                                controller: _traffic,
                                keyboardType: TextInputType.number),
                          ])),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Skew angle (°)'),
                            TextField(
                                controller: _skew,
                                keyboardType: TextInputType.number),
                          ])),
                ]),
                const SizedBox(height: 18),

                const _SectionLabel('PHOTOS'),
                const SizedBox(height: 8),
                Row(children: [
                  if (_photoCount > 0)
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.thumbnailMint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${_photoCount} ↑',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  if (_photoCount > 0) const SizedBox(width: 8),
                  _AddPhoto(onTap: () => setState(() => _photoCount++)),
                ]),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // ---- Footer actions ----
        const Divider(height: 1, color: AppColors.border),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Create & inspect',
              icon: Icons.arrow_forward,
              expanded: false,
              onPressed: _submit,
            ),
          ]),
        ),
      ],
    );
  }
}

// =================================================================
//  Small UI bits
// =================================================================

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 1.2));
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13)),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.tag,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String tag, label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Material(
        color: selected ? AppColors.primaryLight : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 1.5 : 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tag,
                    style: TextStyle(
                        color: selected
                            ? AppColors.primaryDeep
                            : AppColors.textTertiary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1)),
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                        color: selected
                            ? AppColors.primaryDeep
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
  });
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(hint,
              style: const TextStyle(color: AppColors.textTertiary)),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textTertiary),
          items: items
              .map((t) => DropdownMenuItem<T>(
                    value: t,
                    child: Text(t.toString()),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AddPhoto extends StatelessWidget {
  const _AddPhoto({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.border, style: BorderStyle.solid, width: 1.4),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.photo_camera_outlined,
                color: AppColors.textSecondary, size: 22),
            SizedBox(height: 4),
            Text('ADD',
                style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0)),
          ],
        ),
      ),
    );
  }
}
