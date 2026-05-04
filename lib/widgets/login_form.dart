import 'package:flutter/material.dart';
import 'custom_text_field.dart';
import 'login_button.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController controladorEmail;
  final TextEditingController controladorSenha;
  final bool carregando;
  final bool lembrarMe;
  final Function(bool?) onChangedLembrarMe;
  final VoidCallback aoClicarEntrar;
  final VoidCallback aoClicarCriarConta;

  const LoginForm({
    super.key,
    required this.controladorEmail,
    required this.controladorSenha,
    required this.carregando,
    required this.lembrarMe,
    required this.onChangedLembrarMe,
    required this.aoClicarEntrar,
    required this.aoClicarCriarConta,
  });

  @override
  Widget build(BuildContext context) {
    final bool modoEscuro = Theme.of(context).brightness == Brightness.dark;
    final corTextoPrincipal = modoEscuro ? const Color(0xFFF0F2F5) : const Color(0xFF1A1C1E);
    final corTextoSecundario = modoEscuro ? const Color(0xFF9BA1A6) : const Color(0xFF44474A);
    const corTextoDestaque = Color(0xFFC4982A);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/images/logo_comunidade_sao_miguel.png',
            height: 120,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.security, size: 100, color: corTextoDestaque),
          ),
          const SizedBox(height: 16),
          Text(
            'Acesso',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: corTextoPrincipal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PORTAL COMUNIDADE SÃO MIGUEL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: corTextoSecundario.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 40),
          CustomTextField(
            rotulo: 'E-mail',
            dica: 'seu@email.com',
            senha: false,
            controlador: controladorEmail,
            modoEscuro: modoEscuro,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            rotulo: 'Senha',
            dica: '••••••••',
            senha: true,
            controlador: controladorSenha,
            modoEscuro: modoEscuro,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: lembrarMe,
                onChanged: onChangedLembrarMe,
                activeColor: corTextoDestaque,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: BorderSide(color: modoEscuro ? const Color(0xFF2A2D31) : const Color(0xFFD9D3C8)),
              ),
              GestureDetector(
                onTap: () {
                  onChangedLembrarMe(!lembrarMe);
                },
                child: Text(
                  'Lembrar de mim',
                  style: TextStyle(
                    color: corTextoSecundario,
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
              carregando: carregando,
              aoClicar: aoClicarEntrar,
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: aoClicarCriarConta,
            child: RichText(
              text: TextSpan(
                text: 'Novo por aqui? ',
                style: TextStyle(color: corTextoSecundario, fontSize: 14),
                children: const [
                  TextSpan(
                    text: 'Crie sua conta',
                    style: TextStyle(color: corTextoDestaque, fontWeight: FontWeight.w900),
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
