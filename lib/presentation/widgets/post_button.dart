import 'package:smart_house_flutter/presentation/template/base/template.dart';

class PostButton extends StatelessWidget {
  Widget leftChild;
  Widget? rightChild;
  //if only one child needed, then pass leftChild only;
  PostButton({required this.leftChild, this.rightChild});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
              height: 27.h,
              alignment: Alignment.center,
              child: _buildChild(),
              decoration: BoxDecoration(
                color: ThemeColors.yellow,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.r),
                    bottomRight: Radius.circular(10.r)),
              )),
        ),
      ],
    );
  }

  Widget _buildChild() {
    if (rightChild != null) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        leftChild,
        Container(
            height: 25.h,
            width: 2.w,
            decoration: BoxDecoration(
              color: ThemeColors.bgDark,
              borderRadius: BorderRadius.circular(10000),
            )),
        rightChild!,
      ]);
    } else {
      return leftChild;
    }
  }
}
