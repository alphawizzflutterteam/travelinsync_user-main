import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/Demo_Localization.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

import 'package:flutter/material.dart';

import 'package:taxi_schedule_user/new_utils/entry_field.dart';

import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage();
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController mobileCon = new TextEditingController();
  TextEditingController genderCon = new TextEditingController();
  TextEditingController emailCon = new TextEditingController();
  TextEditingController nameCon = new TextEditingController();
  TextEditingController dobCon = new TextEditingController();
  TextEditingController passCon = new TextEditingController();
  List<String> gender = ["Male", "Female", "Other"];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mobileCon.text = Constants.userModel!.mobile ?? '';
    emailCon.text = Constants.userModel!.email ?? '';
    nameCon.text = Constants.userModel!.username ?? '';
    //dobCon.text = Constants.userModel!.do??'';
    passCon.text = Constants.userModel!.password ?? '';
    genderCon.text = Constants.userModel!.gender ?? '';
  }

  DateTime startDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: startDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2023));
    if (picked != null) {
      setState(() {
        startDate = picked;
        dobCon.text = DateFormat("yyyy-MM-dd").format(startDate);
      });
    }
  }

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  PersistentBottomSheetController? persistentBottomSheetController1;
  showBottom1() async {
    persistentBottomSheetController1 =
        await scaffoldKey.currentState!.showBottomSheet((context) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.white),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Text(
              getTranslated(context, "SELECT_GENDER")!,
              style: TextStyle(
                fontSize: 12.0,
                color: MyColorName.colorTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20),
            Container(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: gender.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        persistentBottomSheetController1!.setState!(() {
                          genderCon.text = gender[index];
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        color: genderCon.text == gender[index]
                            ? MyColorName.primaryLite.withOpacity(0.2)
                            : Colors.white,
                        padding: EdgeInsets.all(10),
                        child: Text(
                          gender[index].toString(),
                          style: TextStyle(
                            fontSize: 10.0,
                            color: MyColorName.colorTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            SizedBox(height: 40),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height + 210,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppBar(),
                      SizedBox(
                        height: 12,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          getTranslated(context, 'MY_PROFILE')!,
                          style: theme.textTheme.headline4,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Text(
                          getTranslated(context, 'YOUR_ACCOUNT_DETAILS')!,
                          style: theme.textTheme.bodyText2!
                              .copyWith(color: theme.hintColor, fontSize: 12),
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Expanded(
                        child: Container(
                          height: 500,
                          color: theme.backgroundColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Spacer(),
                              EntryField(
                                label: getTranslated(context, 'ENTER_PHONE'),
                                // initialValue: mobile.toString(),
                                controller: mobileCon,
                                readOnly: true,
                                maxLength: 10,
                                keyboardType: TextInputType.phone,
                              ),
                              EntryField(
                                //  initialValue: name.toString(),
                                controller: nameCon,
                                keyboardType: TextInputType.name,
                                label: getTranslated(context, 'FULL_NAME'),
                              ),
                              EntryField(
                                //initialValue: email.toString(),
                                controller: emailCon,
                                label: getTranslated(context, 'EMAIL_ADD'),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              gender.length > 0
                                  ? EntryField(
                                      maxLength: 10,
                                      readOnly: true,
                                      controller: genderCon,
                                      onTap: () {
                                        showBottom1();
                                      },
                                      label: getTranslated(context, "GENDER")!,
                                    )
                                  : SizedBox(),
                              /* EntryField(
                                label: getTranslated(context, "DOB")!,
                                controller: dobCon,
                                readOnly: true,
                                onTap: () {
                                  selectDate(context);
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),*/
                              /*  EntryField(
                                  //  initialValue: name.toString(),
                                  controller: passCon,
                                  keyboardType: TextInputType.visiblePassword,
                                  label: "Password",
                                  obscureText: true,
                                ),*/
                              Spacer(flex: 3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  PositionedDirectional(
                    top: 200,
                    start: 24,
                    child: InkWell(
                      onTap: () {
                        requestPermission(context);
                      },
                      child: Row(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                color: theme.hintColor,
                                borderRadius: BorderRadius.circular(10)),
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _image == null
                                  ? Constants.userProfile != ""
                                      ? UI.commonImage(
                                          Constants.userProfile,
                                          context,
                                          height: 100,
                                          width: 100,
                                          boxFit: BoxFit.fill,
                                        )
                                      : Icon(
                                          Icons.supervised_user_circle,
                                          size: 100,
                                          color: Colors.white,
                                        )
                                  : Image.file(
                                      _image!,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.edit,
                            color: MyColorName.secondColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            start: 0,
            end: 0,
            child: UI.commonButton(
              loading: loading,
              title: getTranslated(context, 'UPDATE') ?? '',
              onPressed: () {
                /*if (mobileCon.text == "" || mobileCon.text.length != 10) {
                  UI.setSnackBar(
                      "Please Enter Valid Mobile Number", context);
                  return;
                }*/
                if (nameCon.text == "") {
                  UI.setSnackBar("Please Enter Full Name", context);
                  return;
                }
                if (genderCon.text == "") {
                  UI.setSnackBar("Please Enter Gender", context);
                  return;
                }
                /* if (validateField(
                              dobCon.text, "Please Enter Date Of Birth") !=
                          null) {
                        UI.setSnackBar("Please Enter Date Of Birth", context);
                        return;
                      }*/
                /* if (passCon.text == "" || passCon.text.length < 8) {
                  UI.setSnackBar(
                      getTranslated(context, "ENTER_PASSWORD")!, context);
                  return;
                }*/
                /*if (_image == null) {
                          UI.setSnackBar("Please Upload Photo", context);
                          return;
                        }*/
                setState(() {
                  loading = true;
                });
                submitSubscription();
              },
            ),
          ),
        ],
      ),
    );
  }

  void requestPermission(BuildContext context) async {
    if (await Permission.camera.isPermanentlyDenied ||
        await Permission.storage.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.storage,
      ].request();
// You can request multiple permissions at once.

      if (statuses[Permission.camera] == PermissionStatus.granted &&
          statuses[Permission.storage] == PermissionStatus.granted) {
        getImage(ImgSource.Both, context);
      } else {
        if (await Permission.camera.isDenied ||
            await Permission.storage.isDenied) {
          // The user opted to never again see the permission request dialog for this
          // app. The only way to change the permission's status now is to let the
          // user manually enable it in the system settings.
          openAppSettings();
        } else {
          UI.setSnackBar("Oops you just denied the permission", context);
        }
      }
    }
  }

  File? _image;
  Future getImage(ImgSource source, BuildContext context) async {
    var image = await ImagePickerGC.pickImage(
      context: context,
      source: source,
      maxHeight: 480,
      maxWidth: 480,
      imageQuality: 60,
      cameraIcon: Icon(
        Icons.add,
        color: Colors.red,
      ), //cameraIcon and galleryIcon can change. If no icon provided default icon will be present
    );
    setState(() {
      _image = File(image.path);
      getCropImage(context);
    });
  }

  void getCropImage(BuildContext context) async {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        compressQuality: 40,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.lightBlueAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    setState(() {
      _image = croppedFile;
    });
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool loading = false;
  Future<void> submitSubscription() async {
    await App.init();

    ///MultiPart request
    isNetwork = await Common.checkInternet();
    if (isNetwork) {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse("${Constants.baseUrl}Authentication/update_userprofile"),
        );
        Map<String, String> headers = {
          "token": App.localStorage.getString("token").toString(),
          "Content-type": "multipart/form-data"
        };
        if (_image != null) {
          request.files.add(
            http.MultipartFile(
              'user_image',
              _image!.readAsBytes().asStream(),
              _image!.lengthSync(),
              filename: path.basename(_image!.path),
              contentType: MediaType('image', 'jpeg,png'),
            ),
          );
          print("ok");
        }
        request.headers.addAll(headers);
        request.fields.addAll({
          "gender": genderCon.text,
          "dob": dobCon.text,
          // "password": passCon.text,
          "user_id": Constants.curUserId.toString(),
          "user_fullname": nameCon.text,
          "user_phone": mobileCon.text,
          "user_email": emailCon.text.trim().toString(),
        });
        print("request: " + request.toString());
        var res = await request.send();
        print("This is response:" + res.toString());
        setState(() {
          loading = false;
        });
        print(res.statusCode);
        if (res.statusCode == 200) {
          final respStr = await res.stream.bytesToString();
          print(respStr.toString());
          Map data = jsonDecode(respStr.toString());
          if (data['status']) {
            Navigator.pop(
              context,
              true,
            );
            //  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> SearchLocationPage()), (route) => false);
            UI.setSnackBar(data['message'].toString(), context);
          } else {
            UI.setSnackBar(data['message'].toString(), context);
          }
        }
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
        setState(() {
          loading = true;
        });
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
      setState(() {
        loading = true;
      });
    }
  }
}
