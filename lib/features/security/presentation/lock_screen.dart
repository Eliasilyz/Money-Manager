import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/features/security/application/security_provider.dart';
import 'package:money_manager/theme/app_colors.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinCtrl = TextEditingController();
  bool _error = false;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerBiometric());
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _offerBiometric() async {
    final service = ref.read(securityServiceProvider);
    if (!mounted) return;
    if (!await service.canUseBiometrics()) return;
    if (!await ref.read(securityServiceProvider).authenticateWithBiometrics()) return;
    _unlock();
  }

  void _unlock() {
    if (!mounted) return;
    ref.read(appLockedProvider.notifier).state = false;
    ref.read(appUnlockedProvider.notifier).state = true;
  }

  Future<void> _verify() async {
    final pin = _pinCtrl.text;
    final ok = await ref.read(securityServiceProvider).verifyPin(pin);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _attempts = 0;
        _error = false;
      });
      _unlock();
    } else {
      _attempts++;
      if (_attempts >= 5) {
        _showLockout();
        return;
      }
      setState(() {
        _error = true;
        _pinCtrl.clear();
      });
    }
  }

  void _showLockout() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Terlalu banyak percobaan', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Text('Coba lagi dalam 1 menit.', style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Future.delayed(const Duration(seconds: 60));
              if (!mounted) return;
              setState(() => _attempts = 0);
            },
            child: const Text('Tunggu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsT.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: colors.primaryDark,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.lock_outline, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text('Money Manager', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: colors.textPrimary)),
                const SizedBox(height: 8),
                Text('Masukkan PIN untuk melanjutkan', style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary)),
                const SizedBox(height: 24),
                TextField(
                  controller: _pinCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  onSubmitted: (_) => _verify(),
                  autofocus: true,
                  style: GoogleFonts.inter(fontSize: 20, letterSpacing: 8, color: colors.textPrimary),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                    errorText: _error ? 'PIN salah, coba lagi' : null,
                    filled: true,
                    fillColor: colors.surface,
                    errorStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.rose),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _verify,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.bg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Buka', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
                FutureBuilder<bool>(
                  future: ref.read(securityServiceProvider).canUseBiometrics(),
                  builder: (context, snap) {
                    if (snap.data != true) return const SizedBox.shrink();
                    return Column(children: [
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _offerBiometric,
                        icon: const Icon(Icons.fingerprint, color: AppColors.gold),
                        label: Text('Gunakan biometrik', style: GoogleFonts.inter(fontSize: 13, color: AppColors.gold)),
                      ),
                    ]);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}