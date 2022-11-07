import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? position;
  var lat;
  var lon;

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    position = await Geolocator.getCurrentPosition();
    lat = position!.latitude;
    lon = position!.longitude;
    print("Position is ${position?.latitude} ${position?.longitude}");
    fetchWeatherData();
  }

  fetchWeatherData() async {
    String weatherApi =
        "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=9077b8bf74a0bc9ddb38883b2ff79491";
    String forecastApi =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=9077b8bf74a0bc9ddb38883b2ff79491";
    // String weatherApi =
    //     "https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=9077b8bf74a0bc9ddb38883b2ff79491";
    // String forecastApi =
    //     "https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=9077b8bf74a0bc9ddb38883b2ff79491";
    var weatherResponce = await http.get(Uri.parse(weatherApi));
    var forecastResponce = await http.get(Uri.parse(forecastApi));

    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponce.body));
      forecastMap =
          Map<String, dynamic>.from(jsonDecode(forecastResponce.body));
    });

    print("ppppppp ${weatherResponce.body}");
  }

  @override
  void initState() {
    // TODO: implement initState
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: weatherMap == null
            ? CircularProgressIndicator()
            : Container(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: [
                    Text(
                        "${Jiffy(DateTime.now()).format("MMM do yy, h:mm a")}"),
                    Text("${weatherMap!["name"]}"),
                    SizedBox(
                      height: 20,
                    ),
                    Text("${weatherMap!["main"]["temp"]}°"),
                    Text("Feels Like ${weatherMap!["main"]["feels_like"]}"),
                    Text(
                        "Feels Like ${weatherMap!["weather"][0]["description"]}"),
                    Image.network(
                        weatherMap!["weather"][0]["description"] == "haze"
                            ? "-----imager link----"
                            : weatherMap!["weather"][0]["description"] ==
                                    "cloud sky"
                                ? "-----imager link----"
                                : weatherMap!["weather"][0]["description"] ==
                                        "cloud sky"
                                    ? "-----imager link----"
                                    : ""),
                    Text(
                        "Humidity: ${weatherMap!["main"]["humidity"]}°, Pressure: ${weatherMap!["main"]["pressure"]}°"),
                    Text(
                        "Sunrise: ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)).format("h:mm a")}, Sunset: ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)).format("h:mm a")}"),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                          itemCount: forecastMap!.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 90,
                              child: Column(
                                children: [
                                  Text(
                                      "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("EEE, h:mm a")}"),
                                  Text(
                                      "${("${forecastMap!["list"][index]["weather"][0]["description"]}")}"),
                                ],
                              ),
                            );
                          }),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
