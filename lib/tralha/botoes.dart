import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Configurações',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const TelaConfiguracoes(),
    );
  }
}

class TelaConfiguracoes extends StatefulWidget {
  const TelaConfiguracoes({super.key});

  @override
  State<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
  // Variáveis de estado das configurações
  bool _notificacoesAtivas = true;
  bool _modoEscuro = false;
  String _idiomaSelecionado = 'PT';

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _lerConfiguracoes();
  }

  // --- LÓGICA DE MANIPULAÇÃO DE ARQUIVO ---

  // Obtém o caminho da pasta de documentos do app
  Future<String> get _caminhoLocal async {
    final diretorio = await getApplicationDocumentsDirectory();
    return diretorio.path;
  }

  // Cria a referência para o arquivo onde vamos salvar as configurações
  Future<File> get _arquivoLocal async {
    final caminho = await _caminhoLocal;
    return File('$caminho/configuracoes.json');
  }

  // Lê o arquivo ao abrir a tela
  Future<void> _lerConfiguracoes() async {
    try {
      final arquivo = await _arquivoLocal;

      // Verifica se o arquivo já existe
      if (await arquivo.exists()) {
        final stringJson = await arquivo.readAsString();
        final Map<String, dynamic> dados = jsonDecode(stringJson);

        setState(() {
          _notificacoesAtivas = dados['notificacoes'] ?? true;
          _modoEscuro = dados['modoEscuro'] ?? false;
          _idiomaSelecionado = dados['idioma'] ?? 'PT';
        });
      }
    } catch (e) {
      debugPrint("Erro ao ler arquivo: $e");
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  // Salva as configurações sempre que o usuário altera algo
  Future<void> _salvarConfiguracoes() async {
    try {
      final arquivo = await _arquivoLocal;

      // Cria um mapa com os dados atuais
      Map<String, dynamic> dados = {
        'notificacoes': _notificacoesAtivas,
        'modoEscuro': _modoEscuro,
        'idioma': _idiomaSelecionado,
      };

      // Converte para String JSON e escreve no arquivo
      String stringJson = jsonEncode(dados);
      await arquivo.writeAsString(stringJson);

      // Feedback visual opcional
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações salvas no arquivo!'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugPrint("Erro ao salvar arquivo: $e");
    }
  }

  // --- INTERFACE DO USUÁRIO ---

  @override
  Widget build(BuildContext context) {
    // Se o modo escuro estiver ativado, muda a cor de fundo do Scaffold
    final corFundo = _modoEscuro ? Colors.grey[850] : Colors.grey[50];
    final corTexto = _modoEscuro ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        title: const Text('Configurações do Arquivo'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // COMPONENTE 1: Switch (Toggle Button)
                SwitchListTile(
                  title: Text(
                    'Notificações Push',
                    style: TextStyle(color: corTexto),
                  ),
                  subtitle: Text(
                    'Receber alertas no celular',
                    style: TextStyle(color: corTexto.withOpacity(0.7)),
                  ),
                  value: _notificacoesAtivas,
                  activeColor: Colors.teal,
                  onChanged: (bool valor) {
                    setState(() {
                      _notificacoesAtivas = valor;
                    });
                    _salvarConfiguracoes();
                  },
                ),
                const Divider(),

                // COMPONENTE 2: Checkbox
                CheckboxListTile(
                  title: Text(
                    'Ativar Modo Escuro',
                    style: TextStyle(color: corTexto),
                  ),
                  value: _modoEscuro,
                  activeColor: Colors.teal,
                  onChanged: (bool? valor) {
                    setState(() {
                      _modoEscuro = valor ?? false;
                    });
                    _salvarConfiguracoes();
                  },
                ),
                const Divider(),

                // COMPONENTE 3: Radio Buttons (agrupados)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                    bottom: 8.0,
                    left: 16.0,
                  ),
                  child: Text(
                    'Idioma do Aplicativo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: corTexto,
                    ),
                  ),
                ),
                RadioListTile<String>(
                  title: Text(
                    'Português (PT)',
                    style: TextStyle(color: corTexto),
                  ),
                  value: 'PT',
                  groupValue: _idiomaSelecionado,
                  activeColor: Colors.teal,
                  onChanged: (String? valor) {
                    setState(() {
                      _idiomaSelecionado = valor!;
                    });
                    _salvarConfiguracoes();
                  },
                ),
                RadioListTile<String>(
                  title: Text('Inglês (EN)', style: TextStyle(color: corTexto)),
                  value: 'EN',
                  groupValue: _idiomaSelecionado,
                  activeColor: Colors.teal,
                  onChanged: (String? valor) {
                    setState(() {
                      _idiomaSelecionado = valor!;
                    });
                    _salvarConfiguracoes();
                  },
                ),
                RadioListTile<String>(
                  title: Text(
                    'Espanhol (ES)',
                    style: TextStyle(color: corTexto),
                  ),
                  value: 'ES',
                  groupValue: _idiomaSelecionado,
                  activeColor: Colors.teal,
                  onChanged: (String? valor) {
                    setState(() {
                      _idiomaSelecionado = valor!;
                    });
                    _salvarConfiguracoes();
                  },
                ),
              ],
            ),
    );
  }
}
