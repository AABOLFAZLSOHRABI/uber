import 'package:flutter/material.dart';
import 'package:uber/constant/dimens.dart';
import 'package:uber/constant/text_styles.dart';
import '../widget/back_button.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            /// osm map
            Container(color: Colors.blueGrey),

            /// current Widget
            currentWidget(),

            BackButtonWidget(
              onPressed: () {
                if (currentWidgetList.length > 1) {
                  setState(() {
                    currentWidgetList.removeLast();
                  });
                }
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
          },
          child: Text("انتخاب مبدا", style: MyTextStyles.button),
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
          },
          child: Text("انتخاب مقصد", style: MyTextStyles.button),
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
          child: Text("درخواست راننده", style: MyTextStyles.button),
        ),
      ),
    );
  }
}
