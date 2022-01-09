import 'dart:io';
import 'package:alien_mates/mgr/redux/states/api_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:alien_mates/mgr/redux/action.dart';
import 'package:alien_mates/presentation/template/base/template.dart';
import 'package:ionicons/ionicons.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKeyEditProfilePage =
      GlobalKey<FormState>(debugLabel: '_formKeyEditProfilePage');

  TextEditingController descriptionController = TextEditingController();

  File? noticeImage;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          descriptionController = TextEditingController(
              text: state.apiState.postDetail.description);
          return DefaultBody(
            withNavigationBar: false,
            withTopBanner: false,
            withActionButton: false,
            titleIcon: _buildTitleIcon(),
            titleText: SizedText(text: 'Edit Profile', textStyle: latoM20),
            bottomPadding: 15.h,
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 140.h,
              child: Form(
                key: _formKeyEditProfilePage,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (descriptionController.text.isNotEmpty)
                      DefaultBanner(
                        bgColor: ThemeColors.black,
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          child: SpacedColumn(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedText(
                                  text: 'User',
                                  textStyle: latoR14.copyWith(
                                      color: ThemeColors.fontWhite)),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 6.h),
                                child: Divider(
                                    thickness: 1.w,
                                    color: ThemeColors.borderDark),
                              ),
                              SpacedColumn(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (state.apiState.postDetail.description !=
                                        null)
                                      InputLabel(label: 'User Name'),
                                    if (state.apiState.postDetail.description !=
                                        null)
                                      PostCreateInput(
                                        maxlines: 1,
                                        validator: Validator.validateText,
                                        controller: descriptionController,
                                      ),
                                    SizedBox(
                                      height: 25.h,
                                    ),
                                    if (state.apiState.postDetail.description !=
                                        null)
                                      InputLabel(label: 'Kakao Id'),
                                    if (state.apiState.postDetail.description !=
                                        null)
                                      PostCreateInput(
                                        maxlines: 1,
                                        validator: Validator.validateText,
                                        controller: descriptionController,
                                      ),
                                  ]),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      DefaultBanner(
                        bgColor: ThemeColors.black,
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          child: SpacedColumn(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedText(
                                  text: 'Password',
                                  textStyle: latoR14.copyWith(
                                      color: ThemeColors.fontWhite)),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 6.h),
                                child: Divider(
                                    thickness: 1.w,
                                    color: ThemeColors.borderDark),
                              ),
                              SpacedColumn(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (state.apiState.postDetail.description !=
                                        null)
                                      InputLabel(label: 'Current Password'),
                                    if (state.apiState.postDetail.description !=
                                        null)
                                      PostCreateInput(
                                        maxlines: 1,
                                        validator: Validator.validateText,
                                        controller: descriptionController,
                                      ),
                                    SizedBox(
                                      height: 25.h,
                                    ),
                                    if (state.apiState.postDetail.description !=
                                        null)
                                      InputLabel(label: 'New Password'),
                                    if (state.apiState.postDetail.description !=
                                        null)
                                      PostCreateInput(
                                        maxlines: 1,
                                        validator: Validator.validateText,
                                        controller: descriptionController,
                                      ),
                                    SizedBox(
                                      height: 25.h,
                                    ),
                                    if (state.apiState.postDetail.description !=
                                        null)
                                      InputLabel(label: 'Confirm Password'),
                                    if (state.apiState.postDetail.description !=
                                        null)
                                      PostCreateInput(
                                        maxlines: 1,
                                        validator: Validator.validateText,
                                        controller: descriptionController,
                                      ),
                                  ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            footer: ExpandedButton(
              text: 'Save',
              onPressed: () {
                _onUpdateEvent(state.apiState.postDetail.postId);
              },
            ),
          );
        });
  }

  Widget _getImageOrNotWidget(ApiState state) {
    if (noticeImage != null) {
      return Image.file(noticeImage!, fit: BoxFit.fitHeight);
    }
    if (state.postDetail.imageUrl != null) {
      return CachedNetworkImage(
          imageUrl: state.postDetail.imageUrl!, fit: BoxFit.fitHeight);
    }
    return const Icon(Ionicons.add, color: ThemeColors.borderDark);
  }

  _onChooseImage() async {
    String? xImagePath = await appStore.dispatch(GetSelectImageAction());
    if (xImagePath != null) {
      setState(() {
        noticeImage = File(xImagePath);
      });
    }
  }

  _onUpdateEvent(String postId) async {
    if (_formKeyEditProfilePage.currentState!.validate()) {
      bool created = await appStore.dispatch(GetUpdatePostAction(
          description: descriptionController.text,
          imagePath: noticeImage?.path,
          postId: postId));

      if (!created) {
        showAlertDialog(context,
            text:
                'There was a problem while updating to server! Please, try again!');
      } else {
        appStore.dispatch(NavigateToAction(to: 'up'));
      }
    }
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
