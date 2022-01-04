import 'dart:io';
import 'dart:typed_data';

import 'package:alien_mates/mgr/models/univ_model/univ_model.dart';
import 'package:alien_mates/mgr/navigation/app_routes.dart';
import 'package:alien_mates/mgr/rest/api_service_client.dart';
import 'package:alien_mates/presentation/widgets/show_alert_dialog.dart';
import 'package:alien_mates/utils/common/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redux/redux.dart';
import 'package:alien_mates/mgr/firebase/firebase_kit.dart';
import 'package:alien_mates/mgr/models/model_exporter.dart';
import 'package:alien_mates/mgr/redux/action.dart';
import 'package:alien_mates/mgr/redux/app_state.dart';
import 'package:alien_mates/presentation/template/base/template.dart';
import 'package:alien_mates/utils/common/global_widgets.dart';
import 'package:alien_mates/utils/common/log_tester.dart';
import 'package:uuid/uuid.dart';

FirebaseKit firebaseKit = FirebaseKit();
final postsCollection = firebaseKit.postsCollection;
final usersCollection = firebaseKit.usersCollection;
const uuid = Uuid();
final now = DateTime.now();
final currentDateAndTime =
    "${now.year}.${now.month}.${now.day}T${now.hour}.${now.minute}.${now.second}";
final currentDate = "${now.year}.${now.month}.${now.day}";

class ApiMiddleware extends MiddlewareClass<AppState> {
  @override
  call(Store<AppState> store, action, next) {
    switch (action.runtimeType) {
      case GetAllKindPostsAction:
        return _getAllKindPostsAction(store.state, action, next);
      case GetCreatePostAction:
        return _getCreatePostAction(store.state, action, next);
      case GetCreateEventAction:
        return _getCreateEventAction(store.state, action, next);
      case GetCreateNoticeAction:
        return _getCreateNoticeAction(store.state, action, next);
      case GetCreateHelpAction:
        return _getCreateHelpAction(store.state, action, next);
      case GetCreateUserAction:
        return _getCreateUserAction(store.state, action, next);
      case GetAllUsersAction:
        return _getAllUsersAction(store.state, action, next);
      case GetUserIdExistAction:
        return _getUserIdExistAction(store.state, action, next);
      case GetLoginAction:
        return _getLoginAction(store.state, action, next);
      case GetPostByIdAction:
        return _getPostByIdAction(store.state, action, next);
      case GetUserByIdAction:
        return _getUserByIdAction(store.state, action, next);
      case GetUpdatePostAction:
        return _getUpdatePostAction(store.state, action, next);
      case GetDeletePostAction:
        return _getDeletePostAction(store.state, action, next);
      case GetSelectImageAction:
        return _getSelectImageAction(store.state, action, next);
      case GetImageDownloadLinkAction:
        return _getImageDownloadLinkAction(store.state, action, next);
      case GetSearchUniversityAction:
        return _getSearchUniversityAction(store.state, action, next);
      case GetUpdateUserAction:
        return _getUpdateUserAction(store.state, action, next);
      case GetLogoutUserAction:
        return _logout(store.state, action);
      default:
        return next(action);
    }
  }
}

Future<bool> _getAllKindPostsAction(
    AppState state, GetAllKindPostsAction action, NextDispatcher next) async {
  List<ListPostModelRes> postsList = await _getPostsList();
  next(UpdateApiStateAction(posts: postsList));
  return postsList.isNotEmpty;
}

