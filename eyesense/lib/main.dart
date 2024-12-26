import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eyesense',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FaceDetectionPage(),
    );
  }
}

class FaceDetectionPage extends StatefulWidget {
  const FaceDetectionPage({super.key});

  @override
  State<FaceDetectionPage> createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  late IO.Socket socket;
  String detectedName = 'No face detected';
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  void connectToServer() {
    socket = IO.io(
        'http://192.168.0.103:5000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .build());

    socket.onConnect((_) {
      print('Connected to server');
      setState(() {
        isConnected = true;
      });
    });

    socket.on('face_detected', (data) {
      print('Received face_detected event: $data');
      if (data != null && data['name'] != null) {
        setState(() {
          detectedName = data['name'];
        });
      }
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
      setState(() {
        isConnected = false;
        detectedName = 'Disconnected from server';
      });
    });

    socket.onConnectError((err) => print('Connect error: $err'));
    socket.onError((err) => print('Socket error: $err'));
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detection'),
        actions: [
          Container(
            margin: const EdgeInsets.all(16.0),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? Colors.green : Colors.red,
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Detected Person:',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              detectedName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
