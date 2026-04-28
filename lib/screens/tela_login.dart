import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/logo_mock.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/login_button.dart';
import '../widgets/footer_text.dart';
import '../widgets/floating_icon_button.dart';
import '../theme/theme_notifier.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _controladorEmail = TextEditingController();
  final TextEditingController _controladorSenha = TextEditingController();
  final AuthService _authService = AuthService();
  bool _carregando = false;

  Future<void> _entrar() async {
    setState(() {
      _carregando = true;
    });

    try {
      final sucesso = await _authService.login(
        _controladorEmail.text,
        _controladorSenha.text,
      );

      if (mounted) {
        if (sucesso) {
          // Feedback visual em pop-up detalhado
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
                      Navigator.of(context).pop(); // Fecha o diálogo
                      // No futuro, coloque aqui: Navigator.pushReplacement(context, ...TelaPrincipal);
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
          _carregando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controladorEmail.dispose();
    _controladorSenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool modoEscuro = Theme.of(context).brightness == Brightness.dark;

    final corFundoCentro = modoEscuro ? const Color(0xFF2C2C2C) : const Color(0xFFF4EFE6);
    final corFundoBorda = modoEscuro ? const Color(0xFF1A1A1A) : const Color(0xFFE4DCCF);
    
    final corTextoPrincipal = modoEscuro ? const Color(0xFFE0E0E0) : const Color(0xFF2D2D2D);
    final corTextoSecundario = modoEscuro ? const Color(0xFFAAAAAA) : const Color(0xFF7A7A7A);
    const corTextoDestaque = Color(0xFFC79E3A);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              corFundoCentro,
              corFundoBorda,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      const LogoMock(cor: corTextoDestaque),
                      Text(
                        'Acesso',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: corTextoPrincipal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PORTAL COMUNIDADE SÃO MIGUEL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: corTextoSecundario,
                        ),
                      ),
                      const SizedBox(height: 48),
                      CustomTextField(
                        rotulo: 'E-mail',
                        dica: 'seu@email.com',
                        senha: false,
                        controlador: _controladorEmail,
                        modoEscuro: modoEscuro,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        rotulo: 'Senha',
                        dica: '••••••••',
                        senha: true,
                        controlador: _controladorSenha,
                        modoEscuro: modoEscuro,
                      ),
                      const SizedBox(height: 40),
                      LoginButton(
                        carregando: _carregando,
                        aoClicar: _entrar,
                      ),
                      const SizedBox(height: 32),
                      FooterText(
                        corTextoSecundario: corTextoSecundario,
                        corDestaque: corTextoDestaque,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: FloatingIconButton(
                  icone: Icons.menu,
                  modoEscuro: modoEscuro,
                  aoClicar: () {},
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingIconButton(
                  icone: modoEscuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  modoEscuro: modoEscuro,
                  aoClicar: () {
                    modoEscuroNotifier.value = !modoEscuroNotifier.value;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