Future<List<ListPostModelRes>> _getPostsList() async {
  try {
    QuerySnapshot _querySnapshot = await postsCollection.get();
    List _snapshotList = _querySnapshot.docs;
    List<ListPostModelRes> _posts = [];
    for (int i = 0; i < _snapshotList.length; i++) {
      var item = _snapshotList[i];
      ListPostModelRes postModelRes = ListPostModelRes(
          createdDate: item['createdDate'],
          postId: item['postId'],
          isEvent: item['isEvent'],
          isNotice: item['isNotice'],
          isPost: item['isPost'],
          isHelp: item['isHelp'],
          imageUrl: item['imageUrl'],
          description: item['description'],
          joinedUserIds: item['joinedUserIds'],
          likedUserIds: item['likedUserIds'],
          title: item['title'],
          joinLimit: item['joinLimit'],
          userId: item['userId']);
      _posts.add(postModelRes);
    }
    return _posts;
  } catch (e) {
    logger(e.toString(), hint: 'GET POSTS LIST CATCH ERROR');
    return [];
  }
}

_logout(AppState state, GetLogoutUserAction action) async {
  await appStore.dispatch(GetRemoveLocalTokenAction());
  appStore.dispatch(UpdateInitAction(token: ""));
  // appStore.dispatch(UpdateApiAction(restart: true));
  appStore.dispatch(UpdateNavigationAction(restart: true));
  if (action.routeTo != null)
    appStore.dispatch(NavigateToAction(
        to: action.routeTo,
        pushAndRemoveUntil: state.navigationState.history.first.name));
  return null;
}

Future<bool> _getCreatePostAction(
    AppState state, GetCreatePostAction action, NextDispatcher next) async {
  try {
    showLoading();
    String _postUid = _generatePostUuid();
    String? downUrl;
    if (action.imagePath != null) {
      downUrl = await appStore.dispatch(GetImageDownloadLinkAction(
          action.imagePath!,
          postId: _postUid,
          postType: "NOTICE_POST"));
    }
    await postsCollection.doc(_postUid).set({
      "postId": _postUid,
      "title": null,
      "description": action.description,
      "eventLocation": null,
      "imageUrl": downUrl,
      "userId": state.apiState.userMe.userId,
      "isPost": true,
      "isEvent": false,
      "isNotice": false,
      "isHelp": false,
      "likedUserIds": [],
      "joinedUserIds": null,
      "joinLimit": null,
      "createdDate": currentDateAndTime
    });
    await appStore.dispatch(GetUpdateUserAction(postId: _postUid));
    await appStore.dispatch(GetAllKindPostsAction());
    closeLoading();
    return true;
  } catch (e) {
    closeLoading();
    logger(e.toString(), hint: 'GET CREATE POST CATCH ERROR');
    return false;
  }
}

Future<bool> _getCreateNoticeAction(
    AppState state, GetCreateNoticeAction action, NextDispatcher next) async {
  try {
    showLoading();
    String _postUid = _generatePostUuid(type: 'NOTICE_POST');
    String? downUrl;
    if (action.imagePath != null) {
      downUrl = await appStore.dispatch(GetImageDownloadLinkAction(
          action.imagePath!,
          postId: _postUid,
          postType: "NOTICE_POST"));
    }
    await postsCollection.doc(_postUid).set({
      "postId": _postUid,
      "eventLocation": null,
      "title": action.title,
      "description": action.description,
      "imageUrl": downUrl,
      "userId": state.apiState.userMe.userId,
      "isPost": false,
      "isEvent": false,
      "isNotice": true,
      "isHelp": false,
      "likedUserIds": null,
      "joinedUserIds": null,
      "joinLimit": null,
      "createdDate": currentDateAndTime
    });
    await appStore.dispatch(GetUpdateUserAction(postId: _postUid));
    await appStore.dispatch(GetAllKindPostsAction());
    closeLoading();
    return true;
  } catch (e) {
    closeLoading();
    logger(e.toString(), hint: 'GET Notice POST CATCH ERROR');
    return false;
  }
}

