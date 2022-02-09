import 'dart:io';

import 'package:alien_mates/mgr/navigation/app_routes.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:alien_mates/mgr/redux/action.dart';
import 'package:alien_mates/presentation/template/base/template.dart';
import 'package:ionicons/ionicons.dart';

class FeedbackPage extends StatefulWidget {
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final GlobalKey<FormState> _formKeyFeedbackPage =
      GlobalKey<FormState>(debugLabel: '_formKeyFeedbackPage');

  TextEditingController emailController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController locationController = TextEditingController(text: "");

  File? postImage;

  bool agreementChecked = false;

  @override
  void dispose() {
    emailController.dispose();
    descriptionController.dispose();
    nameController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return DefaultBody(
            withNavigationBar: false,
            withTopBanner: false,
            withActionButton: false,
            titleIcon: _buildTitleIcon(),
            titleText:
                SizedText(text: 'Create an Event post', textStyle: latoM20),
            child: Form(
              key: _formKeyFeedbackPage,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultBanner(
                      bgColor: ThemeColors.black,
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        child: SpacedColumn(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedText(
                                text: 'Feedback',
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
                                  InputLabel(label: 'Description'),
                                  PostCreateInput(
                                    hintText:
                                        'Add description for the feedback ... ',
                                    maxlines: 10,
                                    validator: Validator.validateDescription,
                                    controller: descriptionController,
                                  ),
                                  SizedBox(height: 20.h),
                                ]),
                            SpacedColumn(verticalSpace: 12.h, children: [
                              SpacedColumn(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InputLabel(label: 'Email'),
                                    PostCreateInput(
                                      controller: emailController,
                                      validator: Validator.validateEmail,
                                    ),
                                  ]),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(height: 20.h),
                    ExpandedButton(text: 'Post', onPressed: _onPostEvent),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _onPostEvent() async {
    if (_formKeyFeedbackPage.currentState!.validate()) {
      bool created = await appStore.dispatch(GetFeedbackPostAction(
          feedback: descriptionController.text, email: emailController.text));

      if (!created) {
        showAlertDialog(context,
            text:
                'There was a problem while uploading to server! Please, try again!');
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
