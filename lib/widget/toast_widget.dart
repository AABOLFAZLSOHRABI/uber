import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../constant/text_styles.dart';

void showSuccessToast(BuildContext context, String message) {
  toastification.show(
    style: ToastificationStyle.flat,
    context: context,
    type: ToastificationType.success,
    title: Text(message, style: MyTextStyles.toast),
    autoCloseDuration: const Duration(seconds: 3),
    alignment: Alignment.topRight,
    direction: TextDirection.rtl,
  );
}
