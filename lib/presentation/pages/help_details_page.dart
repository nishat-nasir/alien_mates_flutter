import 'package:alien_mates/presentation/widgets/button/expanded_btn.dart';
import 'package:alien_mates/presentation/widgets/input/basic_input.dart';
import 'package:alien_mates/utils/common/validators.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:ionicons/ionicons.dart';
import 'package:alien_mates/mgr/models/model_exporter.dart';
import 'package:alien_mates/mgr/navigation/app_routes.dart';
import 'package:alien_mates/mgr/redux/action.dart';
import 'package:alien_mates/mgr/redux/app_state.dart';
import 'package:alien_mates/mgr/redux/states/api_state.dart';
import 'package:alien_mates/presentation/template/base/template.dart';
import 'package:alien_mates/utils/common/log_tester.dart';

class HelpDetailsPage extends StatefulWidget {
  @override
  State<HelpDetailsPage> createState() => _HelpDetailsPageState();
}

class _HelpDetailsPageState extends State<HelpDetailsPage> {
  @override
  Widget build(BuildContext context) {
    print("IN HELP DETAIL PAGE");
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
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SpacedColumn(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  verticalSpace: 21,
                  children: [
                    if (state.apiState.postDetail.imageUrl != null)
                      PostItemBanner(
                          child: CachedNetworkImage(
                        imageUrl: state.apiState.postDetail.imageUrl!,
                        fit: BoxFit.cover,
                      )),
                    SpacedColumn(verticalSpace: 25, children: [
                      Container(
                          height: MediaQuery.of(context).size.height / 2,
                          alignment: Alignment.topLeft,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedText(
                                    text: state.apiState.postDetail.title,
                                    textStyle:
                                        latoB45.copyWith(color: Colors.white)),
                                SizedBox(height: 20.h),
                                SizedText(
                                  text: state.apiState.postDetail.description,
                                  textStyle:
                                      latoR16.copyWith(color: Colors.white),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          )),
                    ]),
                  ],
                ),
              ]),
            ),
            footer: Container(
              margin: EdgeInsets.only(bottom: 15.h),
              child: ExpandedButton(
                text: 'OKAY',
                onPressed: () {
                  appStore.dispatch(NavigateToAction(to: 'up'));
                },
              ),
            ),
          );
        });
  }

  Widget _buildTitleIcon() {
    return IconButton(
      padding: EdgeInsets.zero,
      iconSize: 25.w,
      icon: const Icon(Ionicons.chevron_back_outline),
      onPressed: () {
        appStore.dispatch(NavigateToAction(to: 'up'));
      },
    );
  }
}
