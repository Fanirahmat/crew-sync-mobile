import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../domain/entities/event_entity.dart';
import '../providers/event_providers.dart';
import 'rundown_timeline_screen.dart';

/// Screen displaying active events assigned to the logged-in crew member.
class EventListScreen extends ConsumerWidget {
  const EventListScreen({super.key});

  static const String routeName = '/events';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final eventsAsync = ref.watch(eventListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        title: Text(
          'Jadwal Acara Lapangan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.softGray),
            tooltip: 'Keluar',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        backgroundColor: AppColors.slateGray,
        color: AppColors.skyBlue,
        onRefresh: () => ref.read(eventListNotifierProvider.notifier).refresh(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user != null) ...[
                Text(
                  'Halo, ${user.name}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pureWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Peran: ${user.role} • ${user.vendorName ?? "Vendor Mitra"}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.softGray,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                'ACARA AKTIF ANDA',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.softGray,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: eventsAsync.when(
                  data: (events) {
                    if (events.isEmpty) {
                      // Demo fallback default event so crew can test immediately
                      final demoEvent = EventEntity(
                        id: 'evt_wedding_rian_sasa',
                        title: 'Pernikahan Rian & Sasa',
                        clientName: 'Rian & Sasa',
                        venueName: 'Grand Ballroom Hotel Mulia',
                        venueAddress: 'Jl. Asia Afrika Senayan, Jakarta',
                        venueLat: -6.2195,
                        venueLng: 106.8000,
                        geofenceRadiusMeters: 100,
                        eventDate: DateTime(2026, 10, 11),
                        isOfflineCached: true,
                      );
                      return _buildEventList(context, [demoEvent]);
                    }
                    return _buildEventList(context, events);
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.skyBlue),
                  ),
                  error: (err, _) => Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                            onPressed: () => ref.read(eventListNotifierProvider.notifier).refresh(),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventList(BuildContext context, List<EventEntity> events) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.slateGray,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.charcoalBlack,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
              ),
              child: const Icon(Icons.event_note, color: AppColors.skyBlue, size: 22),
            ),
            title: Text(
              event.title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.pureWhite,
                fontSize: 15,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${event.venueName} • ${DateFormatter.formatDate(event.eventDate)}',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.softGray),
                ),
                if (event.isOfflineCached) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.offline_pin, size: 12, color: AppColors.emeraldGreen),
                      const SizedBox(width: 4),
                      Text(
                        'Offline Cache Tersimpan',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.emeraldGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.softGray),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RundownTimelineScreen(event: event),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
