import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/rundown_item_entity.dart';

/// Card widget rendering a single rundown item adhering strictly to ui-design-guide.md.
class RundownCardWidget extends StatelessWidget {
  final RundownItemEntity item;
  final bool isLast;

  const RundownCardWidget({
    super.key,
    required this.item,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final status = item.status;
    final timeRange = DateFormatter.formatTimeRange(item.startTime, item.endTime);

    switch (status) {
      case RundownStatus.completed:
        return _buildCompletedCard(context, timeRange);
      case RundownStatus.active:
        return _buildActiveCard(context, timeRange);
      case RundownStatus.pending:
        return _buildUpcomingCard(context, timeRange);
    }
  }

  // -------------------------------------------------------------
  // Item 1 (Past / Finished): Muted Gray, Strike-through or Check Icon
  // -------------------------------------------------------------
  Widget _buildCompletedCard(BuildContext context, String timeRange) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slateGray.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeRange,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.softGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.charcoalBlack,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, size: 12, color: AppColors.softGray),
                    const SizedBox(width: 4),
                    Text(
                      'Selesai',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.softGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.softGray,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.softGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${item.zone} • PIC: ${item.picName}${item.picRole != null ? " (${item.picRole})" : ""}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.softGray.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Item 2 (CURRENT ACTIVE CUE - Prominent Focus):
  // 1.5px Emerald Green border, green dot indicator, [SEDANG BERLANGSUNG]
  // -------------------------------------------------------------
  Widget _buildActiveCard(BuildContext context, String timeRange) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.slateGray,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.emeraldGreen,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldGreen.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.emeraldGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timeRange,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pureWhite,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emeraldGreenTint,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.emeraldGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'SEDANG BERLANGSUNG',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppColors.emeraldGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.pureWhite,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 14, color: AppColors.skyBlue),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${item.zone} • PIC: ${item.picName}${item.picRole != null ? " (${item.picRole})" : ""}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.pureWhite.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.description!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.softGray,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Item 3 (Next Upcoming): Flat card with 1px border, [Berikutnya]
  // -------------------------------------------------------------
  Widget _buildUpcomingCard(BuildContext context, String timeRange) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slateGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeRange,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.softGray,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.charcoalBlack,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Berikutnya',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.softGray,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.pureWhite,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${item.zone} • PIC: ${item.picName}${item.picRole != null ? " (${item.picRole})" : ""}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.softGray,
            ),
          ),
        ],
      ),
    );
  }
}
