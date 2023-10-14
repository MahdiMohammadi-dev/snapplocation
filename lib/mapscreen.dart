import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snapp/styles.dart';
import 'dimens.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UserStateButton {
  UserStateButton._();
  static const setmabdastate = 0;
  static const setmaghsadstate = 1;
  static const requestDriverstate = 2;
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String distanceText = "محاسبه مسیر...";
  List liststate = [UserStateButton.setmabdastate];
  List<GeoPoint> geopint = [];
  Widget markericon = SvgPicture.asset(
    'assets/icons/origin.svg',
    height: 100,
    width: 40,
  );
  Widget destinationicon = SvgPicture.asset(
    'assets/icons/destination.svg',
    height: 100,
    width: 40,
  );
  MapController mapController = MapController(
      initMapWithUserPosition: false,
      initPosition: GeoPoint(latitude: 35.6997331, longitude: 51.3380361));
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            ///TODO:Map Section
            SizedBox.expand(
              child: OSMFlutter(
                controller: mapController,
                initZoom: 16,
                maxZoomLevel: 18,
                minZoomLevel: 8,
                mapIsLoading: SpinKitCubeGrid(color: Colors.black),
                trackMyPosition: false,
                isPicker: true,
                stepZoom: 1,
                markerOption: MarkerOption(
                    advancedPickerMarker: MarkerIcon(
                  iconWidget: markericon,
                )),
              ),
            ),

            ///TODO:Submit Location Button
            buttoniwdget(),

            ///TODO:Back Button
            MyBackButton(),
          ],
        ),
      ),
    );
  }

  Widget MyBackButton() {
    return Positioned(
      left: Dimens.medium,
      top: Dimens.medium,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(2, 3),
              )
            ]),
        child: IconButton(
          onPressed: () {
            if (geopint.isNotEmpty) {
              geopint.removeLast();
              destinationicon = markericon;
              mapController.init();
            }
            print("Geolength:" + geopint.length.toString());

            if (liststate.length > 1) {
              setState(() {
                liststate.removeLast();
              });
              print("Lenth: " + liststate.length.toString());
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
    );
  }

  Widget buttoniwdget() {
    Widget widget = setMabda();
    switch (liststate.last) {
      case UserStateButton.setmabdastate:
        widget = setMabda();
        break;
      case UserStateButton.setmaghsadstate:
        widget = setMaghsad();
        break;
      case UserStateButton.requestDriverstate:
        widget = requestDriver();
        break;
    }
    return widget;
  }

  Widget setMabda() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: ElevatedButton(
            onPressed: () async {
              GeoPoint origingeopoint = await mapController
                  .getCurrentPositionAdvancedPositionPicker();
              geopint.add(origingeopoint);
              markericon = destinationicon;
              setState(() {
                liststate.add(UserStateButton.setmaghsadstate);
                log("The lenght${liststate.length}");
              });
              mapController.init();
              print("GeoL:  " + geopint.length.toString());
            },
            child: Text(
              "ثبت مبدا",
              style: MyTextStyles.button,
            )),
      ),
    );
  }

  Widget setMaghsad() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: ElevatedButton(
            onPressed: () async {
              await mapController
                  .getCurrentPositionAdvancedPositionPicker()
                  .then((value) {
                geopint.add(value);
              });

              await mapController.addMarker(geopint.first,
                  markerIcon: MarkerIcon(
                    iconWidget: markericon,
                  ));
              await mapController.addMarker(geopint.last,
                  markerIcon: MarkerIcon(
                    iconWidget: destinationicon,
                  ));

              mapController.cancelAdvancedPositionPicker();

              setState(() {
                liststate.add(UserStateButton.requestDriverstate);
              });
              await distance2point(geopint.first, geopint.last).then((value) {
                setState(() {
                  if (value <= 1000) {
                    distanceText = "فاصله مبدا تا مقصد کمتر از هزار متر است";
                  } else {
                    distanceText =
                        "فاصله ی مبدا تا مقصد ${value ~/ 1000} کیلومتراست";
                  }
                });
              });
            },
            child: Text(
              "ثبت مقصد",
              style: MyTextStyles.button,
            )),
      ),
    );
  }

  Widget requestDriver() {
    mapController.zoomOut();
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimens.medium)),
              width: double.infinity,
              height: 60,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(distanceText,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.vazirmatn(
                        fontWeight: FontWeight.w700, color: Colors.black)),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      liststate.add(UserStateButton.setmabdastate);
                    });
                  },
                  child: Text(
                    "درخواست راننده",
                    style: MyTextStyles.button,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
