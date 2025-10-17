import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:uber/constant/dimens.dart';
import 'package:uber/consts/const_texts.dart';
import 'package:uber/gen/assets.gen.dart';
import 'package:uber/widget/map_widgets.dart';
import 'package:uber/widget/toast_widget.dart';
import '../widget/back_button.dart';
import 'package:uber/service/location_service.dart';

enum MapState { selectOrigin, selectDestination, requestDriver }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  MapState currentMapState = MapState.selectOrigin;
  final MapController controller = MapController();
  final initialCenter = const LatLng(35.6892, 51.3890);
  LatLng? originPoint;
  LatLng? destinationPoint;
  bool _isLoadingLocation = false;
  double? tripDistanceKm;

  double _calculateDirectDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    final double meters = distance(point1, point2);
    return meters / 1000.0;
  }

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
                initialCenter: initialCenter,
                initialZoom: 13.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    if (currentMapState == MapState.selectOrigin) {
                      originPoint = point;
                    } else if (currentMapState == MapState.selectDestination) {
                      destinationPoint = point;
                    }
                    if (originPoint != null && destinationPoint != null) {
                      tripDistanceKm = _calculateDirectDistance(
                        originPoint!,
                        destinationPoint!,
                      );
                    } else {
                      tripDistanceKm = null;
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
                        child: SvgPicture.asset(
                          Assets.icons.origin,
                          height: 40,
                        ),
                      ),
                    if (destinationPoint != null)
                      Marker(
                        point: destinationPoint!,
                        width: 50,
                        height: 50,
                        child: SvgPicture.asset(
                          Assets.icons.destination,
                          height: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (currentMapState != MapState.requestDriver)
              UserLocationFAB(
                onPressed: _onLocationFABPressed,
                isLoading: _isLoadingLocation,
              ),
            currentWidget(),
            BackButtonWidget(onPressed: _handleBackButton),
          ],
        ),
      ),
    );
  }

  Widget currentWidget() {
    switch (currentMapState) {
      case MapState.selectOrigin:
        return SelectOriginButton(
          onPressed: () {
            setState(() {
              currentMapState = MapState.selectDestination;
            });
            showSuccessToast(ConstTexts.originSelected);
          },
        );

      case MapState.selectDestination:
        return SelectDestinationButton(
          onPressed: () {
            setState(() {
              currentMapState = MapState.requestDriver;
            });
            showSuccessToast(ConstTexts.destinationSelected);
          },
        );

      case MapState.requestDriver: // فقط یک بار تعریف شود
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(Dimens.large),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ۱. ویجت نمایش فاصله
                if (tripDistanceKm != null)
                  DistanceDisplayWidget(distanceKm: tripDistanceKm),

                // ۲. ویجت دکمه درخواست راننده
                RequestDriverButton(
                  onPressed: () {
                    // منطق درخواست راننده
                  },
                ),
              ],
            ),
          ),
        );
    }
  }

  void _handleBackButton() {
    setState(() {
      switch (currentMapState) {
        case MapState.selectOrigin:
          // اگر در اولین وضعیت هستیم، از صفحه خارج می‌شویم (یا کاری نمی‌کنیم)
          // Navigator.of(context).pop();
          break;
        case MapState.selectDestination:
          // بازگشت به انتخاب مبدا
          currentMapState = MapState.selectOrigin;
          originPoint = null; // پاک کردن مبدا در صورت نیاز
          break;
        case MapState.requestDriver:
          // بازگشت به انتخاب مقصد
          currentMapState = MapState.selectDestination;
          destinationPoint = null; // پاک کردن مقصد
          break;
      }
    });
  }

  // در کلاس _MapScreenState

  void _onLocationFABPressed() async {
    // ۱. شروع لودینگ
    setState(() => _isLoadingLocation = true);

    // ۲. فراخوانی سرویس LocationService با Callbacks
    LatLng? pos = await _locationService.getUserCurrentLocation(
      onGpsDisabled: () {
        // این Callback اجرا می‌شود اگر GPS خاموش باشد.
        // اگر logic باز کردن تنظیمات در LocationService باشد، این فقط یک log است.
        debugPrint('GPS Disabled or not enabled.');
      },
      onPermissionDenied: () {
        // این Callback اجرا می‌شود اگر مجوز رد شود.
        debugPrint('Location permission denied.');
      },
      onPermissionDeniedForever: () {
        // این Callback اجرا می‌شود اگر مجوز برای همیشه رد شود.
        debugPrint('Location permission denied forever.');
      },
    );

    // بررسی mounted قبل از setState
    if (!mounted) return;

    // ۳. پایان لودینگ
    setState(() => _isLoadingLocation = false);

    // ۴. استفاده از موقعیت دریافت شده و به‌روزرسانی UI
    if (pos != null) {
      setState(() {

        // تعیین نقطه بر اساس وضعیت فعلی نقشه
        if (currentMapState == MapState.selectOrigin) {
          originPoint = pos;
        } else if (currentMapState == MapState.selectDestination) {
          destinationPoint = pos;
        }

        // حرکت دوربین به موقعیت جدید
        controller.move(pos, 15.0);

        // محاسبه مجدد فاصله پس از تنظیم نقطه مقصد
        if (originPoint != null && destinationPoint != null) {
          tripDistanceKm = _calculateDirectDistance(originPoint!, destinationPoint!);
        }
      });
    }
  }

}
