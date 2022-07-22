import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isScanning = false;
  List<Region> regions = <Region>[];
  late StreamSubscription<RangingResult> _streamRanging;
  List<Beacon> rangingResults = List<Beacon>.empty(growable: true);
  late StreamSubscription<MonitoringResult> _streamMonitoring;
  Beacon? closestBeacon;

  void initBT() async {
    try {
      await flutterBeacon.initializeScanning;
    } on PlatformException catch (e) {
      log("Issue initizalizing bluetooth: $e");
    }

    if (Platform.isIOS) {
      regions.add(Region(identifier: "ZebraBeacons", proximityUUID: "FE913213-B311-4A42-8C16-47FAEAC938DC"));
      regions.add(Region(identifier: "", proximityUUID: "73697475-6d73-6974-756d-736974756d15"));
      //regions.add(Region(identifier: "", proximityUUID: "fe913213b3114a428c1647faeac938dc"));
      //regions.add(Region(identifier: "", proximityUUID: "fe913213-b311-4a42-8c16-47faeac938dc"));
    } else {
      regions.add(Region(identifier: "com.beacon"));
    }

    setState(() {
      isScanning = true;
    });
    _streamRanging = flutterBeacon.ranging(regions).listen((RangingResult results) {
      results.beacons.sort(((a, b) => a.major < b.major ? 0 : 1));
      rangingResults.clear();
      setState(() => rangingResults = results.beacons);
    });

    _streamMonitoring = flutterBeacon.monitoring(regions).listen((MonitoringResult results) {
      log("Event: ${results.monitoringEventType.toString()}");
    });
  }

  void stopScanning() {
    setState((() => isScanning = false));
    _streamRanging.cancel();
  }

  void startScanning() {
    setState((() => isScanning = true));
    _streamRanging = flutterBeacon.ranging(regions).listen(
      (RangingResult results) {
        results.beacons.sort(((a, b) => a.major < b.major ? 0 : 1));
        rangingResults.clear();
        setState(() => rangingResults = results.beacons);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initBT();
  }

  @override
  void dispose() {
    super.dispose();
    _streamRanging.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          isScanning ? Icons.stop : Icons.start,
          color: Colors.white,
        ),
        onPressed: () {
          if (isScanning) {
            stopScanning();
          } else {
            startScanning();
          }
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Beacon Scanner"),
      ),
      body: BeaconListView(
        beacons: rangingResults,
      ),
    );
  }
}

class BeaconListView extends StatefulWidget {
  const BeaconListView({Key? key, required this.beacons}) : super(key: key);
  final List<Beacon> beacons;

  @override
  State<BeaconListView> createState() => _BeaconListViewState();
}

class _BeaconListViewState extends State<BeaconListView> {
  @override
  Widget build(BuildContext context) {
    return widget.beacons.isEmpty
        ? const Center(
            child: Text("No Devices Found"),
          )
        : ListView.builder(
            itemCount: widget.beacons.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: Column(
                  children: [
                    Text("ID: ${widget.beacons[index].proximityUUID}"),
                    Text("Major: ${widget.beacons[index].major}       Minor: ${widget.beacons[index].minor}"),
                    Text("RSSI: ${widget.beacons[index].rssi}     ${widget.beacons[index].proximity}"),
                    Text("Power: ${widget.beacons[index].txPower}"),
                    const Divider(),
                  ],
                ),
              );
            });
  }
}
