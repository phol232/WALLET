import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';

const kBgTop = Color(0xFF1A2E1F);
const kBgBottom = Color(0xFF0F1A12);
const kCard = Color(0xFF2A3D2F);
const kInput = Color(0xFF1F2A20);
const kStroke = Color(0xFF3A4A3C);
const kAccent = Color(0xFFB9FF3C);
const kTextPrimary = Colors.white;
const kTextSecondary = Color(0xFFB0B8B0);

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  bool _obscure = true;
  int _tabIndex = 1; // 0=Sign In, 1=Sign Up

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final notifier = ref.read(authControllerProvider.notifier);

    // Navigate to home on successful registration (which now includes auto-login)
    if (authState.loginSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
        // Reset success flag
        notifier.clearSuccess();
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBgTop, kBgBottom],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),

                      // ======= BLOQUE PRINCIPAL =======
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _tabIndex == 1 ? 'Crear' : 'Bienvenido de Vuelta',
                            style: const TextStyle(
                              color: kTextPrimary,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.08,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            _tabIndex == 1
                                ? 'Tu Nueva Cuenta'
                                : 'Inicia Sesión para Continuar',
                            style: const TextStyle(
                              color: kTextPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              height: 1.1,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Regístrate con los siguientes métodos',
                            style: TextStyle(
                              color: kTextSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Segmented control
                          Container(
                            decoration: BoxDecoration(
                              color: kCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: kStroke),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                _SegmentTab(
                                  label: 'Iniciar Sesión',
                                  selected: _tabIndex == 0,
                                  onTap: () {
                                    setState(() => _tabIndex = 0);
                                    context.go('/login');
                                  },
                                ),
                                _SegmentTab(
                                  label: 'Registrarse',
                                  selected: _tabIndex == 1,
                                  onTap: () => setState(() => _tabIndex = 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Form
                          const _Label('Nombre Completo'),
                          const SizedBox(height: 8),
                          _Input(
                            hint: 'Tu nombre completo',
                            icon: Icons.person_outline,
                            onChanged: notifier.setName,
                          ),
                          const SizedBox(height: 14),
                          const _Label('Ingresa Email'),
                          const SizedBox(height: 8),
                          _Input(
                            hint: 'tu@ejemplo.com',
                            icon: Icons.mail_outline,
                            onChanged: notifier.setEmail,
                          ),
                          const SizedBox(height: 14),
                          const _Label('Contraseña'),
                          const SizedBox(height: 8),
                          _Input(
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            obscure: _obscure,
                            suffix: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: kTextSecondary,
                              ),
                            ),
                            onChanged: notifier.setPassword,
                          ),
                          const SizedBox(height: 20),

                          // CTA
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () => notifier.register(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kAccent,
                                disabledBackgroundColor: kAccent.withValues(
                                  alpha: 0.5,
                                ),
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Registrarse'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (authState.error != null)
                            Text(
                              authState.error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 10),

                          // Divider "Or"
                          Row(
                            children: [
                              Expanded(
                                child: Container(height: 1, color: kStroke),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Or',
                                  style: TextStyle(color: kTextSecondary),
                                ),
                              ),
                              Expanded(
                                child: Container(height: 1, color: kStroke),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Social
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              _SocialChip(
                                label: 'Google',
                                asset: 'assets/icons/icons8-logo-de-google.svg',
                              ),
                              SizedBox(width: 12),
                              _SocialChip(
                                label: 'GitHub',
                                asset: 'assets/icons/icons8-github.svg',
                              ),
                            ],
                          ),
                        ],
                      ),

                      // ======= FIN BLOQUE PRINCIPAL =======
                      const Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¿Ya tienes una cuenta? ',
                            style: TextStyle(color: kTextSecondary),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text(
                              'Inicia Sesión',
                              style: TextStyle(
                                color: kAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? kAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : kTextSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: kTextSecondary, fontWeight: FontWeight.w600),
  );
}

class _Input extends StatelessWidget {
  const _Input({
    super.key,
    required this.hint,
    required this.icon,
    this.onChanged,
    this.obscure = false,
    this.suffix,
  });

  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;
  final bool obscure;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscure,
      style: const TextStyle(color: kTextPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: kInput,
        hintText: hint,
        hintStyle: const TextStyle(color: kTextSecondary),
        prefixIcon: Icon(icon, color: kAccent),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kAccent, width: 1.2),
        ),
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({required this.label, required this.asset});
  final String label;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCard,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: kStroke),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              asset,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(kTextPrimary, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: kTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
