import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
      Golfinho().salvar(_counter);
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    carregarDado();
    setState(() {});
  }

  void carregarDado() async {
    _counter = await Golfinho().devolverValor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Golfinho {
  Future<String> get diretorioApp async {
    // encontrar o diretório do aplicativo
    final diretorio = await getApplicationDocumentsDirectory();
    return diretorio.path;
  }

  Future<File> acessarArquivo(String arq) async {
    final caminho = await diretorioApp;
    // abrir o arquivo, passando o caminho + nome do arquivo
    return File('$caminho/$arq');
  }

  Future<File> salvar(int num) async {
    final arquivo = await acessarArquivo("agua.txt");
    // escrever o número no arquivo
    return arquivo.writeAsString(num.toString());
  }

  Future<int> devolverValor() async {
    final arquivo = await acessarArquivo("agua.txt");
    try {
      // ler o conteúdo do arquivo e converter para inteiro
      final valor = await arquivo.readAsString();
      return int.parse(valor);
    } catch (e) {
      // se ocorrer um erro (como o arquivo não existir), retornar 0
      print(e);
      return 0;
    }
  }
}
