import 'package:flutter/material.dart';
import '../constant/dimens.dart';

class BackButtonWidget extends StatelessWidget {
  final Function onPressed;
  const BackButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: Dimens.medium,
      left: Dimens.medium,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 3),
              blurRadius: 18
          )],
        ),
        child: IconButton(onPressed: () => onPressed(), icon: const Icon(Icons.arrow_back)),
      ),
    );
  }
}
