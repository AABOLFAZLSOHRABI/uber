// در فایل map_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uber/constant/dimens.dart';
import 'package:uber/constant/text_styles.dart';
import 'package:uber/consts/const_texts.dart';

// -------------------------------------------------------------------
// ویجت انتخاب مبدا
// -------------------------------------------------------------------
class SelectOriginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SelectOriginButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(ConstTexts.selectOrigin, style: MyTextStyles.button),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// ویجت انتخاب مقصد
// -------------------------------------------------------------------
class SelectDestinationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SelectDestinationButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(ConstTexts.selectDestination, style: MyTextStyles.button),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// ویجت درخواست راننده
// -------------------------------------------------------------------
class RequestDriverButton extends StatelessWidget {
  final VoidCallback onPressed; // در حال حاضر خالی است، اما برای توسعه می‌ماند

  const RequestDriverButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // حذف هرگونه Positioned یا Padding اضافی در اینجا
    return ElevatedButton(
      onPressed: onPressed,
      // مطمئن شوید ابعاد به درستی مدیریت می‌شوند، مثلاً ارتفاع مشخص اگر لازم است
      child: Text(ConstTexts.requestDriver, style: MyTextStyles.button),
    );
  }
}

// -------------------------------------------------------------------
// ویجت دکمه موقعیت‌یابی کاربر (User Location FAB)
// -------------------------------------------------------------------
class UserLocationFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading; // اضافه کردن پراپرتی لودینگ

  const UserLocationFAB({
    super.key,
    required this.onPressed,
    required this.isLoading, // ضروری
  });
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton(
        // دکمه را در حین لودینگ غیرفعال کنید تا جلوی کلیک‌های مکرر گرفته شود
        onPressed: isLoading ? null : onPressed,

        // نمایش لودینگ یا آیکون عادی
        child: isLoading
            ? const SpinKitThreeBounce(
          color: Colors.white, // رنگ لودینگ
          size: 20.0, // اندازه لودینگ
        )
            : const Icon(Icons.my_location),
      ),
    );
  }
}

// در فایل map_widgets.dart

class DistanceDisplayWidget extends StatelessWidget {
  final double? distanceKm;

  const DistanceDisplayWidget({super.key, required this.distanceKm});

  @override
  Widget build(BuildContext context) {
    if (distanceKm == null || distanceKm == 0) {
      return const SizedBox.shrink(); // اگر فاصله نامعلوم یا صفر است، چیزی نشان نده
    }

    final String distanceText = '${distanceKm!.toStringAsFixed(1)} کیلومتر';

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8), // برای فاصله با دکمه زیرین
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        'فاصله تقریبی: $distanceText',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }
}