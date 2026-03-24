import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AppProgressBar extends StatefulWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showPercentage;
  final Duration animationDuration;

  const AppProgressBar({
    super.key,
    required this.progress,
    this.height = 12,
    this.backgroundColor,
    this.progressColor,
    this.showPercentage = false,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<AppProgressBar> createState() => _AppProgressBarState();
}

class _AppProgressBarState extends State<AppProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AppProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Text(
                  '${(_animation.value * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey,
                  ),
                );
              },
            ),
          ),
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.greyLight,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _animation.value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: widget.progressColor != null
                        ? null
                        : AppColors.primaryGradient,
                    color: widget.progressColor,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
