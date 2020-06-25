import 'package:flutter/material.dart';
import 'package:iotincubatorbleapp/bluetooth.dart';
import 'package:iotincubatorbleapp/pages/drawer.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:flutter/services.dart';

class DashBoard extends StatefulWidget {
  DashBoard({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<DashBoard> {
  //DatabaseHelper databaseHelper = DatabaseHelper();


  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // Track the Bluetooth connection with the remote device
  static BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green[700],
    'offTextColor': Colors.red[700],
    'neutralTextColor': Colors.blue,
  };

// To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  static BluetoothDevice _device;
  static bool _connected = false;
  bool _isButtonUnavailable = false;

//  @override
//  void initState() {
//
//  }

//  @override
//  void dispose() {
//    // Avoid memory leak and disconnect
//    if (isConnected) {
//      isDisconnecting = true;
////      connection.dispose();
////      connection = null;
//    }
//
//    super.dispose();
//  }
  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  final Color primaryColor = Color(0xff99cc33);
  bool _isLoading = false;
  double _temp = 0.0;
  double _hum = 0.0;

  @override
  void initState() {

    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
    super.initState();
    Bluewrapper().blueController.stream.listen(listenToClient);
  }

//  @override
//  void dispose() {
//
//  }

  void listenToClient(Map data) {
    if (this.mounted) {
      setState(() {
        print("I am coming from the iot device $data");
//     databaseHelper.InsertDatareading(Datareading.fromJson(data));
        double t = double.parse(data["temperature"].toString());
        double h = double.parse(data["humidity"].toString());

        _isLoading = true;
        _temp = t;
        _hum = h;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final control = Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ListTile(
              leading: IconButton(
                icon: Icon(Icons.control_point),
                onPressed: null,
              ),
              title: Text(
                'Control Panel',
                style: TextStyle(
                    color: Colors.deepOrange, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: IconButton(
                icon: Icon(Icons.lightbulb_outline),
                onPressed: null,
              ),
              title: Row(
                children: [
                  Text('Heat Control'),
                  Spacer(),
                  ButtonBar(
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.green,
                        child: const Text(
                          'On',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () { publish('heaton');},
                      ),
                      RaisedButton(
                        color: Colors.red,
                        child: const Text(
                          'Off',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {  publish('heatoff');},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: IconButton(
                icon: Icon(Icons.all_out),
                onPressed: null,
              ),
              title: Row(
                children: [
                  Text('Air Control'),
                  Spacer(),
                  ButtonBar(
                    children: <Widget>[
                      RaisedButton(
                        color: Colors.green,
                        child: const Text(
                          'On',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () { publish('airon');},
                      ),
                      RaisedButton(
                        color: Colors.red,
                        child: const Text(
                          'Off',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () { publish('airoff');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
//        elevation: 0.5,
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 10.0,
          ),
          _createListTile(
            "Temperature",
            _temp.toString(),
            "C",
          ),
          SizedBox(
            height: 5.0,
          ),
          _createListTile(
            "Humidity",
            _hum.toString(),
            "%",
          ),
          SizedBox(
            height: 5.0,
          ),
          control
        ],
      ),
      drawer: drawer,
    );
  }
  void publish(String value) {
    Bluewrapper().publish(value);
  }

  _createListTile(String title, String value, String initials) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, bottom: 5.0, right: 5.0),
      child: Card(
        elevation: 0.5,
        child: Container(
          height: 100.0,
          child: ListTile(
            trailing: Container(
              alignment: Alignment.center,
              height: 40.0,
              width: 30.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Text(
                initials,
                style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: !_isLoading
                ? Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 48.0,
                  color: Colors.black),
            )
                : Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1.0,
                )),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
//      connection.dispose();
//      connection = null;
    }

    super.dispose();
  }
}
