import 'package:smart_house_flutter/presentation/template/base/template.dart';

class DefaultBody extends StatelessWidget {
  Widget child;
  bool? centerTitle;
  Widget? titleIcon;
  Widget? leftButton;
  IconData? rightIcon;
  VoidCallback? onRightButtonClick;
  double? horizontalPadding;
  double? bottomPadding;
  double? topPadding;
  bool showAppBar;

  DefaultBody(
      {this.centerTitle = false,
      this.showAppBar = true,
      this.titleIcon,
      this.leftButton,
      required this.child,
      this.onRightButtonClick,
      this.bottomPadding = 0,
      this.horizontalPadding = 20,
      this.topPadding = 0,
      this.rightIcon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? DefaultHeader(
              centerTitle: centerTitle,
              leftButton: leftButton,
              titleIcon: titleIcon,
              onRightButtonClick: onRightButtonClick,
              rightIcon: rightIcon,
            )
          : null,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.only(
          left: horizontalPadding!.w,
          right: horizontalPadding!.w,
          bottom: bottomPadding!.h,
          top: topPadding!.h,
        ),
        child: child,
      )),
    );
  }
}
