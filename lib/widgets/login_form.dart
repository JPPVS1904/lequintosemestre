import 'package:flutter/material.dart';
import 'custom_text_field.dart';
import 'login_button.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool rememberMe;
  final Function(bool?) onChangedRememberMe;
  final VoidCallback onClickLogin;
  final VoidCallback onClickCreateAccount;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.rememberMe,
    required this.onChangedRememberMe,
    required this.onClickLogin,
    required this.onClickCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? const Color(0xFFF0F2F5) : const Color(0xFF1A1C1E);
    final secondaryTextColor = isDarkMode ? const Color(0xFF9BA1A6) : const Color(0xFF44474A);
    const highlightTextColor = Color(0xFFC4982A);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/images/logo_comunidade_sao_miguel.png',
            height: 120,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.security, size: 100, color: highlightTextColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Acesso',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PORTAL COMUNIDADE SÃO MIGUEL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: secondaryTextColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 40),
          CustomTextField(
            label: 'E-mail',
            hint: 'seu@email.com',
            isPassword: false,
            controller: emailController,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Senha',
            hint: '••••••••',
            isPassword: true,
            controller: passwordController,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: rememberMe,
                onChanged: onChangedRememberMe,
                activeColor: highlightTextColor,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: BorderSide(color: isDarkMode ? const Color(0xFF2A2D31) : const Color(0xFFD9D3C8)),
              ),
              GestureDetector(
                onTap: () {
                  onChangedRememberMe(!rememberMe);
                },
                child: Text(
                  'Lembrar de mim',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: LoginButton(
              isLoading: isLoading,
              onClick: onClickLogin,
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: onClickCreateAccount,
            child: RichText(
              text: TextSpan(
                text: 'Novo por aqui? ',
                style: TextStyle(color: secondaryTextColor, fontSize: 14),
                children: const [
                  TextSpan(
                    text: 'Crie sua conta',
                    style: TextStyle(color: highlightTextColor, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
