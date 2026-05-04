import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextEditingController controller;
  final bool isDarkMode;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.isPassword,
    required this.controller,
    required this.isDarkMode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = widget.isDarkMode ? const Color(0xFFCCCCCC) : const Color(0xFF4A4A4A);
    final backgroundColor = widget.isDarkMode ? const Color(0xFF252525) : const Color(0xFFEBE4D5);
    final shadowColor = widget.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08);
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final hintColor = widget.isDarkMode ? Colors.grey[600] : const Color(0xFF9E9E9E);
    final iconColor = widget.isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: labelColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: _obscureText,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: hintColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: iconColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
          ),
        )
      ],
    );
  }
}

