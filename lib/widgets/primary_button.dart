import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_typography.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final bool isOutlined;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.icon,
    this.isOutlined = false,
    this.height = 48,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.03,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading ? (_) => _controller.forward() : null,
      onTapUp: widget.onPressed != null && !widget.isLoading ? (_) => _controller.reverse() : null,
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: Material(
            color: widget.isOutlined ? Colors.transparent : widget.backgroundColor,
            borderRadius: AppSpacing.roundedMd,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: AppSpacing.roundedMd,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppSpacing.roundedMd,
                  border: widget.isOutlined
                      ? Border.all(color: widget.backgroundColor, width: 1.5)
                      : null,
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: widget.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.isOutlined ? widget.backgroundColor : widget.textColor,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 18, color: widget.isOutlined ? widget.backgroundColor : widget.textColor),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: AppTypography.labelLg.copyWith(
                              color: widget.isOutlined ? widget.backgroundColor : widget.textColor,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
