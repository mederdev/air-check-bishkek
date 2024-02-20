import 'package:clima/screens/main_screen.dart';
import 'package:clima/services/weather.dart';
import 'package:flutter/material.dart';
import 'package:clima/utilities/items.dart';
import 'package:clima/utilities/constants.dart';
import 'package:geolocator/geolocator.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<Widget> slides = items
      .map((item) => Container(
          padding: EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 100),
              Image.asset(
                item['image'],
                fit: BoxFit.fitWidth,
                width: 220.0,
                alignment: Alignment.bottomCenter,
              ),
              const SizedBox(height: 70),
              Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: <Widget>[
                      Text(item['header'],
                          style: const TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w300,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          textAlign: TextAlign.center),
                      SizedBox(height: 20),
                      Text(
                        item['description'],
                        style: const TextStyle(
                            color: Color.fromARGB(255, 132, 130, 130),
                            letterSpacing: 1.2,
                            fontSize: 16.0,
                            height: 1.3),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              )
            ],
          )))
      .toList();

  List<Widget> indicator() => List<Widget>.generate(
      slides.length,
      (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 3.0),
            height: 10.0,
            width: 10.0,
            decoration: BoxDecoration(
                color: currentPage.round() == index
                    ? Color(0XFF256075)
                    : Color(0XFF256075).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.0)),
          ));

  double currentPage = 0.0;
  dynamic weatherData;
  dynamic todayWeatherData;
  final _pageViewController = PageController();

  void _loadData() async {
    await Geolocator.requestPermission();
    try {
      weatherData = await Future.value(WeatherModel().getLocationWeather())
          .timeout(const Duration(seconds: 5));
      todayWeatherData =
          await Future.value(WeatherModel().getTodayLocationWeather())
              .timeout(const Duration(seconds: 5));
    } catch (e) {
      print('Failed to get data by $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _pageViewController.addListener(() {
      setState(() {
        currentPage = _pageViewController.page!;
      });
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    bool isLastPage = currentPage.round() == slides.length - 1;

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageViewController,
              itemCount: slides.length,
              itemBuilder: (BuildContext context, int index) {
                bool isLastSlide = currentPage == slides.length - 1;
                return Container(
                  child: Stack(
                    children: <Widget>[
                      slides[index],
                      if (isLastSlide)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainScreen(
                                              locationWeather: weatherData,
                                              todayLocationWeather:
                                                  todayWeatherData,
                                            )));
                              },
                              child: Text(
                                'Get Started',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: const Color.fromARGB(
                                        255, 254, 254, 254)),
                              ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: kGrey),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            if (!isLastPage)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 70.0),
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: indicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
