import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mart_wallet/features/profile/presentation/profile_controller.dart';
import 'package:mart_wallet/features/profile/domain/entities/user_profile_entity.dart';
import 'package:mart_wallet/features/auth/presentation/controllers/auth_controller.dart';

const kAccent = Color(0xFFB9FF3C);

// Exponer una función de "leave guard" para que HomePage consulte al cambiar de tab
final profileLeaveGuardProvider = StateProvider<Future<bool> Function()?>(
  (ref) => null,
);

ImageProvider? _buildImageProvider(String url) {
  try {
    if (url.startsWith('data:image')) {
      final base64String = url.split(',').last;
      final Uint8List bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } else {
      return NetworkImage(url);
    }
  } catch (e) {
    return null;
  }
}

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _form = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _country = TextEditingController(text: 'PE');
  final _locale = TextEditingController(text: 'es-PE');
  final _timezone = TextEditingController(text: 'America/Lima');
  final _currency = TextEditingController(text: 'PEN');
  final _avatar = TextEditingController();
  DateTime? _birth;
  bool _optin = false;
  bool _creating = false;
  bool _updated = false;
  bool _dirty = false;
  bool _suppressDirty = false;
  String _snapshot = '';

  String _takeSnapshot() {
    return [
      _fullName.text,
      _email.text,
      _phone.text,
      _country.text,
      _locale.text,
      _timezone.text,
      _currency.text,
      _avatar.text,
      _optin.toString(),
      _birth?.toIso8601String() ?? '',
    ].join('|');
  }

  void _attachDirtyListeners() {
    for (final c in [
      _phone,
      _country,
      _locale,
      _timezone,
      _currency,
      _avatar,
    ]) {
      c.addListener(_markDirtyIfChanged);
    }
  }

  void _markDirtyIfChanged() {
    if (_suppressDirty) return;
    final current = _takeSnapshot();
    final isDirty = current != _snapshot;
    if (isDirty != _dirty && mounted) {
      setState(() => _dirty = isDirty);
    }
  }

  Future<bool> _leaveGuard() async {
    if (!_dirty) return true;
    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Cambios sin guardar'),
        content: const Text('Tienes cambios sin guardar. ¿Qué deseas hacer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text('Salir sin guardar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Guardar y salir'),
          ),
        ],
      ),
    );
    if (action == 'cancel') return false;
    if (action == 'save') {
      final ok = await _saveProfileSilent();
      return ok;
    }
    return true; // discard
  }

  Future<void> _confirmAndLogout() async {
    if (_dirty) {
      final action = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Cambios sin guardar'),
          content: const Text('Tienes cambios sin guardar. ¿Qué deseas hacer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'discard'),
              child: const Text('Salir sin guardar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(context, 'save'),
              child: const Text('Guardar y salir'),
            ),
          ],
        ),
      );

      if (action == 'cancel') return;
      if (action == 'save') {
        final ok = await _saveProfileSilent();
        if (!ok) return;
      }
    } else {
      final ok = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('¿Cerrar sesión?'),
          content: const Text('Se cerrará tu sesión actual.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  void initState() {
    super.initState();
    _attachDirtyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAuthData();
      print('🔄 Force loading profile from server');
      ref.read(profileControllerProvider.notifier).load();
      _suppressDirty = true;
      _snapshot = _takeSnapshot();
      _dirty = false;
      _suppressDirty = false;
      // Registrar leave guard después del build
      ref.read(profileLeaveGuardProvider.notifier).state = _leaveGuard;
    });
  }

  void _loadAuthData() {
    final authState = ref.read(authControllerProvider);
    print(
      '🔍 Loading auth data: name=${authState.name}, email=${authState.email}',
    );
    if (mounted) {
      _suppressDirty = true;
      setState(() {
        _fullName.text = authState.name.isNotEmpty ? authState.name : 'Usuario';
        _email.text = authState.email.isNotEmpty
            ? authState.email
            : 'usuario@ejemplo.com';
      });
      _snapshot = _takeSnapshot();
      _dirty = false;
      _suppressDirty = false;
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _country.dispose();
    _locale.dispose();
    _timezone.dispose();
    _currency.dispose();
    _avatar.dispose();
    // Limpiar guard registrado
    ref.read(profileLeaveGuardProvider.notifier).state = null;
    super.dispose();
  }

  void _applyProfile(UserProfileEntity p) {
    print(
      '📋 Applying profile data: phone=${p.phoneE164}, avatar=${p.avatarUrl?.substring(0, 20)}...',
    );
    if (!mounted) return;
    _suppressDirty = true;
    setState(() {
      _phone.text = p.phoneE164 ?? '';
      _country.text = p.country ?? 'PE';
      _locale.text = p.locale ?? 'es-PE';
      _timezone.text = p.timezone ?? 'America/Lima';
      _currency.text = p.currency ?? 'PEN';
      _avatar.text = p.avatarUrl ?? '';
      _optin = p.marketingOptin;
      _birth = p.birthdate;
    });
    _snapshot = _takeSnapshot();
    _dirty = false;
    _suppressDirty = false;
  }

  Widget _buildAvatar(String? url, {double radius = 32}) {
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: kAccent,
      child: Icon(Icons.person, size: radius * 0.8, color: Colors.black),
    );
    if (url == null || url.isEmpty) return fallback;
    final provider = _buildImageProvider(url);
    if (provider == null) return fallback;
    return CircleAvatar(
      radius: radius,
      backgroundImage: provider,
      backgroundColor: Colors.grey[200],
    );
  }

  UserProfileEntity? _buildEntityOrShowError(BuildContext context) {
    final phone = _phone.text.trim();
    final country = _country.text.trim().toUpperCase();
    final locale = _locale.text.trim();
    final timezone = _timezone.text.trim();
    final currency = _currency.text.trim().toUpperCase();
    final avatar = _avatar.text.trim();

    // Validaciones básicas
    if (currency.isNotEmpty && !RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La moneda debe ser código ISO-4217, ej: PEN'),
        ),
      );
      return null;
    }
    if (country.isNotEmpty && !RegExp(r'^[A-Z]{2}$').hasMatch(country)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El país debe ser código ISO-2, ej: PE')),
      );
      return null;
    }

    return UserProfileEntity(
      phoneE164: phone.isEmpty ? null : phone,
      country: country.isEmpty ? null : country,
      locale: locale.isEmpty ? null : locale,
      timezone: timezone.isEmpty ? null : timezone,
      currency: currency.isEmpty ? null : currency,
      birthdate: _birth,
      avatarUrl: avatar.isEmpty ? null : avatar,
      marketingOptin: _optin,
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha de Nacimiento',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Text(
                  _birth != null
                      ? '${_birth!.day.toString().padLeft(2, '0')}/${_birth!.month.toString().padLeft(2, '0')}/${_birth!.year}'
                      : 'Seleccionar fecha',
                  style: TextStyle(
                    fontSize: 16,
                    color: _birth != null ? Colors.black : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _birth ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _birth = date);
      _markDirtyIfChanged();
    }
  }

  void _showAvatarDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('URL del Avatar'),
        content: TextField(
          controller: _avatar,
          decoration: const InputDecoration(
            hintText: 'Ingresa la URL de tu avatar',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {});
            _markDirtyIfChanged();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            style: FilledButton.styleFrom(backgroundColor: kAccent),
            child: const Text('Guardar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    if (_form.currentState?.validate() ?? false) {
      final entity = _buildEntityOrShowError(context);
      if (entity != null) {
        await ref.read(profileControllerProvider.notifier).upsert(entity);
        setState(() => _updated = true);
      }
    }
  }

  // Guarda sin cambiar a pantalla de éxito; actualiza snapshot/dirty
  Future<bool> _saveProfileSilent() async {
    final entity = _buildEntityOrShowError(context);
    if (entity == null) return false;
    try {
      await ref.read(profileControllerProvider.notifier).upsert(entity);
      if (!mounted) return true;
      setState(() {
        _suppressDirty = true;
        _snapshot = _takeSnapshot();
        _dirty = false;
        _suppressDirty = false;
      });
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    // Guard de navegación se registra en initState vía post-frame

    ref.listen(profileControllerProvider, (prev, next) {
      if (next.profile != null) {
        _applyProfile(next.profile!);
      }
    });

    ref.listen(authControllerProvider, (prev, next) {
      _loadAuthData();
    });

    if (state.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_updated) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: kAccent, size: 72),
                const SizedBox(height: 12),
                const Text(
                  'Perfil actualizado',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kAccent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    setState(() => _updated = false);
                    ref.read(profileControllerProvider.notifier).load();
                  },
                  child: const Text('Ver perfil'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!state.exists && !_creating) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline, size: 72),
                const SizedBox(height: 12),
                const Text('Aún no has configurado tu perfil'),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => setState(() => _creating = true),
                  style: FilledButton.styleFrom(
                    backgroundColor: kAccent,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.settings),
                  label: const Text('Configurar perfil'),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 10),
                  Text(state.error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        // Botón atrás del sistema / AppBar
        if (!_dirty) return true;
        final guard = ref.read(profileLeaveGuardProvider);
        if (guard != null) return await guard();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Información Personal'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Form(
          key: _form,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (_dirty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kAccent.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kAccent.withOpacity(0.45)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Tienes cambios sin guardar',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: _saveProfile,
                          child: const Text('Guardar ahora'),
                        ),
                      ],
                    ),
                  ),
                // Avatar Section
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _showAvatarDialog,
                        child: _buildAvatar(_avatar.text.trim(), radius: 50),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: kAccent,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _showAvatarDialog,
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.black,
                              size: 20,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                _buildInputField(
                  label: 'Nombre Completo',
                  controller: _fullName,
                  readOnly: true,
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'Email',
                  controller: _email,
                  readOnly: true,
                  prefixIcon: Icons.email,
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'Número de Teléfono',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone,
                ),
                const SizedBox(height: 20),

                _buildDateField(),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'País (ISO-2)',
                  controller: _country,
                  prefixIcon: Icons.flag,
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'Moneda (ISO-4217)',
                  controller: _currency,
                  prefixIcon: Icons.attach_money,
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'Configuración Regional',
                  controller: _locale,
                  prefixIcon: Icons.language,
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'Zona Horaria',
                  controller: _timezone,
                  prefixIcon: Icons.schedule,
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Checkbox(
                      value: _optin,
                      onChanged: (v) {
                        setState(() => _optin = v ?? false);
                        _markDirtyIfChanged();
                      },
                      activeColor: kAccent,
                    ),
                    const Expanded(
                      child: Text('Acepto recibir comunicaciones de marketing'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Cerrar sesión
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _confirmAndLogout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
