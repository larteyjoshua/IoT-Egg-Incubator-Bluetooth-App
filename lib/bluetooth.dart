
import 'package:iotincubatorbleapp/models/readings.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'package:iotincubatorbleapp/utils/database_helper.dart';

//creating Blue class
class Bluewrapper {

  StreamController<Map<String, dynamic>> blueController = StreamController
      .broadcast();
  static final Bluewrapper instance = Bluewrapper._internal();

  factory Bluewrapper () => instance;

  Bluewrapper._internal();

  DatabaseHelper databaseHelper = DatabaseHelper();

  static BluetoothConnection connection;

  bool isDisconnecting = false;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  void onDataReceived(Uint8List data) {
    while (true) {
      if (data != null && data.length > 3) {
        print('Data incoming: ${ascii.decode(data)}');
        final datapoint = '${ascii.decode(data)}';
        final datasensor = json.decode(datapoint);
        blueController.add(datasensor);
        print(datasensor['temperature']);
        print(datasensor['humidity']);
        databaseHelper.InsertDatareading(Datareading.fromJson(datasensor));
        //connection.output.add(data); // Sending data
      }
      break;
    }
  }

  Future<void> publish(String value) async {
    connection.output.add(utf8.encode(value  + "\r\n")); // Sending data
    await connection.output.allSent;
    print("Command:  $value");
  }

  void dispose() {
    Bluewrapper().blueController.close();
  }
}