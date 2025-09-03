import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_wallet/features/profile/presentation/profile_controller.dart';
import 'package:mart_wallet/features/profile/domain/entities/user_profile_entity.dart';

const kAccent = Color(0xFFB9FF3C);

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _country = TextEditingController(text: 'PE');
  final _locale = TextEditingController(text: 'es-PE');
  final _timezone = TextEditingController(text: 'America/Lima');
  final _currency = TextEditingController(text: 'PEN');
  final _avatar = TextEditingController();
  DateTime? _birth;
  bool _optin = false;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileControllerProvider.notifier).load());
  }

  UserProfileEntity? _buildEntityOrShowError(BuildContext context) {
    final country = _country.text.trim().toUpperCase();
    final currency = _currency.text.trim().toUpperCase();
    final locale = _locale.text.trim();
    final timezone = _timezone.text.trim();
    final phone = _phone.text.replaceAll(RegExp(r'[^+0-9]'), '');

    if (country.isNotEmpty && country.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El país debe ser código ISO-2, ej: PE')),
      );
      return null;
    }
    if (currency.isNotEmpty && currency.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La moneda debe ser ISO-4217, ej: PEN')),
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
      avatarUrl: _avatar.text.trim().isEmpty ? null : _avatar.text.trim(),
      marketingOptin: _optin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);

    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.exists && !_creating) {
      return Center(
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
      );
    }

    final profile = state.profile;
    _phone.text = profile?.phoneE164 ?? _phone.text;
    _country.text = profile?.country ?? _country.text;
    _locale.text = profile?.locale ?? _locale.text;
    _timezone.text = profile?.timezone ?? _timezone.text;
    _currency.text = profile?.currency ?? _currency.text;
    _avatar.text = profile?.avatarUrl ?? _avatar.text;
    _optin = profile?.marketingOptin ?? _optin;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _form,
        child: ListView(
          children: [
            const Text(
              'Perfil de usuario',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Teléfono (+51...)'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _country,
                    decoration: const InputDecoration(
                      labelText: 'País (ISO-2)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _currency,
                    decoration: const InputDecoration(
                      labelText: 'Moneda (ISO-4217)',
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _locale,
                    decoration: const InputDecoration(labelText: 'Locale'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _timezone,
                    decoration: const InputDecoration(labelText: 'Timezone'),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _avatar,
              decoration: const InputDecoration(labelText: 'Avatar URL'),
            ),
            SwitchListTile(
              value: _optin,
              onChanged: (v) => setState(() => _optin = v),
              title: const Text('Recibir recomendaciones y tips'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      final entity = _buildEntityOrShowError(context);
                      if (entity == null) return;
                      await ref
                          .read(profileControllerProvider.notifier)
                          .upsert(entity);
                      if (mounted) setState(() => _creating = false);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: Colors.black,
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Guardar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final entity = _buildEntityOrShowError(context);
                      if (entity == null) return;
                      ref
                          .read(profileControllerProvider.notifier)
                          .upsert(entity);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kAccent),
                      foregroundColor: kAccent,
                    ),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Actualizar'),
                  ),
                ),
              ],
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(state.error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
