import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/user_health_profile.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/module_scaffold.dart';

/// Health profile & dietary preferences editor.
/// Ported from InviSafeP's FoodPreferenceActivity + health profile sheet.
class FoodPreferencesScreen extends StatefulWidget {
  const FoodPreferencesScreen({super.key});

  @override
  State<FoodPreferencesScreen> createState() => _FoodPreferencesScreenState();
}

class _FoodPreferencesScreenState extends State<FoodPreferencesScreen> {
  late final UserHealthProfile _p = UserHealthProfileStore.instance.profile;
  late final FoodPreferences _prefs = UserHealthProfileStore.instance.preferences;
  final _allergyController = TextEditingController();

  @override
  void dispose() {
    _allergyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.bioSafetyGreen;
    return ModuleScaffold(
      title: 'HEALTH PROFILE',
      accent: accent,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CONDITIONS',
                    style: TextStyle(
                        color: AppColors.textSecondary, letterSpacing: 2)),
                _toggle('Diabetes', _p.diabetes,
                    (v) => setState(() => _p.diabetes = v)),
                _toggle('High Blood Pressure', _p.highBloodPressure,
                    (v) => setState(() => _p.highBloodPressure = v)),
                _toggle('Low Blood Pressure', _p.lowBloodPressure,
                    (v) => setState(() => _p.lowBloodPressure = v)),
                _toggle('Iron Deficiency', _p.ironDeficiency,
                    (v) => setState(() => _p.ironDeficiency = v)),
                _toggle('Obesity', _p.obesity,
                    (v) => setState(() => _p.obesity = v)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DIET',
                    style: TextStyle(
                        color: AppColors.textSecondary, letterSpacing: 2)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: DietType.values
                      .map((d) => ChoiceChip(
                            label: Text(d.name),
                            selected: _prefs.diet == d,
                            onSelected: (_) => setState(() => _prefs.diet = d),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                const Text('GOAL',
                    style: TextStyle(
                        color: AppColors.textSecondary, letterSpacing: 2)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: HealthGoal.values
                      .map((g) => ChoiceChip(
                            label: Text(g.name),
                            selected: _prefs.goal == g,
                            onSelected: (_) => setState(() => _prefs.goal = g),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ALLERGIES',
                    style: TextStyle(
                        color: AppColors.textSecondary, letterSpacing: 2)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _allergyController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'e.g. peanut',
                          hintStyle: TextStyle(color: AppColors.textTertiary),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: accent),
                      onPressed: () {
                        final t = _allergyController.text.trim();
                        if (t.isNotEmpty) {
                          setState(() {
                            _p.allergies.add(t);
                            _allergyController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: _p.allergies
                      .map((a) => Chip(
                            label: Text(a),
                            onDeleted: () =>
                                setState(() => _p.allergies.remove(a)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      value: value,
      activeColor: AppColors.bioSafetyGreen,
      onChanged: onChanged,
    );
  }
}
