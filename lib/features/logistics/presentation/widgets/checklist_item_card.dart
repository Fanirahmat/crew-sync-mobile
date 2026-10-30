import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/checklist_item_entity.dart';

/// Card component rendering an inventory checklist item according to Layar 4 UI specifications.
class ChecklistItemCard extends StatefulWidget {
  final ChecklistItemEntity item;
  final Function({
    required int actualQuantity,
    required ItemCondition condition,
    File? photoEvidence,
  }) onVerify;
  final VoidCallback onTakePhoto;
  final File? selectedPhoto;

  const ChecklistItemCard({
    super.key,
    required this.item,
    required this.onVerify,
    required this.onTakePhoto,
    this.selectedPhoto,
  });

  @override
  State<ChecklistItemCard> createState() => _ChecklistItemCardState();
}

class _ChecklistItemCardState extends State<ChecklistItemCard> {
  late int _actualCount;
  late ItemCondition _selectedCondition;

  @override
  void initState() {
    super.initState();
    _actualCount = widget.item.actualQuantity > 0
        ? widget.item.actualQuantity
        : widget.item.targetQuantity;
    _selectedCondition = widget.item.condition;
  }

  @override
  void didUpdateWidget(covariant ChecklistItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      _actualCount = widget.item.actualQuantity > 0
          ? widget.item.actualQuantity
          : widget.item.targetQuantity;
      _selectedCondition = widget.item.condition;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.isVerified) {
      return _buildVerifiedCard();
    } else {
      return _buildUnverifiedCard();
    }
  }

  // -------------------------------------------------------------
  // Item Card 1: Verified Good
  // -------------------------------------------------------------
  Widget _buildVerifiedCard() {
    final conditionName = widget.item.condition.toDisplayName();
    final verifiedBy = widget.item.verifiedBy ?? 'Kru Lapangan';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slateGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.item.itemName} (${widget.item.actualQuantity} ${widget.item.unit})',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pureWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dicek oleh $verifiedBy • Fisik: $conditionName',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.softGray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Trailing green checkmark
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.emeraldGreenTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.emeraldGreen,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Item Card 2: Unverified / Attention Needed
  // -------------------------------------------------------------
  Widget _buildUnverifiedCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slateGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Title
          Text(
            '${widget.item.itemName} (${widget.item.targetQuantity} ${widget.item.unit})',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.pureWhite,
            ),
          ),
          const SizedBox(height: 12),

          // Stepper Counter Row: "Target: 4 Unit | Aktual: [ - 3 + ]"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: ${widget.item.targetQuantity} ${widget.item.unit}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.softGray,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Aktual: ',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.softGray),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.charcoalBlack,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            if (_actualCount > 0) {
                              setState(() => _actualCount--);
                            }
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Icon(Icons.remove, size: 16, color: AppColors.pureWhite),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '$_actualCount',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.skyBlue,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _actualCount++),
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Icon(Icons.add, size: 16, color: AppColors.pureWhite),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Condition Pills: [Baik] | [Rusak] | [Hilang]
          Row(
            children: [
              _buildConditionPill(ItemCondition.good, 'Baik'),
              const SizedBox(width: 8),
              _buildConditionPill(ItemCondition.damaged, 'Rusak'),
              const SizedBox(width: 8),
              _buildConditionPill(ItemCondition.missing, 'Hilang'),
            ],
          ),
          const SizedBox(height: 14),

          // Action Row: Camera Button + Outline Button "Verifikasi"
          Row(
            children: [
              // Camera button with photo preview if attached
              InkWell(
                onTap: widget.onTakePhoto,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.charcoalBlack,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.selectedPhoto != null
                          ? AppColors.emeraldGreen
                          : AppColors.borderSubtle,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 16,
                        color: widget.selectedPhoto != null
                            ? AppColors.emeraldGreen
                            : AppColors.softGray,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.selectedPhoto != null ? 'Foto Terlampir' : 'Foto Bukti',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: widget.selectedPhoto != null
                              ? AppColors.emeraldGreen
                              : AppColors.softGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Outline button "Verifikasi"
              OutlinedButton(
                onPressed: () {
                  widget.onVerify(
                    actualQuantity: _actualCount,
                    condition: _selectedCondition,
                    photoEvidence: widget.selectedPhoto,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.skyBlue,
                  side: const BorderSide(color: AppColors.skyBlue, width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Verifikasi',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConditionPill(ItemCondition condition, String label) {
    final isSelected = _selectedCondition == condition;
    Color activeColor = AppColors.skyBlue;
    if (condition == ItemCondition.good) activeColor = AppColors.emeraldGreen;
    if (condition == ItemCondition.damaged) activeColor = AppColors.crimsonRed;
    if (condition == ItemCondition.missing) activeColor = AppColors.amberOrange;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCondition = condition),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.2) : AppColors.charcoalBlack,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.borderSubtle,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? activeColor : AppColors.softGray,
            ),
          ),
        ),
      ),
    );
  }
}
