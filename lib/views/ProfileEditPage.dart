import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kvis_sf/models/Authentication.dart';
import 'package:kvis_sf/models/InAppLogging.dart';
import 'package:kvis_sf/views/widgets/TriggerableWidgets.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final GlobalKey<FormBuilderState> _profileEditForm =
      GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              FormBuilder(
                key: _profileEditForm,
                autovalidate: true,
                initialValue: {
                  ...data,
                  'age': (data['age'] ?? 16).round().toString(),
                },
                child: Column(
                  children: <Widget>[
                    FormBuilderTextField(
                      attribute: 'name',
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Name',
                      ),
                      validators: [
                        FormBuilderValidators.required(
                            errorText: 'Name cannot be empty.'),
                      ],
                    ),
                    FormBuilderDropdown(
                      attribute: 'gender',
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Gender',
                      ),
                      items: ['Male', 'Female', 'Other', 'Prefer not to say']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                    ),
                    FormBuilderTextField(
                      attribute: 'age',
                      valueTransformer: (value) => int.tryParse(value) ?? 16,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Age',
                      ),
                      validators: [
                        FormBuilderValidators.required(
                            errorText: 'Age cannot be empty.'),
                        (val) {
                          try {
                            int parsedVal = int.parse(val);
                            if (parsedVal < 0 || parsedVal > 150) {
                              return 'Age must be in a reasonable range.';
                            }
                            return null;
                          } catch (e) {
                            return 'Age must be an integer value.';
                          }
                        },
                      ],
                    ),
                    FormBuilderTextField(
                      attribute: 'school',
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'School',
                      ),
                    ),
                    FormBuilderTextField(
                      attribute: 'country',
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Country',
                      ),
                      validators: [
                        FormBuilderValidators.required(
                            errorText: 'Country cannot be empty.'),
                      ],
                    ),
                    FormBuilderTextField(
                      attribute: 'information',
                      minLines: 3,
                      maxLines: 10,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Additional Information',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () {
                            if (_profileEditForm.currentState
                                .saveAndValidate()) {
                              authService.updateProfileData(
                                  _profileEditForm.currentState.value);
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: Text('Save'),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                        ),
                        RaisedButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Cancel'),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          color: Theme.of(context).errorColor,
                        ),
                      ],
                    ),
                    Divider(height: 25.0, thickness: 3.0),
                    Text(
                      'The following actions require internet connection.',
                      style: Theme
                          .of(context)
                          .textTheme
                          .body2,
                    ),
                    Container(height: 10.0),
                    ProfilePictureUpload(
                      filePath:
                          'profiles/${data['firebaseUid'].toString()}/profile_picture.jpg',
                    ),
                    RaisedButton(
                      onPressed: () {
                        authService.sendResetPasswordLinkViaEmail();
                        FlashNotification.TopNotification(context,
                            title: Text('Email Sent'),
                            message: Text(
                                'We\'ve sent an email to ${data['email'] ?? '...'}.\nPlease use the link in the email to reset your password.'));
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Change Password'),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      color: Theme.of(context).errorColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePictureUpload extends StatefulWidget {
  final String filePath;

  ProfilePictureUpload({@required this.filePath});

  @override
  _ProfilePictureUploadState createState() => _ProfilePictureUploadState();
}

class _ProfilePictureUploadState extends State<ProfilePictureUpload> {
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () async {
        if (_uploading) {
          return;
        }

        try {
          File imageFile =
              await ImagePicker.pickImage(source: ImageSource.gallery);

          FlashNotification.TopNotification(
            context,
            title: Text('Profile Picture'),
            message: Text('New profile picture is being uploaded.'),
            duration: Duration(seconds: 3),
          );

          setState(() {
            _uploading = true;
          });

          StorageUploadTask uploadTask = FirebaseStorage.instance
              .ref()
              .child(widget.filePath)
              .putFile(imageFile);

          await (await uploadTask.onComplete).ref.getMetadata();

          FlashNotification.TopNotification(context,
              title: Text('Profile Picture'),
              message: Text(
                  'New profile picture has been uploaded.\nYou may need to restart the app for the picture to be displayed.'));

          setState(() {
            _uploading = false;
          });
        } catch (e) {
          setState(() {
            _uploading = false;
          });

          FlashNotification.TopNotification(context,
              title: Text('Profile Picture'),
              message: Text('Failed to upload new profile picture.'));

          loggingService
              .pushLogs({'source': 'uploadProfilePicture', 'error': e});
        }
      },
      child: Text('Upload Profile Picture'),
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 10.0,
      ),
    );
  }
}
