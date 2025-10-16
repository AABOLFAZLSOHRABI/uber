import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:uber/constant/dimens.dart';
import 'package:uber/constant/text_styles.dart';
import 'package:uber/consts/const_texts.dart';
import 'package:uber/widget/toast_widget.dart';
import '../widget/back_button.dart';
import 'package:geolocator/geolocator.dart';

Future<LatLng?> _getUserCurrentLocation({
  required VoidCallback onGpsDisabled,
  required VoidCallback onPermissionDenied,
  required VoidCallback onPermissionDeniedForever,
}) async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onGpsDisabled();
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        onPermissionDenied();
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      onPermissionDeniedForever();
      await Geolocator.openAppSettings();
      return null;
    }

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    return LatLng(position.latitude, position.longitude);
  } catch (e) {
    return null;
  }
}


class CurrentWidgetState {
  CurrentWidgetState._();

  static const stateSelectOrigin = 0;
  static const stateSelectDestination = 1;
  static const stateRequestDriver = 2;
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List currentWidgetList = [CurrentWidgetState.stateSelectOrigin];
  final controller = MapController();
  final LatLng userLocation = LatLng(35.6892, 51.3890);
  LatLng? originPoint;
  LatLng? destinationPoint;


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            /// osm map
            /// current Widget
            FlutterMap(
              mapController: controller,
              options: MapOptions(
                initialCenter: LatLng(35.6892, 51.3890),
                initialZoom: 13.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    if (currentWidgetList.last ==
                        CurrentWidgetState.stateSelectOrigin) {
                      originPoint = point;
                    } else if (currentWidgetList.last ==
                        CurrentWidgetState.stateSelectDestination) {
                      destinationPoint = point;
                    }
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.uber',
                ),
                MarkerLayer(
                  markers: [
                    if (originPoint != null)
                      Marker(
                        point: originPoint!,
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 40,
                        ),
                      ),
                    if (destinationPoint != null)
                      Marker(
                        point: destinationPoint!,
                        width: 50,
                        height: 50,
                        child: Icon(Icons.my_location_sharp, color: Colors.red, size: 40),
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 100,
              right: 20,
              child: FloatingActionButton(
                onPressed: () async {
                  // نمایش پیام در حال دریافت موقعیت
                  showSuccessToast(context, ConstTexts.gettingPosition);

                  LatLng? pos = await _getUserCurrentLocation(
                    onGpsDisabled: () => showSuccessToast(context, ConstTexts.pleaseEnableGPS),
                    onPermissionDenied: () => showSuccessToast(context, ConstTexts.accessNotGranted),
                    onPermissionDeniedForever: () => showSuccessToast(context, ConstTexts.accessNotGranted),
                  );

                  if (pos != null) {
                    setState(() {
                      originPoint = pos;
                      controller.move(pos, 15.0);
                    });
                    showSuccessToast(context, ConstTexts.locationHasBeenDisplayed);
                  }
                },
                child: const Icon(Icons.my_location),
              ),
            ),
            currentWidget(),
            BackButtonWidget(
              onPressed: () {
                if (currentWidgetList.length <= 1) {
                  // Navigator.of(context).pop();
                  return;
                }

                // اگر بیش از یک حالت هست، حذف-last و پاک کردن نقطه مربوطه
                setState(() {
                  // حذف حالت فعلی
                  currentWidgetList.removeLast();

                  // حالت فعلی جدید بعد از حذف
                  final currentState = currentWidgetList.isNotEmpty
                      ? currentWidgetList.last
                      : CurrentWidgetState.stateSelectOrigin;

                  // اگر برگشتیم به صفحه انتخاب مبدا => مبدا رو پاک کن
                  if (currentState == CurrentWidgetState.stateSelectOrigin) {
                    originPoint = null;
                  }
                  // اگر برگشتیم به صفحه انتخاب مقصد => مقصد رو پاک کن
                  else if (currentState == CurrentWidgetState.stateSelectDestination) {
                    destinationPoint = null;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget currentWidget() {
    Widget widget = origin();
    switch (currentWidgetList.last) {
      case CurrentWidgetState.stateSelectOrigin:
        widget = origin();
        break;
      case CurrentWidgetState.stateSelectDestination:
        widget = dest();
        break;
      case CurrentWidgetState.stateRequestDriver:
        widget = reqDriver();
        break;
    }
    return widget;

  }
  Positioned origin() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              currentWidgetList.add(CurrentWidgetState.stateSelectDestination);
            });
            showSuccessToast(context, ConstTexts.originSelected);
          },
          child: Text(ConstTexts.selectOrigin, style: MyTextStyles.button),
        ),
      ),
    );
  }

  Positioned dest() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              currentWidgetList.add(CurrentWidgetState.stateRequestDriver);
            });
            showSuccessToast(context, ConstTexts.destinationSelected);
          },
          child: Text(ConstTexts.selectDestination, style: MyTextStyles.button),
        ),
      ),
    );
  }

  Positioned reqDriver() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: ElevatedButton(
          onPressed: () {},
          child: Text(ConstTexts.requestDriver, style: MyTextStyles.button),
        ),
      ),
    );
  }
}
