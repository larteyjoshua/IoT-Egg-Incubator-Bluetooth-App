/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/05/2017
 * Copyright :  S.Hamblett
 */

import 'package:flutter/material.dart';
import 'package:iotincubatorbleapp/models/readings.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
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

  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  static BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;
  static bool _connected = false;


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
    if (_bluetoothState == BluetoothState.STATE_ON) {
      connection.output.add(utf8.encode(value + "\r\n"));
      await connection.output.allSent; // Sending data
      print("Command:  $value");
    }
  }

  @override
  void dispose() {
    Bluewrapper().blueController.close();
  }
}

