import 'package:clima/screens/map_screen.dart';
import 'package:clima/screens/shop_screen.dart';
import 'package:clima/services/mongo.dart';
import 'package:clima/services/weather.dart';
import 'package:clima/utilities/constants.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen(
      {super.key, this.locationWeather, this.todayLocationWeather});

  final locationWeather;
  final todayLocationWeather;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  WeatherModel weather = WeatherModel();
  late String cityName, weatherMessage, weatherIcon;
  late int temprature, humidity, speed;
  late List weathers;
  late Color weatherAmbience;
  late bool isError;
  dynamic airData = null;
  MongoDBService mongoService = MongoDBService();

  void getWeather(dynamic weatherData) {
    setState(() {
      if (weatherData == null) {
        temprature = 0;
        weatherIcon = 'error';
        weatherMessage = 'Unable to get weather data';
        cityName = 'City Not Found';
        weatherAmbience = weather.getWeatherAmbience(1000);
        isError = true;
        return;
      }
      int condition = weatherData['weather'][0]['id'];
      var temp = weatherData['main']['temp'];
      humidity = weatherData['main']['humidity'];
      double spdTemp = weatherData['wind']['speed'];
      speed = spdTemp.toInt();
      temprature = temp.toInt();
      cityName = weatherData['name'];
      weatherIcon = weather.getWeatherIcon(condition);
      weatherMessage = weather.getMessage(condition);
      weatherAmbience = weather.getWeatherAmbience(condition);
      isError = false;
    });
  }

  getTodayWeather(dynamic weatherData) {
    setState(() {
      weathers = weatherData['list'];
    });
  }

  _loadInitData() async {
    try {
      final items = await mongoService.getData('places');
      final airDataForCity =
          await mongoService.getDatByWhere('places', 'DKXVT0781');
      setState(() {
        airData = airDataForCity;
        cityName = airDataForCity[0]['name'];
      });
      return items;
    } catch (e) {
      // Handle errors
      print('Error loading data from MongoDB: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitData();
    getWeather(widget.locationWeather);
    getTodayWeather(widget.todayLocationWeather);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Stack(
            children: [
              ambience(weatherAmbience),
              Padding(
                padding: const EdgeInsets.only(top: 320),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      temprature.toString(),
                      style: kSemiBoldTextStyle.copyWith(fontSize: 92),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          Text(
                            '°C',
                            style: kSemiBoldTextStyle.copyWith(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 100,
                          child: GestureDetector(
                            onTap: () async {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  cityName,
                                  style: kSemiBoldTextStyle,
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Image.asset(
                    'images/$weatherIcon.png',
                    width: 250,
                    height: 250,
                  ),
                  SizedBox(
                    height: (isError) ? 130 : 80,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      weatherMessage,
                      textAlign: TextAlign.center,
                      style: kMediumTextStyle.copyWith(
                          fontSize: (isError) ? 25 : 32, color: kLightGrey),
                    ),
                  ),
                  SizedBox(
                    height: (isError) ? 0 : 10,
                  ),
                  (isError)
                      ? const SizedBox()
                      : Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          width: 300,
                          decoration: BoxDecoration(
                              color: const Color(0xFF212227),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 5,
                                  offset: const Offset(0, 4),
                                ),
                              ]),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'images/windspeed.png',
                                      width: 35,
                                      height: 35,
                                    ),
                                    Text(
                                      '$speed km/h',
                                      style: kMediumTextStyle.copyWith(
                                          fontSize: 15),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      'Wind',
                                      style: kMediumTextStyle.copyWith(
                                          fontSize: 12, color: kGrey),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                color: const Color(0xFF292A2F),
                                height: 50,
                                width: 3,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'images/humidity.png',
                                      width: 35,
                                      height: 35,
                                    ),
                                    Text(
                                      '$humidity%',
                                      style: kMediumTextStyle.copyWith(
                                          fontSize: 15),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      'Humidity',
                                      style: kMediumTextStyle.copyWith(
                                          fontSize: 12, color: kGrey),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                color: const Color(0xFF292A2F),
                                height: 50,
                                width: 3,
                              )
                            ],
                          ),
                        ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 5,
                            offset: const Offset(0, 4),
                          ),
                        ]),
                    child: Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/aqi.png',
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Text(
                                '${airData?[0]['aqi']}',
                                style: kMediumTextStyle.copyWith(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.normal,
                                    decorationStyle: TextDecorationStyle.solid,
                                    color: weather.getAirQualityAmbience(
                                        airData?[0]['aqi'] != null
                                            ? int.tryParse(
                                                    airData?[0]['aqi']) ??
                                                0
                                            : 0)),
                              ),
                              const SizedBox(
                                height: 1,
                              )
                            ],
                          ),
                          Text(
                            '${airData?[0]['aqiText']}',
                            style: kMediumTextStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              decorationStyle: TextDecorationStyle.solid,
                              color: weather.getAirQualityAmbience(
                                  airData?[0]['aqi'] != null
                                      ? int.tryParse(airData?[0]['aqi']) ?? 0
                                      : 0),
                            ),
                          ),
                          const SizedBox(height: 10)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 55,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Color.fromARGB(255, 242, 156, 9),
        color: const Color(0xFF212227),
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.home, size: 26, color: Colors.white),
          Icon(Icons.map, size: 26, color: Colors.white),
          Icon(Icons.shopping_cart_outlined, size: 26, color: Colors.white),
        ],
        animationCurve: Curves.linear,
        onTap: (index) async {
          if (index == 0) {
          } else if (index == 1) {
            final mapData = await _loadInitData();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MapScreen(airData: mapData)));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ShopScreen()));
          }
        },
      ),
    );
  }
}