Future<bool> _getCreateEventAction(
    AppState state, GetCreateEventAction action, NextDispatcher next) async {
  try {
    showLoading();
    String _postUid = _generatePostUuid(type: 'EVENT_POST');
    String? downUrl;
    if (action.imagePath != null) {
      downUrl = await appStore.dispatch(GetImageDownloadLinkAction(
          action.imagePath!,
          postId: _postUid,
          postType: "EVENT_POST"));
    }
    await postsCollection.doc(_postUid).set({
      "postId": _postUid,
      "title": action.title,
      "description": action.description,
      "eventLocation": action.eventLocation,
      "imageUrl": downUrl,
      "userId": state.apiState.userMe.userId,
      "isPost": false,
      "isEvent": true,
      "isNotice": false,
      "isHelp": false,
      "likedUserIds": null,
      "joinedUserIds": [],
      "joinLimit": action.joinLimit ?? 0,
      "createdDate": currentDateAndTime
    });
    await appStore.dispatch(GetUpdateUserAction(postId: _postUid));
    await appStore.dispatch(GetAllKindPostsAction());
    closeLoading();
    return true;
  } catch (e) {
    closeLoading();
    logger(e.toString(), hint: 'GET Event POST CATCH ERROR');
    return false;
  }
}

Future<bool> _getCreateHelpAction(
    AppState state, GetCreateHelpAction action, NextDispatcher next) async {
  try {
    showLoading();
    String _postUid = _generatePostUuid(type: 'HELP_POST');
    String? _downUrl;
    if (action.imagePath != null) {
      _downUrl = await appStore.dispatch(GetImageDownloadLinkAction(
          action.imagePath!,
          postId: _postUid,
          postType: 'HELP_POST'));
    }
    await postsCollection.doc(_postUid).set({
      "postId": _postUid,
      "title": action.title,
      "description": action.description,
      "eventLocation": null,
      "imageUrl": _downUrl,
      "userId": state.apiState.userMe.userId,
      "isPost": false,
      "isEvent": false,
      "isNotice": false,
      "isHelp": true,
      "likedUserIds": null,
      "joinedUserIds": null,
      "joinLimit": null,
      "createdDate": currentDateAndTime
    });
    await appStore.dispatch(GetUpdateUserAction(postId: _postUid));
    await appStore.dispatch(GetAllKindPostsAction());
    closeLoading();
    return true;
  } catch (e) {
    closeLoading();
    logger(e.toString(), hint: 'GET Help POST CATCH ERROR');
    return false;
  }
}

Future<bool> _getCreateUserAction(
    AppState state, GetCreateUserAction action, NextDispatcher next) async {
  try {
    bool userExists = false;
    String _userUid = _generateUserUuid();
    for (int i = 0; i < state.apiState.users.length; i++) {
      UserModelRes user = state.apiState.users[i];
      if (user.phoneNumber == action.phoneNumber) {
        userExists = true;
      }
    }
    if (!userExists) {
      showLoading();
      await usersCollection.doc(_userUid).set({
        "userId": _userUid,
        "name": action.name,
        "phoneNumber": action.phoneNumber,
        "password": action.password,
        "uniName": action.uniName,
        "postIds": [],
        "createdDate": currentDateAndTime,
        "isAdmin": false,
      });
      closeLoading();
    } else {
      showError('User exists with the given phone number');
    }
    return true;
  } catch (e) {
    closeLoading();
    logger(e.toString(), hint: 'GET Create USER CATCH ERROR');
    return false;
  }
}

Future<List<UserModelRes>> _getAllUsersAction(
    AppState state, GetAllUsersAction action, NextDispatcher next) async {
  List<UserModelRes> usersList = await _getUsersList();
  next(UpdateApiStateAction(users: usersList));
  return usersList;
}

Future<List<UserModelRes>> _getUsersList() async {
  try {
    QuerySnapshot _querySnapshot = await usersCollection.get();
    List _snapshotList = _querySnapshot.docs;
    List<UserModelRes> _users = [];
    for (int i = 0; i < _snapshotList.length; i++) {
      var item = _snapshotList[i];
      UserModelRes userModelRes = UserModelRes(
        createdDate: item['createdDate'],
        userId: item['userId'],
        phoneNumber: item['phoneNumber'],
        name: item['name'],
        password: item['password'],
        uniName: item['uniName'],
        postIds: item['postIds'],
      );
      _users.add(userModelRes);
    }
    return _users;
  } catch (e) {
    logger(e.toString(), hint: 'GET USERS LIST CATCH ERROR');
    return [];
  }
}

