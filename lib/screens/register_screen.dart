import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/app_modal.dart';
import 'login_screen.dart' show CpfInputFormatter;

/// Phone mask formatter – (00) 00000-0000
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 11) digits = digits.substring(0, 11);

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}



/// Register screen matching Register.svelte
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();

  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  String? _selectedSex;
  String? _selectedMaritalStatusId;
  DateTime _selectedBirthday = DateTime(2000, 1, 1);

  bool _isLoading = false;
  bool _success = false;

  final _authService = AuthService();

  final _sexOptions = [
    {'value': 'M', 'label': 'Masculino'},
    {'value': 'F', 'label': 'Feminino'},
  ];

  final _maritalOptions = [
    {'value': '1', 'label': 'Solteiro(a)'},
    {'value': '2', 'label': 'Casado(a)'},
    {'value': '3', 'label': 'Divorciado(a)'},
    {'value': '4', 'label': 'Viúvo(a)'},
  ];

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday,
      firstDate: DateTime(1910),
      lastDate: DateTime.now(),
      helpText: 'DATA DE NASCIMENTO',
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                  primary: AppColors.brand,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedBirthday = picked);
    }
  }

  Future<void> _handleRegister() async {
    // Validations matching Register.svelte
    final rawCpf = _cpfController.text.replaceAll(RegExp(r'\D'), '');
    if (rawCpf.length != 11) {
      showAppModal(context, type: 'error', message: 'Por favor, informe um CPF válido com 11 dígitos.');
      return;
    }

    final rawPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (rawPhone.length < 10) {
      showAppModal(context, type: 'error', message: 'Por favor, informe um número de celular válido.');
      return;
    }

    if (_nameController.text.length > 80) {
      showAppModal(context, type: 'error', message: 'O nome é muito longo.');
      return;
    }

    if (_passwordController.text != _passwordConfirmController.text) {
      showAppModal(context, type: 'error', message: 'As senhas não coincidem.');
      return;
    }

    if (_selectedSex == null || _selectedMaritalStatusId == null) {
      showAppModal(context, type: 'error', message: 'Preencha todos os campos obrigatórios.');
      return;
    }

    setState(() => _isLoading = true);

    final birthday =
        '${_selectedBirthday.year}-${_selectedBirthday.month.toString().padLeft(2, '0')}-${_selectedBirthday.day.toString().padLeft(2, '0')}';

    final payload = {
      'name': _nameController.text,
      'email': _emailController.text,
      'cpf': rawCpf,
      'phone': rawPhone,
      'document': '',
      'sex': _selectedSex,
      'birthday': birthday,
      'marital_status_id': _selectedMaritalStatusId,
      'password': _passwordController.text,
      'password_confirmation': _passwordConfirmController.text,
      'is_counselor': 0,
      'picture': 'default.png',
    };

    final result = await _authService.register(payload);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() => _success = true);
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) Navigator.pop(context);
    } else {
      showAppModal(context, type: 'error', message: result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bgSecondary = isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary;
    final borderColor = isDark ? AppColors.darkBorderUi : AppColors.lightBorderUi;

    final months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            // Logo (mobile)
            Image.asset(
              'lib/images/logo_comunidade_sao_miguel.png',
              height: 120,
              errorBuilder: (_, __, ___) => Icon(Icons.shield_rounded, size: 80, color: AppColors.brand),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              'Cadastrar',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'PREENCHA SEUS DADOS PARA CONTINUAR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: textSecondary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 28),

            if (_success) ...[
              // Success state matching Register.svelte
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Text('🛡️', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text('Bem-vindo!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary)),
                    const SizedBox(height: 8),
                    Text(
                      'Seu acesso foi criado. Redirecionando...',
                      style: TextStyle(fontSize: 14, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // ── Form fields ──
              _buildLabel('Nome Completo *'),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                maxLength: 80,
                decoration: const InputDecoration(hintText: 'Seu nome aqui', counterText: ''),
              ),
              const SizedBox(height: 16),

              _buildLabel('E-mail *'),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'exemplo@gmail.com'),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('CPF *'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _cpfController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [CpfInputFormatter()],
                          decoration: const InputDecoration(hintText: '000.000.000-00'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Celular *'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [PhoneInputFormatter()],
                          decoration: const InputDecoration(hintText: '(00) 00000-0000'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Gênero *'),
                        const SizedBox(height: 6),
                        _buildDropdown(
                          value: _selectedSex,
                          items: _sexOptions,
                          onChanged: (v) => setState(() => _selectedSex = v),
                          borderColor: borderColor,
                          bgSecondary: bgSecondary,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Estado Civil *'),
                        const SizedBox(height: 6),
                        _buildDropdown(
                          value: _selectedMaritalStatusId,
                          items: _maritalOptions,
                          onChanged: (v) => setState(() => _selectedMaritalStatusId = v),
                          borderColor: borderColor,
                          bgSecondary: bgSecondary,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),



              // Date picker
              _buildLabel('Data de Nascimento'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickBirthday,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedBirthday.day.toString().padLeft(2, '0')} de ${months[_selectedBirthday.month - 1]} de ${_selectedBirthday.year}',
                        style: TextStyle(
                          color: AppColors.brand,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Icon(Icons.calendar_today_rounded, color: textSecondary, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Senha *'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(hintText: '••••••••'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Confirmar *'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordConfirmController,
                          obscureText: true,
                          decoration: const InputDecoration(hintText: '••••••••'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Footer note
              Text(
                'Campos marcados com * são obrigatórios.',
                style: TextStyle(
                  fontSize: 10,
                  color: textSecondary.withValues(alpha: 0.6),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brand.withValues(alpha: 0.2),
                        offset: const Offset(0, 6),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('CONFIRMAR CADASTRO'),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Go to login
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    text: 'Já tem uma conta? ',
                    style: TextStyle(color: textSecondary, fontSize: 14),
                    children: const [
                      TextSpan(
                        text: 'Faça login',
                        style: TextStyle(color: AppColors.brand, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandColor = AppColors.brand;
    final labelColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // Detect required marker
    final hasRequired = text.endsWith('*');
    final cleanText = hasRequired ? text.substring(0, text.length - 2) : text;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: RichText(
          text: TextSpan(
            text: cleanText.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: labelColor,
            ),
            children: hasRequired
                ? [TextSpan(text: ' *', style: TextStyle(color: brandColor))]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
    required Color borderColor,
    required Color bgSecondary,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text('Selecione...', style: TextStyle(color: textSecondary.withValues(alpha: 0.6))),
          dropdownColor: bgSecondary,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e['value'],
                    child: Text(e['label']!, style: TextStyle(color: textPrimary)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
