import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _focusAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_focusNode.hasFocus) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              widget.labelText!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _isFocused ? AppColors.primary : AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15 * _focusAnimation.value),
                    blurRadius: 20 * _focusAnimation.value,
                    offset: Offset(0, 8 * _focusAnimation.value),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            maxLines: widget.maxLines,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onSubmitted,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, right: 12),
                      child: widget.prefixIcon,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: widget.suffixIcon,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