Future<void> _getUserIdExistAction(
    AppState state, GetUserIdExistAction action, NextDispatcher next) async {
  try {
    final postsFetched = await appStore.dispatch(GetAllKindPostsAction());
    if (postsFetched) {
      for (int i = 0; i < state.apiState.users.length; i++) {
        UserModelRes _userInst = state.apiState.users[i];
        if (_userInst.userId == action.userId) {
          next(UpdateApiStateAction(userMe: _userInst));
          next(UpdateInitStateAction(userId: _userInst.userId));
        }
      }
      appStore.dispatch(
          NavigateToAction(to: AppRoutes.homePageRoute, replace: true));
    }
  } catch (e) {
    logger(e.toString(), hint: 'GET USER ID CATCH ERROR');
  }
}

Future<bool> _getLoginAction(
    AppState state, GetLoginAction action, NextDispatcher next) async {
  try {
    bool _matched = false;
    showLoading();
    List<UserModelRes> users = await appStore.dispatch(GetAllUsersAction());
    if (users.isNotEmpty) {
      for (int i = 0; i < users.length; i++) {
        UserModelRes? _userInst = users[i];
        bool _matched = _userInst.phoneNumber == action.phoneNumber &&
            _userInst.password == action.password;
        if (_matched) {
          next(UpdateApiStateAction(userMe: _userInst));
          next(UpdateInitStateAction(userId: _userInst.userId));
          await appStore.dispatch((SetLocalUserIdAction(_userInst.userId)));
          await appStore.dispatch(GetAllKindPostsAction());
          appStore.dispatch(
              NavigateToAction(to: AppRoutes.homePageRoute, replace: true));
        }
      }
    }
    closeLoading();
    return _matched;
  } catch (e) {
    logger(e.toString(), hint: 'GET LOGIN CATCH ERROR');
    return false;
  }
}

Future<PostModelRes?> _getPostByIdAction(
    AppState state, GetPostByIdAction action, NextDispatcher next) async {
  try {
    if (action.showloading) showLoading();
    final _postDetail = await postsCollection.doc(action.postId).get();
    PostModelRes _postModelRes = PostModelRes(
        createdDate: _postDetail['createdDate'],
        postId: _postDetail['postId'],
        isNotice: _postDetail['isNotice'],
        isPost: _postDetail['isPost'],
        userId: _postDetail['userId'],
        isEvent: _postDetail['isEvent'],
        isHelp: _postDetail['isHelp'],
        likedUserIds: _postDetail['likedUserIds'],
        joinedUserIds: _postDetail['joinedUserIds'],
        description: _postDetail['description'],
        title: _postDetail['title'],
        joinLimit: _postDetail['joinLimit'],
        imageUrl: _postDetail['imageUrl'],
        eventLocation: _postDetail['eventLocation']);
    next(UpdateApiStateAction(postDetail: _postModelRes));
    if (action.goToRoute != null) {
      appStore.dispatch(NavigateToAction(
        to: action.goToRoute,
      ));
    }
    if (action.showloading) closeLoading();
    return _postModelRes;
  } catch (e) {
    if (action.showloading) closeLoading();
    logger(e.toString(), hint: 'GET 1 POST CATCH ERROR');
  }
}

