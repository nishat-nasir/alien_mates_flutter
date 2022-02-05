import 'package:ionicons/ionicons.dart';
import 'package:alien_mates/mgr/navigation/app_routes.dart';
import 'package:alien_mates/mgr/redux/action.dart';
import 'package:alien_mates/presentation/template/base/template.dart';

class DefaultHeader extends StatelessWidget implements PreferredSizeWidget {
  bool? centerTitle;
  Widget? titleIcon;
  Widget? leftButton;
  IconData? rightIcon;
  VoidCallback? onRightButtonClick;
  SizedText? titleText;
  bool withAction;
  Color? bgColor;

  DefaultHeader({
    this.centerTitle = false,
    this.withAction = false,
    this.titleIcon,
    this.leftButton,
    this.onRightButtonClick,
    this.titleText,
    this.rightIcon,
    this.bgColor = ThemeColors.black,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      title: _buildTitle(),
      leading: leftButton,
      automaticallyImplyLeading: false,
      titleSpacing: 20.w,
      toolbarHeight: 40.h,
      actions: withAction ? _buildActions() : null,
      backgroundColor: bgColor,
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, 45.h);

  Widget _buildTitle() {
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
    if (centerTitle! || leftButton != null) {
      mainAxisAlignment = MainAxisAlignment.center;
    }
    Widget _container = Container();
    _container = Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        if (titleIcon != null) titleIcon!,
        if (titleIcon != null) SizedBox(width: 10.w),
        titleText ??
            SizedText(
              text: 'Alien Mates',
              textStyle: latoB30.copyWith(color: ThemeColors.coolgray300),
            ),
      ],
    );
    return _container;
  }

  List<Widget> _buildActions() {
    List<Widget> _list = [];
    if (rightIcon == null && onRightButtonClick == null) {
      print('isNull');
      _list.add(Container(
        margin: EdgeInsets.only(right: 10.w),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Ionicons.person_outline,
              color: ThemeColors.coolgray300),
          iconSize: 25.h,
          onPressed: () {
            appStore.dispatch(NavigateToAction(to: AppRoutes.profilePageRoute));
          },
        ),
      ));
    } else {
      print('isNotNull');

      _list.add(Container(
        margin: EdgeInsets.only(right: 10.w),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(rightIcon!, color: ThemeColors.bgLight),
          iconSize: 25.h,
          onPressed: onRightButtonClick,
        ),
      ));
    }

    return _list;
  }
}
