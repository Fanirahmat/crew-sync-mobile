import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../events/presentation/screens/event_list_screen.dart';
import '../providers/auth_provider.dart';

/// Screen 1: Login & Autentikasi (/login)
/// Strict implementation of ui-design-guide.md specifications.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authControllerProvider.notifier).login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.slateGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Bantuan Akun Kru',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.pureWhite,
          ),
        ),
        content: Text(
          'Kredensial kru lapangan dibuat dan dikelola oleh Stage Manager atau Koordinator Vendor Anda.\n\nJika lupa kata sandi atau akun belum terdaftar, silakan hubungi Koordinator Lapangan Anda.',
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
              'Mengerti',
              style: GoogleFonts.poppins(
                color: AppColors.skyBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state transitions
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.crimsonRed,
              behavior: SnackBarBehavior.floating,
              content: Text(
                error.toString(),
                style: GoogleFonts.poppins(color: AppColors.pureWhite),
              ),
            ),
          );
        },
        data: (user) {
          if (user != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const EventListScreen()),
            );
          }
        },
      );
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. TOP AREA: Minimalist Monochrome Brand Mark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.slateGray,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.sync_alt_rounded,
                          color: AppColors.pureWhite,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'CrewSync - Field Ops',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: AppColors.pureWhite,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Headline & Helper Text
                  Text(
                    'Masuk ke Akun Kru',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pureWhite,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gunakan nomor HP atau email yang didaftarkan vendor',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.softGray,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  // 2. INPUT FORM (Single Column, Flat Cards)
                  // Input 1: Nomor WhatsApp / Email
                  Text(
                    'Nomor WhatsApp / Email',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.pureWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _identifierController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(color: AppColors.pureWhite),
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 08123456789 atau kru@vendor.com',
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.softGray,
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nomor WhatsApp atau Email wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Input 2: Kata Sandi
                  Text(
                    'Kata Sandi',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.pureWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.poppins(color: AppColors.pureWhite),
                    decoration: InputDecoration(
                      hintText: 'Masukkan kata sandi akun',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.softGray,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.softGray,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Kata sandi wajib diisi';
                      }
                      if (val.length < 6) {
                        return 'Kata sandi minimal 6 karakter';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _submitLogin(),
                  ),
                  const SizedBox(height: 32),

                  // 3. ACTIONS
                  // Primary Full-Width Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitLogin,
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.charcoalBlack,
                            ),
                          )
                        : Text(
                            'Masuk',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoalBlack,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Text Link Below Button
                  Center(
                    child: GestureDetector(
                      onTap: _showHelpDialog,
                      child: Text(
                        'Lupa kata sandi? Hubungi Koordinator',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.softGray,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