Future<bool> _getUpdatePostAction(
    AppState state, GetUpdatePostAction action, NextDispatcher next) async {
  try {
    if (action.islikeact) {
      PostModelRes _postModelRes = PostModelRes(
        postId: action.postId,
        createdDate: action.listPostModelRes!.createdDate,
        isNotice: action.listPostModelRes!.isNotice,
        isPost: action.listPostModelRes!.isPost,
        userId: action.listPostModelRes!.userId,
        isEvent: action.listPostModelRes!.isEvent,
        isHelp: action.listPostModelRes!.isHelp,
        likedUserIds: action.likedUserIds,
        joinedUserIds: action.listPostModelRes!.joinedUserIds,
        description: action.listPostModelRes!.description,
        title: action.listPostModelRes!.title,
        joinLimit: action.listPostModelRes!.joinLimit,
        imageUrl: action.listPostModelRes!.imageUrl,
      );
      next(UpdateApiStateAction(postDetail: _postModelRes));
    }
    if (action.showloading) {
      showLoading();
    }
    PostModelRes? _postById = await appStore.dispatch(
        GetPostByIdAction(action.postId, showloading: action.showloading));
    String? _downUrl;
    if (action.imagePath != null) {
      final updateRes = await _updateFileFromFirebaseStorage(
          action.postId, File(action.imagePath!));
      _downUrl = await updateRes.ref.getDownloadURL();
    }
    if (_postById != null) {
      PostModelRes _postModelRes = PostModelRes(
        createdDate: action.createdDate ?? _postById.createdDate,
        postId: action.postId,
        isNotice: action.isNotice ?? _postById.isNotice,
        isPost: action.isPost ?? _postById.isPost,
        userId: action.userId ?? _postById.userId,
        isEvent: action.isEvent ?? _postById.isEvent,
        isHelp: action.isHelp ?? _postById.isHelp,
        likedUserIds: action.likedUserIds ?? _postById.likedUserIds,
        joinedUserIds: action.joinedUserIds ?? _postById.joinedUserIds,
        description: action.description ?? _postById.description,
        title: action.title ?? _postById.title,
        joinLimit: action.joinLimit ?? _postById.joinLimit,
        imageUrl: _downUrl ?? _postById.imageUrl,
      );
      await postsCollection.doc(action.postId).update({
        "createdDate": _postModelRes.createdDate,
        "postId": _postModelRes.postId,
        "isNotice": _postModelRes.isNotice,
        "isPost": _postModelRes.isPost,
        "userId": _postModelRes.userId,
        "isEvent": _postModelRes.isEvent,
        "isHelp": _postModelRes.isHelp,
        "likedUserIds": _postModelRes.likedUserIds,
        "joinedUserIds": _postModelRes.joinedUserIds,
        "description": _postModelRes.description,
        "title": _postModelRes.title,
        "joinLimit": _postModelRes.joinLimit,
        "imageUrl": _postModelRes.imageUrl,
      });
      next(UpdateApiStateAction(postDetail: _postModelRes));
      await appStore
          .dispatch(GetAllKindPostsAction(showLoading: action.showloading));
      if (action.showloading) {
        closeLoading();
      }
    }
  } catch (e) {
    if (action.showloading) {
      closeLoading();
    }
    logger(e.toString(), hint: 'GET UPDATE POST CATCH ERROR');
  }
  return true;
}

Future<bool> _getUpdateUserAction(
    AppState state, GetUpdateUserAction action, NextDispatcher next) async {
  try {
    //Saving old user info
    UserModelRes _oldUserData = UserModelRes(
      name: state.apiState.userMe.name,
      userId: state.apiState.userMe.userId,
      createdDate: state.apiState.userMe.createdDate,
      password: state.apiState.userMe.password,
      phoneNumber: state.apiState.userMe.phoneNumber,
      uniName: state.apiState.userMe.uniName,
      postIds: state.apiState.userMe.postIds,
    );
    showLoading();
    //Updating the user
    await usersCollection.doc(state.apiState.userMe.userId).update({
      "name": state.apiState.userMe.name,
      "userId": state.apiState.userMe.userId,
      "createdDate": state.apiState.userMe.createdDate,
      "password": state.apiState.userMe.password,
      "phoneNumber": state.apiState.userMe.phoneNumber,
      "uniName": state.apiState.userMe.uniName,
      "postIds": [...?state.apiState.userMe.postIds, action.postId],
    });
    UserModelRes? _updatedUser = await appStore
        .dispatch(GetUserByIdAction(state.apiState.userMe.userId));
    if (_updatedUser != null) {
      //If update successful, update the state
      next(UpdateApiStateAction(userMe: _updatedUser));
    } else {
      //If not success then revert user info back
      await usersCollection.doc(state.apiState.userMe.userId).update({
        "name": _oldUserData.name,
        "userId": _oldUserData.userId,
        "createdDate": _oldUserData.createdDate,
        "password": _oldUserData.password,
        "phoneNumber": _oldUserData.phoneNumber,
        "uniName": _oldUserData.uniName,
        "postIds": _oldUserData.postIds,
      });
    }
    await appStore.dispatch(GetAllKindPostsAction());
    closeLoading();
    return true;
  } catch (e) {
    closeLoading();
    logger(e.toString(), hint: 'GET UPDATE POST CATCH ERROR');
    return false;
  }
}

