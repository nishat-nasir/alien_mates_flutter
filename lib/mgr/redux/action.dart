import 'package:flutter/material.dart';
import 'package:alien_mates/mgr/models/model_exporter.dart';
export "./app_state.dart";

///----------------- Navigation -----------------
class NavigateToAction {
  final String? to;
  final bool replace;
  final dynamic arguments;

  // final Widget? page;
  final bool reload;
  final bool isStayPopup;

  NavigateToAction(
      {this.to,
      this.replace = false,
      this.arguments,
      // this.page,
      this.reload = false,
      this.isStayPopup = false});
}

class NavigateToOrderAction {}

class NavigateToPayListAction {}

class UpdateNavigationAction {
  final String? name;
  final bool? isPage;
  final String? method;

  UpdateNavigationAction({this.name, this.isPage, this.method});
}

class ShowPopupAction<T> {
  final bool barrierDismissible;
  final WidgetBuilder? builder;
  final bool dismissAll;

  ShowPopupAction(
      {this.barrierDismissible = true, this.builder, this.dismissAll = true});

  Future<T?> show(BuildContext context) {
    return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: builder!);
  }
}

class DismissPopupAction {
  final bool all;
  final dynamic result;

  DismissPopupAction({this.all = false, this.result});
}

///----------------- API -----------------

class GetAllKindPostsAction {}

class UpdateApiStateAction {
  List<ListPostModelRes>? posts;
  List<PostOnlyModel>? postOnly;
  List<UserModelRes>? users;
  UserModelRes? userMe;
  PostModelRes? postDetail;

  UpdateApiStateAction(
      {this.posts, this.postOnly, this.users, this.userMe, this.postDetail});
}

class GetStateInitAction {}

class GetCreatePostAction {
  String? description;
  String? imagePath;
  GetCreatePostAction({this.description, this.imagePath});
}

class GetCreateNoticeAction {
  String? imagePath;
  String title;
  String description;
  GetCreateNoticeAction(
      {required this.title, this.imagePath, required this.description});
}

class GetCreateEventAction {
  String? imagePath;
  String title;
  String description;
  int? joinLimit;
  String eventLocation;
  GetCreateEventAction(
      {required this.title,
      required this.description,
      this.imagePath,
      this.joinLimit,
      required this.eventLocation});
}

class GetCreateHelpAction {
  String title;
  String description;
  String? imagePath;
  GetCreateHelpAction(
      {required this.title, required this.description, this.imagePath});
}

class GetCreateUserAction {
  String phoneNumber;
  String name;
  String password;
  String uniName;

  GetCreateUserAction(
      {required this.phoneNumber,
      required this.uniName,
      required this.password,
      required this.name});
}

class GetUserIdExistAction {
  String userId;
  GetUserIdExistAction(this.userId);
}

class GetLoginAction {
  String phoneNumber;
  String password;
  GetLoginAction({required this.phoneNumber, required this.password});
}

class GetPostByIdAction {
  String postId;
  GetPostByIdAction(this.postId);
}

class GetUserByIdAction {
  String userId;
  GetUserByIdAction(this.userId);
}

class GetAllUsersAction {}

class GetDeletePostAction {
  String postId;
  GetDeletePostAction(this.postId);
}

class GetSelectImageAction {
  bool multipleImages;
  bool withCamera;
  GetSelectImageAction({this.multipleImages = false, this.withCamera = false});
}

class GetImageDownloadLinkAction {
  String imagePath;
  String? postType;
  GetImageDownloadLinkAction(this.imagePath, {this.postType});
}

class GetUpdatePostAction {
  String? imageUrl;
  int? numberOfLikes;
  List? joinedUserIds;
  String? title;
  String? description;
  String? eventLocation;
  bool? isPost;
  bool? isEvent;
  bool? isHelp;
  bool? isNotice;
  String? userId;
  int? joinLimit;
  String postId;
  String? createdDate;

  GetUpdatePostAction(
      {this.imageUrl,
      this.numberOfLikes,
      required this.postId,
      this.joinedUserIds,
      this.description,
      this.title,
      this.joinLimit,
      this.eventLocation,
      this.userId,
      this.isEvent,
      this.isNotice,
      this.isHelp,
      this.isPost,
      this.createdDate});
}

///----------------- Init -----------------

class GetLocalUserIdAction {}

class SetLocalUserIdAction {
  String userId;

  SetLocalUserIdAction(this.userId);
}

class RemoveLocalUserIdAction {}

class UpdateInitStateAction {
  String? userId;
  UpdateInitStateAction({this.userId});
}
