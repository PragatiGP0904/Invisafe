import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Glassmorphism module card used on the home grid.
///
/// Vertical layout (glowing icon tile → title → subtitle) so all six modules
/// fit a responsive grid with a uniform size, while preserving the existing
/// dark / neon-glow / glassmorphism design language. Reacts to both pointer
/// hover (desktop/web) and touch (mobile) with a premium scale + glow.
class ScenarioCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData iconData;
  final String? iconAsset;
  final VoidCallback onTap;

  const ScenarioCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.iconData,
    required this.onTap,
    this.iconAsset,
  });

  @override
  State<ScenarioCard> createState() => _ScenarioCardState();
}

class _ScenarioCardState extends State<ScenarioCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: 1.04).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
  );

  bool _active = false;

  void _setActive(bool value) {
    if (_active == value) return;
    setState(() => _active = value);
    value ? _controller.forward() : _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setActive(true),
      onExit: (_) => _setActive(false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _setActive(true),
        onTapUp: (_) => _setActive(false),
        onTapCancel: () => _setActive(false),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _active
                    ? widget.accentColor.withOpacity(0.7)
                    : AppColors.glassWhite.withOpacity(0.20),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor
                      .withOpacity(_active ? 0.30 : 0.10),
                  blurRadius: _active ? 26 : 14,
                  spreadRadius: _active ? 2 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.45),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.06),
                        widget.accentColor.withOpacity(0.04),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _iconTile(),
                      const Spacer(),
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.accentColor,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconTile() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.accentColor.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withOpacity(_active ? 0.35 : 0.18),
            blurRadius: _active ? 18 : 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(child: _iconContent()),
    );
  }

  Widget _iconContent() {
    final fallback =
        Icon(widget.iconData, color: widget.accentColor, size: 30);
    if (widget.iconAsset == null) return fallback;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Image.asset(
        widget.iconAsset!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}
