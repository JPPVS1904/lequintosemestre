import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:cross_file/cross_file.dart';
import 'package:video_player/video_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // lista de câmeras disponíveis
  final camerasDisponiveis = await availableCameras();
  // camera principal
  final camera = camerasDisponiveis.first;
  runApp(CameraApp(camera: camera));
}

class CameraApp extends StatelessWidget {
  // passar camera como parâmetro
  const CameraApp({super.key, required this.camera});
  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Camera",
      home: CameraScreen(camera: camera),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.camera});
  final CameraDescription camera;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controlador;
  late Future<void> _incializarControlador;
  XFile? video;

  @override
  void initState() {
    super.initState();
    _controlador = CameraController(widget.camera, ResolutionPreset.ultraHigh);
    _incializarControlador = _controlador.initialize();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Camera")),
      body: FutureBuilder(
        future: _incializarControlador,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(flex: 9, child: CameraPreview(_controlador)),
                Expanded(child: barraDeCaptura()),
                Expanded(child: Text("")),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _incializarControlador;
            final foto = await _controlador.takePicture();
            if (!context.mounted) {
              return;
            }

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MostrarFoto(caminho: foto.path),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Erro: $e")));
          }
        },
        child: Icon(Icons.camera_alt_rounded),
      ),
    );
  }

  Widget barraDeCaptura() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed:
              _controlador.value.isInitialized &&
                  _controlador.value.isRecordingVideo
              ? inicializarGravacao
              : null,
          icon: Icon(Icons.videocam),
          color: Colors.grey,
        ),
        IconButton(
          onPressed:
              _controlador.value.isInitialized &&
                  _controlador.value.isRecordingVideo
              ? _controlador.value.isRecordingPaused
                    ? retomarGravacao
                    : pausarGravacao
              : null,
          icon: _controlador.value.isRecordingPaused
              ? Icon(Icons.play_arrow)
              : Icon(Icons.pause),
          color: _controlador.value.isRecordingPaused
              ? Colors.grey
              : Colors.red,
        ),
        IconButton(
          onPressed:
              _controlador.value.isInitialized &&
                  _controlador.value.isRecordingVideo
              ? pararGravacao
              : null,
          icon: Icon(Icons.stop),
          color: Colors.grey,
        ),
      ],
    );
  }

  void inicializarGravacao() {
    inicializar().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> inicializar() async {
    final CameraController controlador = _controlador;
    if (!controlador.value.isInitialized) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: Camera não inicializada")));
      return;
    }
    if (controlador.value.isRecordingVideo) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: Já está gravando")));
      return;
    }
    try {
      await controlador.startVideoRecording();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
      rethrow;
    }
  }

  void retomarGravacao() {
    retomar().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> retomar() async {
    final CameraController controlador = _controlador;
    if (!controlador.value.isInitialized) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: Camera não inicializada")));
      return;
    }
    if (!controlador.value.isRecordingVideo) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: Não está gravando")));
      return;
    }
    if (!controlador.value.isRecordingPaused) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: A gravação não está pausada")),
      );
      return;
    }
    try {
      await controlador.resumeVideoRecording();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
      rethrow;
    }
  }

  void pausarGravacao() {
    pausar().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> pausar() async {
    final CameraController controlador = _controlador;
    if (!controlador.value.isInitialized) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: Camera não inicializada")));
      return;
    }
    if (!controlador.value.isRecordingVideo) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: Não está gravando")));
      return;
    }
    if (controlador.value.isRecordingPaused) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: A gravação já está pausada")),
      );
      return;
    }
    try {
      await controlador.pauseVideoRecording();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
      rethrow;
    }
  }

  void pararGravacao() {
    parar().then((XFile? video) {
      if (mounted) {
        setState(() {});
      }
      if (video != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => MostrarVideo(video: video)),
        );
      }
    });
  }

  Future<XFile?> parar() async {
    final CameraController controlador = _controlador;
    if (!controlador.value.isInitialized) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: Camera não inicializada")));
      return null;
    }
    if (!controlador.value.isRecordingVideo) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: Não está gravando")));
      return null;
    }
    try {
      final XFile arquivo = await controlador.stopVideoRecording();
      return arquivo;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
      rethrow;
    }
  }
}

class MostrarFoto extends StatelessWidget {
  const MostrarFoto({super.key, required this.caminho});
  final String caminho;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Foto")),
      body: Image.network(caminho),
    );
  }
}

class MostrarVideo extends StatefulWidget {
  const MostrarVideo({super.key, required this.video});
  final XFile? video;

  @override
  State<MostrarVideo> createState() => _MostrarVideoState();
}

class _MostrarVideoState extends State<MostrarVideo> {
  VideoPlayerController? _controlador;
  VoidCallback? _videoListener;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Video Gravado")),
      body: Row(
        children: [
          if (_controlador == null)
            Container()
          else
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _controlador!.value.aspectRatio,
                  child: VideoPlayer(_controlador!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    inicializarVideo();
  }

  Future<void> inicializarVideo() async {
    XFile? video = widget.video;
    if (video == null) {
      return;
    }
    final VideoPlayerController controlador = kIsWeb
        ? VideoPlayerController.networkUrl(Uri.parse(video.path))
        : VideoPlayerController.file(File(video.path));

    _videoListener = () {
      if (_controlador != null) {
        if (_controlador!.value.isInitialized) {
          setState(() {});
        }
        controlador.removeListener(_videoListener!);
      }
    };
    controlador.addListener(_videoListener!);
    await controlador.setLooping(true);
    await controlador.initialize();
    await _controlador?.dispose();
    if (mounted) {
      setState(() {
        _controlador = controlador;
      });
    }
    controlador.play();
  }
}
