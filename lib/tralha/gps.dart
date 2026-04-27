import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(Localizar());
}

class Localizar extends StatelessWidget {
  const Localizar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'GPS', home: Local());
  }
}

class Local extends StatefulWidget {
  const Local({super.key});

  @override
  State<Local> createState() => _LocalState();
}

class _LocalState extends State<Local> {
  Position? localizacao;

  Future<bool> permitido() async {
    bool gps_ativo;
    LocationPermission permicao;

    gps_ativo = await Geolocator.isLocationServiceEnabled();

    if (!gps_ativo) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("GPS Desabilitado")));
      return false;
    }

    permicao = await Geolocator.checkPermission();

    if (permicao == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permissão negada para sempre")),
      );
      return false;
    }

    if (permicao == LocationPermission.denied) {
      permicao = await Geolocator.requestPermission();
      if (permicao == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Permissão Negada")));
        return false;
      }
    }

    if (permicao == LocationPermission.always ||
        permicao == LocationPermission.whileInUse) {
      return true;
    }

    return false;
  }

  void PegarPosicao() async {
    final permissaoOK = await permitido();

    if (permissaoOK) {
      await Geolocator.getCurrentPosition()
          .then((Position pos) {
            setState(() {
              localizacao = pos;
            });
          })
          .catchError((e) {
            String erro = "Erro" + e.toString();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Erro: $e")));
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text("Latitude: ${localizacao?.latitude ?? ""}"),
            Text("Longitude: ${localizacao?.longitude ?? ""}"),
            ElevatedButton(
              onPressed: PegarPosicao,
              child: Text("Montrar Localização"),
            ),
          ],
        ),
      ),
    );
  }
}