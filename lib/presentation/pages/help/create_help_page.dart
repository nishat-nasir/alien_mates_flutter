import 'dart:io';

import 'package:alien_mates/mgr/navigation/app_routes.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:alien_mates/mgr/redux/action.dart';
import 'package:alien_mates/presentation/template/base/template.dart';
import 'package:ionicons/ionicons.dart';

class CreateHelpPage extends StatefulWidget {
  @override
  State<CreateHelpPage> createState() => _CreateHelpPageState();
}

class _CreateHelpPageState extends State<CreateHelpPage> {
  final GlobalKey<FormState> _formKeyCreateHelpPage =
      GlobalKey<FormState>(debugLabel: '_formKeyCreateHelpPage');

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  File? helpImage;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
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
                SizedText(text: 'Create a Support post', textStyle: latoM20),
            child: Form(
              key: _formKeyCreateHelpPage,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: ThemeColors.borderDark),
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.r))),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SpacedColumn(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedText(
                                text: 'Help details',
                                textStyle: latoR14.copyWith(
                                    color: ThemeColors.fontWhite)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(
                                  thickness: 1.w,
                                  color: ThemeColors.borderDark),
                            ),
                            InputLabel(label: 'Title'),
                            PostCreateInput(
                              controller: titleController,
                              validator: Validator.validateTitle,
                            ),
                            SizedBox(height: 10.h),
                            InputLabel(label: 'Description'),
                            PostCreateInput(
                              hintText: 'Add description about support!',
                              maxlines: 10,
                              validator: Validator.validateDescription,
                              controller: descriptionController,
                              textInputAction: TextInputAction.newline,
                              keyboardType: TextInputType.multiline,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    DefaultBanner(
                      onTap: _onChooseImage,
                      height: 200.h,
                      child: FittedBox(
                          child: helpImage == null
                              ? Column(
                                  children: [
                                    const Icon(
                                      Ionicons.add,
                                      size: 120,
                                      color: ThemeColors.coolgray600,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10.0),
                                      child: SizedText(
                                        text: "Add images or GIF",
                                        textStyle: latoR12.copyWith(
                                            color: ThemeColors.coolgray500),
                                      ),
                                    ),
                                  ],
                                )
                              : Image.file(helpImage!)),
                    ),
                    SizedBox(height: 40.h),
                    ExpandedButton(text: 'Post', onPressed: _onPostEvent),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _onChooseImage() async {
    String? xImagePath = await appStore.dispatch(GetSelectImageAction());
    if (xImagePath != null) {
      setState(() {
        helpImage = File(xImagePath);
      });
    }
  }

  _onPostEvent() async {
    if (_formKeyCreateHelpPage.currentState!.validate()) {
      bool created = await appStore.dispatch(GetCreateHelpAction(
          title: titleController.text,
          description: descriptionController.text,
          imagePath: helpImage?.path));

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
