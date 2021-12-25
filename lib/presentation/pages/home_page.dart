import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:ionicons/ionicons.dart';
import 'package:smart_house_flutter/mgr/models/model_exporter.dart';
import 'package:smart_house_flutter/mgr/redux/action.dart';
import 'package:smart_house_flutter/mgr/redux/app_state.dart';
import 'package:smart_house_flutter/presentation/template/base/template.dart';

class HomePage extends StatelessWidget {
  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: appStore,
      child: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) => DefaultBody(
                  child: SizedBox(
                height: 200.h,
                child: ListView(
                  controller: _controller,
                  children: [..._buildPostsWidgetList(state)],
                ),
              ))),
    );
  }

  List<Widget> _buildPostsWidgetList(AppState state) {
    List<Widget> _list = [];
    List<ListPostModelRes> postsList = state.apiState.posts;

    for (int i = 0; i < postsList.length; i++) {
      _list.add(PostItemBanner(
          child: CachedNetworkImage(
        imageUrl: state.apiState.posts[i].imageUrl!,
        fit: BoxFit.cover,
      )));
    }
    return _list;
  }
}
