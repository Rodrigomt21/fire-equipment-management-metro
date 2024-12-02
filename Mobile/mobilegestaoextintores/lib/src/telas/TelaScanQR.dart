import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class ScannerQRCODE extends StatelessWidget {
  const ScannerQRCODE({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner QR Code')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const QRViewExample(),
            ));
          },
          child: const Text('Iniciar Scanner'),
        ),
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? resultado;
  QRViewController? controlador;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controlador?.pauseCamera();
    }
    controlador?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (resultado != null)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QRResultScreen(
                            resultado:
                                resultado?.code ?? 'Nenhum dado encontrado',
                          ),
                        ),
                      );
                    },
                    child: const Text('Ver Resultado'),
                  )
                else
                  const Text('Aguardando escaneamento...'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await controlador?.toggleFlash();
                        setState(() {});
                      },
                      child: FutureBuilder(
                        future: controlador?.getFlashStatus(),
                        builder: (context, snapshot) {
                          return Text(
                              'Flash: ${snapshot.data == true ? "Ligado" : "Desligado"}');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await controlador?.flipCamera();
                        setState(() {});
                      },
                      child: FutureBuilder(
                        future: controlador?.getCameraInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return Text(
                                'Câmera: ${describeEnum(snapshot.data!)}');
                          } else {
                            return const Text('Carregando...');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var areaDeScan = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.green,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: areaDeScan,
      ),
      onPermissionSet: (ctrl, permissao) =>
          _onPermissionSet(context, ctrl, permissao),
    );
  }

  void _onQRViewCreated(QRViewController controlador) {
    setState(() {
      this.controlador = controlador;
    });
    controlador.scannedDataStream.listen((dadosEscaneados) {
      setState(() {
        resultado = dadosEscaneados;
      });
    });
  }

  void _onPermissionSet(
      BuildContext context, QRViewController ctrl, bool permissao) {
    if (!permissao) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão negada')),
      );
    }
  }

  @override
  void dispose() {
    controlador?.dispose();
    super.dispose();
  }
}

class QRResultScreen extends StatelessWidget {
  final String resultado;

  const QRResultScreen({Key? key, required this.resultado}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado do QR Code')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Dados do QR Code:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                resultado,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
