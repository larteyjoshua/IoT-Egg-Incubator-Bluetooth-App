/*
 * Package : mqtt_client
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/05/2017
 * Copyright :  S.Hamblett
 */

import 'dart:async';
import 'dart:io';
import'dart:convert';
import 'package:iotincubatorbleapp/models/readings.dart';
import 'package:iotincubatorbleapp/utils/database_helper.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

//creating mqtt class
class Bluewrapper {

  StreamController<Map<String, dynamic>> blueController = StreamController
      .broadcast();
  static final Bluewrapper instance = Bluewrapper._internal();

  factory Bluewrapper () => instance;

  Bluewrapper._internal();
  DatabaseHelper databaseHelper = DatabaseHelper();

  /// An annotated simple subscribe/publish usage example for mqtt_client. Please read in with reference
  /// to the MQTT specification. The example is runnable, also refer to test/mqtt_client_broker_test...dart


         // final datasensor = json.decode(pt);
       //   blueController.add(datasensor);
       //   print(datasensor['temperature']);
       //   databaseHelper.InsertDatareading(Datareading.fromJson(datasensor));


//@override
//void dispose(){
 // Bluewrapper().blueController.close();
}


