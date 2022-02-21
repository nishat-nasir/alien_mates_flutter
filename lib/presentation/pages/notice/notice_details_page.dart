import 'package:alien_mates/mgr/redux/action.dart';
import 'package:alien_mates/mgr/redux/app_state.dart';
import 'package:alien_mates/presentation/template/base/template.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:ionicons/ionicons.dart';

class NoticeDetailsPage extends StatelessWidget {
  const NoticeDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return DefaultBody(
            withTopBanner: false,
            withNavigationBar: false,
            withActionButton: false,
            titleIcon: _buildTitleIcon(),
            titleText: SizedText(text: 'Back', textStyle: latoM20),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 50.h),
              child: SpacedColumn(
                verticalSpace: 21,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.apiState.postDetail.imageUrl != null)
                    PostItemBanner(
                        height: 200.h,
                        child: CachedNetworkImage(
                          imageUrl: state.apiState.postDetail.imageUrl!,
                          fit: BoxFit.cover,
                        )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      SizedText(
                          text: state.apiState.postDetail.title,
                          textStyle:
                              latoB25.copyWith(color: ThemeColors.coolgray100)),
                      SizedBox(height: 20.h),
                      SizedText(
                        text: state.apiState.postDetail.description,
                        textStyle:
                            latoR16.copyWith(color: ThemeColors.coolgray400),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildTitleIcon() {
    return IconButton(
      padding: EdgeInsets.zero,
      iconSize: 30.w,
      icon: const Icon(Ionicons.arrow_back),
      onPressed: () {
        appStore.dispatch(NavigateToAction(to: 'up'));
      },
    );
  }
}
