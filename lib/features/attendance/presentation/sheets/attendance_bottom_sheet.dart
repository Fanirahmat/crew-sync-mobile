import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/geofence_service.dart';
import '../../../events/domain/entities/event_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import '../providers/attendance_providers.dart';
import '../widgets/geofence_radar_card.dart';
import '../widgets/verification_option_card.dart';

/// Screen 3: Presensi Kehadiran Geofence & Dual-Method (AttendanceSheet)
/// Implements specifications from ui-design-guide.md.
class AttendanceBottomSheet extends ConsumerStatefulWidget {
  final EventEntity event;

  const AttendanceBottomSheet({
    super.key,
    required this.event,
  });

  @override
  ConsumerState<AttendanceBottomSheet> createState() => _AttendanceBottomSheetState();
}

class _AttendanceBottomSheetState extends ConsumerState<AttendanceBottomSheet> {
  AttendanceType _selectedType = AttendanceType.checkIn;
  bool _isActionLoading = false;

  void _showWarningOutsideGeofence({
    required VoidCallback onProceed,
    required int distanceMeters,
    required int allowedRadiusMeters,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.slateGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.amberOrange, size: 24),
            const SizedBox(width: 8),
            Text(
              'Di Luar Radius Venue',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.pureWhite,
              ),
            ),
          ],
        ),
        content: Text(
          'Jarak Anda ($distanceMeters meter) melebihi batas radius venue ($allowedRadiusMeters meter).\n\nPresensi akan dicatat dengan tanda "Di Luar Radius" untuk ditinjau oleh Koordinator Lapangan. Lanjutkan?',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.pureWhite.withValues(alpha: 0.9),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: AppColors.softGray),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amberOrange,
              foregroundColor: AppColors.charcoalBlack,
              minimumSize: const Size(100, 40),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onProceed();
            },
            child: Text(
              'Tetap Kirim',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBiometric(GeofenceStatusResult geofence) async {
    if (!geofence.isWithinGeofence) {
      _showWarningOutsideGeofence(
        distanceMeters: geofence.distanceMeters.round(),
        allowedRadiusMeters: geofence.allowedRadiusMeters,
        onProceed: () => _executeBiometric(geofence),
      );
      return;
    }
    await _executeBiometric(geofence);
  }

  Future<void> _executeBiometric(GeofenceStatusResult geofence) async {
    setState(() => _isActionLoading = true);
    try {
      final result = await ref
          .read(attendanceSubmissionNotifierProvider.notifier)
          .submitBiometric(
            event: widget.event,
            type: _selectedType,
            geofence: geofence,
          );

      if (result != null && mounted) {
        _showSuccessSnackbar('Presensi Biometrik Berhasil Dicatat!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _handlePhoto(GeofenceStatusResult geofence) async {
    if (!geofence.isWithinGeofence) {
      _showWarningOutsideGeofence(
        distanceMeters: geofence.distanceMeters.round(),
        allowedRadiusMeters: geofence.allowedRadiusMeters,
        onProceed: () => _executePhoto(geofence),
      );
      return;
    }
    await _executePhoto(geofence);
  }

  Future<void> _executePhoto(GeofenceStatusResult geofence) async {
    final imageService = ref.read(imageServiceProvider);
    final photo = await imageService.captureSelfie();

    if (photo == null) return;

    setState(() => _isActionLoading = true);
    try {
      final result = await ref
          .read(attendanceSubmissionNotifierProvider.notifier)
          .submitPhoto(
            event: widget.event,
            type: _selectedType,
            geofence: geofence,
            photoFile: photo,
          );

      if (result != null && mounted) {
        _showSuccessSnackbar('Presensi Swafoto Berhasil Terkirim!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  void _showSuccessSnackbar(String msg) {
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
            Text(msg, style: GoogleFonts.poppins(color: AppColors.pureWhite)),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.crimsonRed,
        behavior: SnackBarBehavior.floating,
        content: Text(msg, style: GoogleFonts.poppins(color: AppColors.pureWhite)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final geofenceAsync = ref.watch(geofenceEvaluationProvider(widget.event));

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.charcoalBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Drag Handle Line at Top Center
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title: "Presensi Lapangan"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Presensi Lapangan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pureWhite,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.softGray, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Type Toggle: Check-In vs Check-Out
            Container(
              decoration: BoxDecoration(
                color: AppColors.slateGray,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = AttendanceType.checkIn),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedType == AttendanceType.checkIn
                              ? AppColors.skyBlue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Tiba di Venue (In)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _selectedType == AttendanceType.checkIn
                                ? AppColors.charcoalBlack
                                : AppColors.softGray,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedType = AttendanceType.checkOut),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedType == AttendanceType.checkOut
                              ? AppColors.skyBlue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Selesai Shift (Out)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _selectedType == AttendanceType.checkOut
                                ? AppColors.charcoalBlack
                                : AppColors.softGray,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. GEOFENCE STATUS RADAR
            geofenceAsync.when(
              data: (result) => GeofenceRadarCard(
                result: result,
                onRetry: () => ref.refresh(geofenceEvaluationProvider(widget.event)),
              ),
              loading: () => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.slateGray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.skyBlue),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Mengevaluasi koordinat GPS kru...',
                      style: GoogleFonts.poppins(color: AppColors.softGray, fontSize: 13),
                    ),
                  ],
                ),
              ),
              error: (err, _) => GeofenceRadarCard(
                result: GeofenceStatusResult.error(
                  message: err.toString(),
                  allowedRadiusMeters: widget.event.geofenceRadiusMeters,
                ),
                onRetry: () => ref.refresh(geofenceEvaluationProvider(widget.event)),
              ),
            ),
            const SizedBox(height: 24),

            // 3. SELECTION SECTION (Dual Verification Methods)
            Text(
              'PILIH METODE VERIFIKASI',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.0,
                color: AppColors.softGray,
              ),
            ),
            const SizedBox(height: 12),

            // Option Card A (Biometric)
            VerificationOptionCard(
              icon: Icons.fingerprint_rounded,
              title: 'Presensi Biometrik',
              description: 'Gunakan sidik jari atau Face ID perangkat',
              isLoading: _isActionLoading,
              onTap: () {
                final geofence = geofenceAsync.value ??
                    GeofenceStatusResult.error(
                      message: 'Lokasi belum terbaca',
                      allowedRadiusMeters: widget.event.geofenceRadiusMeters,
                    );
                _handleBiometric(geofence);
              },
            ),
            const SizedBox(height: 12),

            // Option Card B (Photo Selfie)
            VerificationOptionCard(
              icon: Icons.camera_alt_outlined,
              title: 'Presensi Swafoto',
              description: 'Ambil foto diri di area venue',
              isLoading: _isActionLoading,
              onTap: () {
                final geofence = geofenceAsync.value ??
                    GeofenceStatusResult.error(
                      message: 'Lokasi belum terbaca',
                      allowedRadiusMeters: widget.event.geofenceRadiusMeters,
                    );
                _handlePhoto(geofence);
              },
            ),
          ],
        ),
      ),
    );
  }
}