Future<void> _getDeletePostAction(
    AppState state, GetDeletePostAction action, NextDispatcher next) async {
  try {
    showLoading();
    await _deleteFileFromFirebaseStorage(action.postId);
    await postsCollection.doc(action.postId).delete();
    await appStore.dispatch(GetAllKindPostsAction());
    closeLoading();
  } catch (e) {
    closeLoading();
    logger(e.toString(), hint: 'GET DELETE POST CATCH ERROR');
  }
}

Future<void> _deleteFileFromFirebaseStorage(String postId) async {
  try {
    final _instance = await FirebaseStorage.instance
        .ref("/${Constants.firebaseStorageImagesFolderName}/")
        .listAll();
    for (int i = 0; i < _instance.items.length; i++) {
      if (_instance.items[i].name.toString() == postId.toString()) {
        await _instance.items[i].delete();
      }
    }
  } catch (e) {
    logger(e.toString(), hint: 'GET POST IMAGE DELETE CATCH ERROR');
  }
}

Future<TaskSnapshot> _updateFileFromFirebaseStorage(
    String postId, File newFile) async {
  TaskSnapshot _updateRes = await FirebaseStorage.instance
      .ref("/${Constants.firebaseStorageImagesFolderName}/$postId")
      .putFile(newFile);

  return _updateRes;
}

Future<String?> _getImageDownloadLinkAction(AppState state,
    GetImageDownloadLinkAction action, NextDispatcher next) async {
  try {
    showLoading();
    File _file = File(action.imagePath);

    TaskSnapshot taskSnapshot = await FirebaseStorage.instance
        .ref("/${Constants.firebaseStorageImagesFolderName}/${action.postId}")
        .putFile(_file);
    String downUrl = await taskSnapshot.ref.getDownloadURL();
    closeLoading();
    return downUrl;
  } catch (e) {
    closeLoading();
    logger(e.toString(), hint: 'GET IMAGE DOWNLOAD LINK POST CATCH ERROR');
  }
}

Future<List<UnivModelRes>?> _getSearchUniversityAction(AppState state,
    GetSearchUniversityAction action, NextDispatcher next) async {
  try {
    showLoading();
    List<UnivModelRes> _univs = [];
    final res =
        await _getClient().get(ApiQueries.querySearchUniv, queryParameters: {
      "name": action.name != null ? action.name!.toLowerCase() : "",
      "country": "Korea, Republic of"
    });
    if (res.statusCode == 200) {
      if (res.data.isNotEmpty) {
        for (int i = 0; i < res.data.length; i++) {
          _univs.add(UnivModelRes(
            name: res.data[i]['name'],
            alpha_two_code: res.data[i]['alpha_two_code'],
            country: res.data[i]['country'],
            domains: res.data[i]['domains'],
            web_pages: res.data[i]['web_pages'],
          ));
        }
        next(UpdateApiStateAction(univs: _univs));
        closeLoading();
        return _univs;
      }
      closeLoading();
    }
  } on DioError catch (e) {
    closeLoading();
    if (e.response != null) {
      showError(e.response!.data.toString());
    } else {
      showError(e.error.toString());
    }
  }
}

