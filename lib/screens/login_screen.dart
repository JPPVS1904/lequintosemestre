import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_modal.dart';

/// Formatador de CPF.
/// Aplica dinamicamente a máscara `000.000.000-00` enquanto o usuário digita.
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 11) digits = digits.substring(0, 11);

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digits[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Tela de Login do aplicativo.
/// Permite ao usuário autenticar-se utilizando seu CPF e Senha.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  final _authService = AuthService();

  Future<void> _handleLogin() async {
    if (_cpfController.text.isEmpty || _passwordController.text.isEmpty) {
      showAppModal(
        context,
        type: 'error',
        message: 'Preencha todos os campos.',
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.login(
      _cpfController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      showAppModal(context, type: 'error', message: result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      key: _scaffoldKey,
      // Fundo gradiente
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF020304),
                    const Color(0xFF0D0F11),
                    const Color(0xFF242830),
                  ]
                : [
                    const Color(0xFFC8BFB0),
                    const Color(0xFFE2D9CC),
                    const Color(0xFFF5F0E8),
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Formulário principal
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        'lib/images/logo_comunidade_sao_miguel.png',
                        height: 140,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.shield_rounded,
                          size: 100,
                          color: AppColors.brand,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Título
                      Text(
                        'Acesso',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'PORTAL COMUNIDADE SÃO MIGUEL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Campo CPF
                      _buildLabel('CPF'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _cpfController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [CpfInputFormatter()],
                        decoration: const InputDecoration(
                          hintText: '000.000.000-00',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Campo Senha
                      _buildLabel('SENHA'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: textSecondary,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Botão de login
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.brand.withValues(alpha: 0.3),
                                offset: const Offset(0, 6),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text('ENTRAR AGORA'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Link para registro
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: RichText(
                          text: TextSpan(
                            text: 'Novo por aqui? ',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Crie sua conta',
                                style: TextStyle(
                                  color: AppColors.brand,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: (isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}
