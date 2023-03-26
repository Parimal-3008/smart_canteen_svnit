import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late BluetoothConnection connection;
  String _scanBarcode = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  void _sendDataToBluetooth() async {
    List<int> list = _scanBarcode.codeUnits;
    Uint8List bytes = Uint8List.fromList(list);
    connection.output.add(bytes);
    print(_scanBarcode);
    await connection.output.allSent;
  }

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text('Smart Canteen')),
            body: Builder(builder: (BuildContext context) {
              return Container(
                  alignment: Alignment.center,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                            onPressed: () => scanBarcodeNormal(),
                            child: Text('Scan')),
                        Text('Unique Id: $_scanBarcode\n',
                            style: TextStyle(fontSize: 20)),

                        // ignore: deprecated_member_use
                        RaisedButton(
                          child: Text('Connect to Bluetooth'),
                          onPressed: () async {
                            BluetoothDevice selectedDevice =
                                await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            BluetoothList()));
                            // ignore: unnecessary_null_comparison
                            if (selectedDevice != null) {
                              await BluetoothConnection.toAddress(
                                      selectedDevice.address)
                                  .then((value) {
                                print('Connected to ${selectedDevice.name}');
                                setState(() {
                                  connection = value;
                                });
                              });
                            }
                          },
                        ),

                        ElevatedButton(
                            onPressed: () => _sendDataToBluetooth(),
                            child: Text('Register the id')),
                      ]));
            })));
  }
}

class BluetoothList extends StatefulWidget {
  @override
  _BluetoothListState createState() => _BluetoothListState();
}

class _BluetoothListState extends State<BluetoothList> {
  List<BluetoothDevice> _devicesList = [];

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
  }

  void _getBondedDevices() {
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        _devicesList = bondedDevices;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paired Bluetooth Devices'),
      ),
      body: ListView.builder(
        itemCount: _devicesList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_devicesList[index].name!),
            subtitle: Text(_devicesList[index].address),
            onTap: () {
              Navigator.of(context).pop(_devicesList[index]);
            },
          );
        },
      ),
    );
  }
}
