import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_wallet/features/profile/presentation/pages/profile_page.dart';

const kLemon = Color(0xFFB9FF3C);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _DashboardBody(),
      const _PlaceholderScreen(title: 'Transacciones'),
      const _PlaceholderScreen(title: 'Insights'),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          ['Mart Wallet', 'Transacciones', 'Insights', 'Cuenta'][_index],
        ),
        actions: [
          if (_index == 0)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) async {
          // Si estamos saliendo de Cuenta (idx 3), preguntar si hay cambios sin guardar
          if (_index == 3 && i != 3) {
            final guard = ref.read(profileLeaveGuardProvider);
            if (guard != null) {
              final canLeave = await guard();
              if (!mounted) return;
              if (!canLeave) return; // cancelar cambio de tab
            }
          }
          setState(() => _index = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Transac.',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Cuenta',
          ),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () {},
              label: const Text('Añadir'),
              icon: const Icon(Icons.add),
            )
          : null,
      body: pages[_index],
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});
  @override
  Widget build(BuildContext context) => Center(child: Text(title));
}

class _DashboardBody extends StatefulWidget {
  const _DashboardBody();
  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  final _filters = const ['Hoy', 'Semana', 'Mes'];
  int _selectedFilter = 2;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        const _HeaderBalance(),
        const SizedBox(height: 16),
        const _QuickActions(),
        const SizedBox(height: 16),
        const _AiCards(),
        const SizedBox(height: 16),
        const _SectionHeader(title: 'Historial', trailing: null),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_filters.length, (i) {
              final sel = i == _selectedFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_filters[i]),
                  selected: sel,
                  onSelected: (_) => setState(() => _selectedFilter = i),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _HeaderBalance extends StatelessWidget {
  const _HeaderBalance();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kLemon, Color(0xFFA1E62E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8CCF28)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo disponible',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                'S/ 9,645.50',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
              ),
              SizedBox(width: 6),
              Text(
                'PEN',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Meta mensual: S/ 2,000 ahorros',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '65%',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.65,
              minHeight: 10,
              backgroundColor: cs.surface,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _QuickAction(icon: Icons.qr_code_scanner, label: 'Escanear\nFactura'),
        _QuickAction(icon: Icons.auto_graph, label: 'Presupuesto\nAuto'),
        _QuickAction(
          icon: Icons.chat_bubble_outline,
          label: 'Asistente\nFinanciero',
        ),
        _QuickAction(icon: Icons.add_circle_outline, label: 'Ingreso/\nGasto'),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Ink(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2E3C30)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Icon(icon, size: 26),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _AiCards extends StatelessWidget {
  const _AiCards();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        _AiCard(
          icon: Icons.warning_amber_rounded,
          color: Colors.amber,
          title: 'Riesgo de sobregasto',
          text: 'Según tu ritmo, podrías pasarte del presupuesto en 5 días.',
          action: TextButton(
            onPressed: () {},
            child: const Text('Ver detalle'),
          ),
        ),
        const SizedBox(height: 10),
        _AiCard(
          icon: Icons.trending_up_rounded,
          color: cs.primary,
          title: 'Predicción del mes',
          text:
              'Gasto estimado: S/ 3,450. Recomendación: reduce delivery 20% (ahorras ~S/ 150).',
          action: TextButton(
            onPressed: () {},
            child: const Text('Aplicar sugerencia'),
          ),
        ),
      ],
    );
  }
}

class _AiCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String text;
  final Widget action;
  const _AiCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E3C30)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(text, style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 6),
                action,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
