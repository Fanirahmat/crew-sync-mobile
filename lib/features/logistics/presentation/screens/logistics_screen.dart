import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/image_service.dart';
import '../../../events/domain/entities/event_entity.dart';
import '../../domain/entities/checklist_item_entity.dart';
import '../providers/logistics_providers.dart';
import '../widgets/checklist_item_card.dart';

/// Screen 4: Checklist Logistik Lapangan (LogisticsScreen)
/// Strict implementation of ui-design-guide.md specifications.
class LogisticsScreen extends ConsumerStatefulWidget {
  final EventEntity event;

  const LogisticsScreen({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<LogisticsScreen> createState() => _LogisticsScreenState();
}

class _LogisticsScreenState extends ConsumerState<LogisticsScreen> {
  ChecklistStage _selectedStage = ChecklistStage.loadIn;
  final Map<String, File> _attachedPhotos = {};

  Future<void> _handleCaptureEvidence(String itemId) async {
    final imageService = ImageService();
    final file = await imageService.captureEvidence();
    if (file != null && mounted) {
      setState(() {
        _attachedPhotos[itemId] = file;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.slateGray,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Foto bukti fisik terlampir!',
            style: GoogleFonts.poppins(color: AppColors.pureWhite),
          ),
        ),
      );
    }
  }

  Future<void> _handleVerify({
    required String itemId,
    required int actualQuantity,
    required ItemCondition condition,
    File? photoEvidence,
  }) async {
    try {
      await ref.read(logisticsNotifierProvider(widget.event.id).notifier).verifyItem(
            itemId: itemId,
            actualQuantity: actualQuantity,
            condition: condition,
            photoEvidence: photoEvidence,
          );

      if (mounted) {
        setState(() {
          _attachedPhotos.remove(itemId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.slateGray,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.emeraldGreen, width: 1.5),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.emeraldGreen),
                const SizedBox(width: 10),
                Text(
                  'Barang berhasil diverifikasi!',
                  style: GoogleFonts.poppins(color: AppColors.pureWhite),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.crimsonRed,
            content: Text(
              'Gagal verifikasi: $e',
              style: GoogleFonts.poppins(color: AppColors.pureWhite),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final checklistAsync = ref.watch(logisticsNotifierProvider(widget.event.id));

    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        title: Text(
          'Logistik: ${widget.event.title}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          // 1. TOP NAVIGATION: Segmented Control / Flat Tab Bar
          Container(
            color: AppColors.charcoalBlack,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _buildSegmentedTab(ChecklistStage.loadIn, 'Load-In'),
                const SizedBox(width: 8),
                _buildSegmentedTab(ChecklistStage.loadOut, 'Load-Out'),
                const SizedBox(width: 8),
                _buildSegmentedTab(ChecklistStage.postEvent, 'Pasca Acara'),
              ],
            ),
          ),

          // 2. PROGRESS SUMMARY & 4px LINEAR PROGRESS BAR
          checklistAsync.when(
            data: (allItems) => _buildProgressHeader(allItems),
            loading: () => const SizedBox(height: 60),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),

          // 3. CHECKLIST CARD FEED
          Expanded(
            child: RefreshIndicator(
              backgroundColor: AppColors.slateGray,
              color: AppColors.skyBlue,
              onRefresh: () =>
                  ref.read(logisticsNotifierProvider(widget.event.id).notifier).refresh(),
              child: checklistAsync.when(
                data: (allItems) {
                  // Fallback sample data if empty so UI can be previewed/tested immediately
                  final items = allItems.isEmpty
                      ? _getDefaultSampleItems(widget.event.id)
                      : allItems;

                  final stageItems = items.where((i) => i.stage == _selectedStage).toList();

                  if (stageItems.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada barang pada tahap ${_selectedStage.toDisplayName()}.',
                        style: GoogleFonts.poppins(color: AppColors.softGray),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: stageItems.length,
                    itemBuilder: (context, index) {
                      final item = stageItems[index];
                      return ChecklistItemCard(
                        item: item,
                        selectedPhoto: _attachedPhotos[item.id],
                        onTakePhoto: () => _handleCaptureEvidence(item.id),
                        onVerify: ({
                          required actualQuantity,
                          required condition,
                          photoEvidence,
                        }) =>
                            _handleVerify(
                          itemId: item.id,
                          actualQuantity: actualQuantity,
                          condition: condition,
                          photoEvidence: photoEvidence,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.skyBlue),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, color: AppColors.softGray, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: AppColors.pureWhite, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(logisticsNotifierProvider(widget.event.id).notifier)
                              .refresh(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTab(ChecklistStage stage, String title) {
    final isSelected = _selectedStage == stage;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStage = stage),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.skyBlue : AppColors.slateGray,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.skyBlue : AppColors.borderSubtle,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.charcoalBlack : AppColors.softGray,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(List<ChecklistItemEntity> allItems) {
    final stageItems = allItems.isEmpty
        ? _getDefaultSampleItems(widget.event.id).where((i) => i.stage == _selectedStage).toList()
        : allItems.where((i) => i.stage == _selectedStage).toList();

    final total = stageItems.length;
    final verifiedCount = stageItems.where((i) => i.isVerified).length;
    final double percent = total > 0 ? (verifiedCount / total) : 0.0;
    final percentInt = (percent * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$verifiedCount dari $total Barang Terverifikasi ($percentInt%)',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.pureWhite,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 4,
              backgroundColor: AppColors.slateGray,
              color: percentInt == 100 ? AppColors.emeraldGreen : AppColors.skyBlue,
            ),
          ),
        ],
      ),
    );
  }

  List<ChecklistItemEntity> _getDefaultSampleItems(String eventId) {
    return [
      ChecklistItemEntity(
        id: 'chk_1',
        eventId: eventId,
        stage: ChecklistStage.loadIn,
        itemName: 'HT Motorola GP328',
        targetQuantity: 10,
        actualQuantity: 10,
        unit: 'Unit',
        condition: ItemCondition.good,
        verifiedBy: 'Dimas',
        isVerified: true,
      ),
      ChecklistItemEntity(
        id: 'chk_2',
        eventId: eventId,
        stage: ChecklistStage.loadIn,
        itemName: 'Kabel Roll 50m',
        targetQuantity: 4,
        actualQuantity: 3,
        unit: 'Unit',
        condition: ItemCondition.good,
        isVerified: false,
      ),
      ChecklistItemEntity(
        id: 'chk_3',
        eventId: eventId,
        stage: ChecklistStage.loadIn,
        itemName: 'Mic Wireless Shure',
        targetQuantity: 6,
        actualQuantity: 6,
        unit: 'Set',
        condition: ItemCondition.good,
        verifiedBy: 'Budi',
        isVerified: true,
      ),
      ChecklistItemEntity(
        id: 'chk_4',
        eventId: eventId,
        stage: ChecklistStage.loadOut,
        itemName: 'Lighting Bar LED',
        targetQuantity: 8,
        actualQuantity: 0,
        unit: 'Unit',
        condition: ItemCondition.good,
        isVerified: false,
      ),
    ];
  }
}
