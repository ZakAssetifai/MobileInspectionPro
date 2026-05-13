import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';
import 'status_chip.dart';

class InspectionCard extends StatelessWidget {
  const InspectionCard({
    super.key,
    required this.inspection,
    this.dense = false,
    this.showId = true,
    this.onTap,
    this.onDelete,
  });

  final Inspection inspection;
  final bool dense;
  final bool showId;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final i = inspection;
    final dateStr =
        '${i.started.day.toString().padLeft(2, '0')}/${i.started.month.toString().padLeft(2, '0')}/${i.started.year}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            AssetThumbnail(tag: i.asset.kind.tag),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    i.asset.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  if (showId) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${i.asset.id}  ·  ${i.kind.label.toLowerCase()}',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (!dense) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${i.asset.region} · ${i.asset.city}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today_outlined,
                            size: 13, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusChip(status: i.status),
            const SizedBox(width: 8),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(CupertinoIcons.delete,
                    size: 18, color: AppColors.severityHigh),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.severityHigh.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(36, 36),
                ),
              )
            else
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