Future<UserModelRes?> _getUserByIdAction(
    AppState state, GetUserByIdAction action, NextDispatcher next) async {
  try {
    showLoading();
    // user detail json
    final _userDetail = await usersCollection.doc(action.userId).get();
    UserModelRes _userModel = UserModelRes(
      name: _userDetail['name'],
      userId: _userDetail['userId'],
      createdDate: _userDetail['createdDate'],
      password: _userDetail['password'],
      phoneNumber: _userDetail['phoneNumber'],
      uniName: _userDetail['uniName'],
      postIds: _userDetail['postIds'],
    );
    next(UpdateApiStateAction(postDetailUser: _userModel));
    closeLoading();
    return _userModel;
  } catch (e) {
    closeLoading();
    logger(e.toString(), hint: 'Get User By Id CATCH ERROR');
  }
}

// Future<bool> _getCreatePostAction(
//     AppState state, GetCreatePostAction action, NextDispatcher next) async {
//   try {
//     showLoading();
//     await firebaseKit.postsCollection.doc(_generatePostUuid()).set({
//       "postId": _generatePostUuid(),
//       "title": action.postModelReq.title,
//       "description": action.postModelReq.description,
//       "imageUrl":
//           'https://firebasestorage.googleapis.com/v0/b/alien-mates.appspot.com/o/posts_images%2Ftestid123.jpg?alt=media&token=d8788469-483d-4a35-969e-fafbaa9e9603',
//       "userId": "USERSHOHID",
//       "isPost": true,
//       "isEvent": false,
//       "isNotice": false,
//       "likedUserIds": 0,
//       "joinedUserIds": null,
//       "joinLimit": null,
//       "createdDate": currentDateAndTime
//     });
//     await appStore.dispatch(GetAllKindPostsAction());
//     closeLoading();
//     return true;
//   } catch (e) {
//     closeLoading();
//     logger(e.toString(), hint: 'GET CREATE POST CATCH ERROR');
//     return false;
//   }
// }

String _generatePostUuid({String? type}) {
  final uid = uuid.v1();
  String postIdFormat = "${type ?? "POST_POST"}_${currentDate}_$uid";
  return postIdFormat;
}

String _generateUserUuid() {
  final uid = uuid.v1();
  String userIdFormat = "USER_${currentDate}_$uid";
  return userIdFormat;
}

showLoading() {
  showLoadingDialog(Global.navState!.context);
}

closeLoading() {
  appStore.dispatch(DismissPopupAction(all: true));
}

showError(String? error, {VoidCallback? onTap}) {
  showAlertDialog(
    Global.navKey.currentState!.context,
    text: '${error.toString()}',
    horizontalPadding: 20,
    buttonText: 'Ok',
    onPress: onTap ??
        () {
          appStore.dispatch(DismissPopupAction(all: true));
        },
  );
}

Future<String?> _getSelectImageAction(
    AppState state, GetSelectImageAction action, NextDispatcher next) async {
  try {
    final ImagePicker _picker = ImagePicker();
    XFile? xImage;
    xImage = await _picker.pickImage(
        source: action.withCamera ? ImageSource.camera : ImageSource.gallery);

    if (xImage != null) {
      return xImage.path;
    }
  } catch (e) {
    logger(e.toString(), hint: 'GET SELECT IMAGE CATCH ERROR');
  }
}

Dio _getClient(
    {String? token,
    String? contentType,
    Map<String, dynamic>? queryParameters,
    String? additionalUrl,
    String? tokenAuth}) {
  return ApiClient(
          additionalUrl: additionalUrl,
          token: token != null ? "${tokenAuth ?? "Bearer"} $token" : null,
          queryParameters: queryParameters,
          contentType: contentType)
      .init();
}
