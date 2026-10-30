import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/geofence_service.dart';
import '../../../../core/utils/geofence_calculator.dart';

/// Radar Status Geofence Card adhering to Layar 3 UI specifications.
class GeofenceRadarCard extends StatelessWidget {
  final GeofenceStatusResult result;
  final VoidCallback? onRetry;

  const GeofenceRadarCard({
    super.key,
    required this.result,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isValid = result.isWithinGeofence;
    final hasError = result.errorMessage != null;

    final statusColor = isValid
        ? AppColors.emeraldGreen
        : (hasError ? AppColors.amberOrange : AppColors.crimsonRed);
    final statusBgTint = isValid
        ? AppColors.emeraldGreenTint
        : (hasError ? AppColors.amberOrangeTint : AppColors.crimsonRedTint);

    final title = isValid
        ? 'Lokasi Terverifikasi'
        : (hasError ? 'GPS Bermasalah' : 'Di Luar Radius Venue');

    final distanceStr = GeofenceCalculator.formatDistance(result.distanceMeters);
    final subtext = hasError
        ? result.errorMessage!
        : 'Jarak Anda: $distanceStr dari venue (Maks. radius: ${result.allowedRadiusMeters}m)';

    final pillLabel = isValid
        ? 'Di Dalam Radius ✓'
        : (hasError ? 'Perlu Izin GPS' : 'Di Luar Radius ✕');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slateGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid ? AppColors.borderSubtle : statusColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Radar / Pin icon with solid dot indicator
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.charcoalBlack,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSubtle, width: 1),
                    ),
                    child: Icon(
                      Icons.radar_rounded,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.charcoalBlack, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Right: Title, Subtext, and Status Pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.pureWhite,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusBgTint,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1),
                          ),
                          child: Text(
                            pillLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtext,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.softGray,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onRetry != null && (!isValid || hasError)) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 14, color: AppColors.skyBlue),
                label: Text(
                  'Segarkan Lokasi',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.skyBlue),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
