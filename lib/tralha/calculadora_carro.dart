import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CalculadoraFlexApp());
}

class CalculadoraFlexApp extends StatelessWidget {
  const CalculadoraFlexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Flex',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const CalculadoraHomePage(),
    );
  }
}

class CalculadoraHomePage extends StatefulWidget {
  const CalculadoraHomePage({super.key});

  @override
  State<CalculadoraHomePage> createState() => _CalculadoraHomePageState();
}

class _CalculadoraHomePageState extends State<CalculadoraHomePage> {
  final _rendimentoGasolinaCtrl = TextEditingController();
  final _rendimentoEtanolCtrl = TextEditingController();
  final _precoGasolinaCtrl = TextEditingController();
  final _precoEtanolCtrl = TextEditingController();

  String _resultado = 'Preencha os valores para calcular.';

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rendimentoGasolinaCtrl.text =
          prefs.getString('rendimento_gasolina') ?? '';
      _rendimentoEtanolCtrl.text = prefs.getString('rendimento_etanol') ?? '';
    });
  }

  Future<void> _salvarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rendimento_gasolina', _rendimentoGasolinaCtrl.text);
    await prefs.setString('rendimento_etanol', _rendimentoEtanolCtrl.text);
  }

  void _calcular() {
    double? rendGasolina = double.tryParse(
      _rendimentoGasolinaCtrl.text.replaceAll(',', '.'),
    );
    double? rendEtanol = double.tryParse(
      _rendimentoEtanolCtrl.text.replaceAll(',', '.'),
    );
    double? precoGasolina = double.tryParse(
      _precoGasolinaCtrl.text.replaceAll(',', '.'),
    );
    double? precoEtanol = double.tryParse(
      _precoEtanolCtrl.text.replaceAll(',', '.'),
    );

    if (rendGasolina == null ||
        rendEtanol == null ||
        precoGasolina == null ||
        precoEtanol == null) {
      setState(() {
        _resultado = 'Por favor, insira valores numéricos válidos.';
      });
      return;
    }

    if (rendGasolina <= 0 || rendEtanol <= 0) {
      setState(() {
        _resultado = 'O rendimento deve ser maior que zero.';
      });
      return;
    }

    _salvarPreferencias();

    double custoKmGasolina = precoGasolina / rendGasolina;
    double custoKmEtanol = precoEtanol / rendEtanol;

    setState(() {
      if (custoKmEtanol < custoKmGasolina) {
        _resultado =
            'Abasteça com ETANOL!\n\n'
            'Custo Etanol: R\$ ${custoKmEtanol.toStringAsFixed(2)} por km\n'
            'Custo Gasolina: R\$ ${custoKmGasolina.toStringAsFixed(2)} por km';
      } else if (custoKmGasolina < custoKmEtanol) {
        _resultado =
            'Abasteça com GASOLINA!\n\n'
            'Custo Gasolina: R\$ ${custoKmGasolina.toStringAsFixed(2)} por km\n'
            'Custo Etanol: R\$ ${custoKmEtanol.toStringAsFixed(2)} por km';
      } else {
        _resultado =
            'Tanto faz! O custo por km é igual.\n'
            '(R\$ ${custoKmGasolina.toStringAsFixed(2)}/km)';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora Flex'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Desempenho do Veículo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _rendimentoGasolinaCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Rendimento com Gasolina (km/l)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _rendimentoEtanolCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Rendimento com Etanol (km/l)',
                border: OutlineInputBorder(),
              ),
            ),
            const Divider(height: 40, thickness: 2),
            const Text(
              'Preço na Bomba',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _precoGasolinaCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Preço da Gasolina (R\$)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _precoEtanolCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Preço do Etanol (R\$)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calcular,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('CALCULAR', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                _resultado,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rendimentoGasolinaCtrl.dispose();
    _rendimentoEtanolCtrl.dispose();
    _precoGasolinaCtrl.dispose();
    _precoEtanolCtrl.dispose();
    super.dispose();
  }
}
