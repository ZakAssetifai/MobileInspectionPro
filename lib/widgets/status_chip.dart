import 'package:flutter/material.dart';
import '../data/models.dart';
import '../theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final InspectionStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case InspectionStatus.draft:
        bg = AppColors.statusDraftBg;
        fg = AppColors.statusDraft;
        break;
      case InspectionStatus.submitted:
        bg = AppColors.statusSubmittedBg;
        fg = AppColors.statusSubmitted;
        break;
      case InspectionStatus.synced:
        bg = AppColors.statusSyncedBg;
        fg = AppColors.statusSynced;
        break;
      case InspectionStatus.assigned:
        bg = const Color(0xFFE9EEF2);
        fg = AppColors.textSecondary;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class KindChip extends StatelessWidget {
  const KindChip({super.key, required this.kind});
  final InspectionKind kind;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (kind) {
      case InspectionKind.routine:
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        break;
      case InspectionKind.detailed:
        bg = AppColors.primaryLight;
        fg = AppColors.primaryDeep;
        break;
      case InspectionKind.damage:
        bg = AppColors.statusDraftBg;
        fg = AppColors.statusDraft;
        break;
      case InspectionKind.emergency:
        bg = const Color(0xFFFADADA);
        fg = AppColors.severityCritical;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        kind.label,
        style: TextStyle(
          color: fg,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class SeverityChip extends StatelessWidget {
  const SeverityChip({super.key, required this.severity});
  final DefectSeverity severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: severity.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
                color: severity.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            severity.label,
            style: TextStyle(
              color: severity.color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class RatingChip extends StatelessWidget {
  const RatingChip({super.key, required this.rating});
  final ConditionRating rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: rating.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        rating.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class AssetThumbnail extends StatelessWidget {
  const AssetThumbnail({super.key, required this.tag, this.size = 44});
  final String tag;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = tag == 'BR';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? AppColors.thumbnailTeal : AppColors.thumbnailMint,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        tag,
        style: TextStyle(
          color: dark ? Colors.white : AppColors.thumbnailTeal,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.32,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
