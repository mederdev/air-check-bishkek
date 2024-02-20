import 'dart:convert';

import 'package:clima/services/air-quality.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required this.airData}) : super(key: key);
  final List<Map<String, dynamic>> airData;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Set<Circle> circles = {}; // Set to hold circles
  final googleAirQualityService = GoogleAirQualityService();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      circles.addAll(
        widget.airData
            .where((data) => data['lat'] != null && data['long'] != null)
            .map((data) => Circle(
                circleId: CircleId(data['_id'].toString()),
                center: LatLng(data['lat'], data['long']),
                radius: 700,
                strokeColor: Colors.grey,
                strokeWidth: 1,
                fillColor: getAirQualityAmbience(int.parse(data['aqi'])),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.airData.length,
                          itemBuilder: (BuildContext context, int index) {
                            var aqiHistoryItem = widget.airData[index];
                            return Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                color: Color.fromARGB(255, 6, 86, 151),
                              ),
                              width: 150,
                              margin: const EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Date: ${aqiHistoryItem['date']}',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Time: ${aqiHistoryItem['dateTime']}',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'AQI: ${aqiHistoryItem['aqi']}',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'Status: ${aqiHistoryItem['aqiText']}',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                consumeTapEvents: true))
            .toSet(),
      );
    });
  }

  Color getAirQualityAmbience(int condition) {
    if (condition <= 50) {
      return Color.fromARGB(255, 5, 210, 26).withOpacity(0.4);
    } else if (condition >= 51 && condition <= 100) {
      return Color.fromARGB(255, 224, 217, 15).withOpacity(0.4);
    } else if (condition >= 101 && condition <= 150) {
      return Color.fromARGB(255, 243, 180, 8).withOpacity(0.4);
    } else if (condition >= 151 && condition <= 200) {
      return Color.fromARGB(255, 227, 18, 18).withOpacity(0.4);
    } else {
      return Color.fromARGB(255, 250, 54, 54).withOpacity(0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Air Quality')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(42.882004, 74.582748),
          zoom: 12.0,
        ),
        circles: circles,
        onLongPress: (LatLng latLng) async {
          final data = await googleAirQualityService.getAirQualityData(
              latLng.latitude, latLng.longitude);

          final currentStatus = data?['hoursInfo'][0];

          if (currentStatus == null) {
            currentStatus['indexes'] = [
              json.encode({
                "aqi": 0
                })
            ];
          }

          setState(() {
            circles.add(
              Circle(
                  circleId: CircleId(
                      DateTime.now().millisecondsSinceEpoch.toString()),
                  center: latLng,
                  radius: 800,
                  strokeColor: Colors.grey,
                  strokeWidth: 1,
                  fillColor: getAirQualityAmbience(currentStatus['indexes'][0]?['aqi']),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.airData.length,
                            itemBuilder: (BuildContext context, int index) {
                              var aqiHistoryItem = widget.airData[index];
                              return Container(
                                width: 150, // Adjust width as needed
                                margin: const EdgeInsets.all(5),
                                color: const Color.fromARGB(255, 6, 86, 151),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Date: ${aqiHistoryItem['date']}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'AQI: ${aqiHistoryItem['aqi']}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Status: ${aqiHistoryItem['aqiText']}',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  consumeTapEvents: true),
            );
          });
        },
      ),
    );
  }
}
