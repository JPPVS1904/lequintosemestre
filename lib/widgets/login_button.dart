import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onClick;

  const LoginButton({
    super.key,
    required this.isLoading,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC79E3A).withOpacity(0.4),
            offset: const Offset(0, 6),
            blurRadius: 12,
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onClick,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC79E3A),
          foregroundColor: Colors.white,
          elevation: 0, 
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: const Color(0xFFC79E3A).withOpacity(0.6),
        ),
        child: isLoading 
          ? const SizedBox(
              height: 20, 
              width: 20, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            )
          : const Text(
              'ENTRAR AGORA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
      ),
    );
  }
}
