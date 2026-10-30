import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/rundown_item_entity.dart';
import '../../../attendance/presentation/sheets/attendance_bottom_sheet.dart';
import '../../../logistics/presentation/screens/logistics_screen.dart';
import '../providers/event_providers.dart';
import '../widgets/rundown_card_widget.dart';

/// Screen 2: Live Rundown & FCM Cue (RundownTimelinePage)
/// Implements specifications from ui-design-guide.md.
class RundownTimelineScreen extends ConsumerStatefulWidget {
  final EventEntity event;

  const RundownTimelineScreen({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<RundownTimelineScreen> createState() => _RundownTimelineScreenState();
}

class _RundownTimelineScreenState extends ConsumerState<RundownTimelineScreen> {
  @override
  Widget build(BuildContext context) {
    final rundownAsync = ref.watch(rundownNotifierProvider(widget.event.id));

    // Listen to real-time live cues and show a subtle top banner/cue
    ref.listen(rundownNotifierProvider(widget.event.id), (previous, next) {
      final prevList = previous?.value;
      final currentList = next.value;

      if (prevList != null && currentList != null) {
        RundownItemEntity? newlyActive;
        for (final item in currentList) {
          if (item.status == RundownStatus.active &&
              prevList.any((p) => p.id == item.id && p.status != RundownStatus.active)) {
            newlyActive = item;
            break;
          }
        }

        if (newlyActive != null && mounted) {
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
                  const Icon(Icons.notifications_active, color: AppColors.emeraldGreen, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'CUE AKTIF: ${newlyActive.title}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppColors.pureWhite,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      // 1. HEADER & CONTEXT
      appBar: AppBar(
        backgroundColor: AppColors.charcoalBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.pureWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.event.title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined, color: AppColors.pureWhite, size: 22),
            tooltip: 'Checklist Logistik',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LogisticsScreen(event: widget.event),
                ),
              );
            },
          ),
          // Subtle offline cache pill "[Offline Siap ✓]"
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.slateGray,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, size: 12, color: AppColors.emeraldGreen),
                  const SizedBox(width: 4),
                  Text(
                    'Offline Siap ✓',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.pureWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.softGray),
                const SizedBox(width: 4),
                Text(
                  widget.event.venueName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.softGray,
                  ),
                ),
                const SizedBox(width: 12),
                Text('•', style: GoogleFonts.poppins(color: AppColors.softGray)),
                const SizedBox(width: 12),
                Text(
                  DateFormatter.formatDate(widget.event.eventDate),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.softGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // 2. MAIN CONTENT (Vertical Chronological Timeline)
      body: Stack(
        children: [
          RefreshIndicator(
            backgroundColor: AppColors.slateGray,
            color: AppColors.skyBlue,
            onRefresh: () => ref.read(rundownNotifierProvider(widget.event.id).notifier).refresh(),
            child: rundownAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada susunan rundown untuk acara ini.',
                      style: GoogleFonts.poppins(color: AppColors.softGray),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 96), // Bottom padding for docked button
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return RundownCardWidget(
                      item: item,
                      isLast: index == items.length - 1,
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
                            .read(rundownNotifierProvider(widget.event.id).notifier)
                            .refresh(),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. BOTTOM FLOATING BAR: Quick action button docked at bottom
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoalBlack.withValues(alpha: 0.9),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Wire into Phase 4: Attendance Sheet
                  _openAttendanceSheet(context);
                },
                icon: const Icon(Icons.location_on, color: AppColors.charcoalBlack),
                label: Text(
                  'Buka Presensi Hari Ini',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalBlack,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.skyBlue,
                  foregroundColor: AppColors.charcoalBlack,
                  minimumSize: const Size.fromHeight(54),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAttendanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AttendanceBottomSheet(event: widget.event),
    );
  }
}
