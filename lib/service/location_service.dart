// در مسیر project/service/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart'; // برای استفاده از VoidCallback

// توجه: اگر قصد دارید showSuccessToast را در اینجا استفاده کنید،
// باید وابستگی به GlobalKey را در این فایل نیز Import کنید.
// import 'package:uber/consts/navigation_service.dart';
// import 'package:uber/widget/toast_widget.dart';

class LocationService {
  // این تابع را Public کنید (بدون _)
  Future<LatLng?> getUserCurrentLocation({
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

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      // اگر showSuccessToast نیاز به context داشته و شما از GlobalKey استفاده نکرده‌اید،
      // نمایش Toast در اینجا باعث ایجاد خطا می‌شود.
      // اما اگر از GlobalKey استفاده کرده‌اید، نمایش Toast بلامانع است.
      // showSuccessToast('خطای ناشناخته در دریافت موقعیت');
      debugPrint('Error getting user location: $e');
      return null;
    }
  }
}