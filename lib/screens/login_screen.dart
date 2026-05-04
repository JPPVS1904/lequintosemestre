import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/login_form.dart';
import '../widgets/login_drawer.dart';
import '../widgets/theme_toggle_button.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _rememberMe = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    SizedBox(width: 8),
                    Text('Sucesso!', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                content: const Text(
                  'Você foi autenticado e conectado com sucesso ao sistema Laravel!',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      );
                    },
                    child: const Text('ENTRAR NO APP', style: TextStyle(color: Color(0xFFC79E3A), fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao entrar. Credenciais inválidas.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final bgGradient = isDarkMode 
        ? const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFF020304), Color(0xFF0D0F11), Color(0xFF242830)],
          )
        : const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFFC8BFB0), Color(0xFFE2D9CC), Color(0xFFF5F0E8)],
          );

    final boxBgColor = isDarkMode ? const Color(0xFF16191C) : const Color(0xFFF2EDE4);
    final boxBorderColor = isDarkMode ? const Color(0xFF2A2D31) : const Color(0xFFD9D3C8);
    final primaryTextColor = isDarkMode ? const Color(0xFFF0F2F5) : const Color(0xFF1A1C1E);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const LoginDrawer(),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: LoginForm(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isLoading: _isLoading,
                  rememberMe: _rememberMe,
                  onChangedRememberMe: (val) {
                    setState(() {
                      _rememberMe = val ?? false;
                    });
                  },
                  onClickLogin: _login,
                  onClickCreateAccount: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: InkWell(
                  onTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: boxBgColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: boxBorderColor),
                    ),
                    child: Icon(Icons.menu, color: primaryTextColor),
                  ),
                ),
              ),
              const Positioned(
                bottom: 24,
                right: 24,
                child: ThemeToggleButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
