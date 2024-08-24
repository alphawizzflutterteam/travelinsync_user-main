import 'dart:async';
import 'package:taxi_schedule_user/generated/assets.dart';
import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/Demo_Localization.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:taxi_schedule_user/new_utils/entry_field.dart';
import 'package:flutter/rendering.dart';



class LoginScreen extends StatefulWidget {


  const LoginScreen();

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _numberController = TextEditingController();
  TextEditingController emailCon = new TextEditingController();
  TextEditingController passCon = new TextEditingController();
  String isoCode = '';
  bool otpOnOff = false;
  dynamic choose = "pass";
  bool obscure = true;
  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            height: MediaQuery.of(context).size.height,
            color: MyColorName.mainColor,
            child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Spacer(flex: 2),
                Image.asset(
                  Assets.assetsAppIcons,
                  height: 200,
                ),
                /*Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                      getTranslated(context, 'ENTER_YOUR')! +
                          '\n' +
                          "Mobile Number and Password",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headline4!.copyWith(fontSize: 20,color: Colors.white)),
                ),*/
                Spacer(),
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  color: MyColorName.scaffoldColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      // chooseType(),
                      // EntryField(
                      //   controller: emailCon,
                      //   keyboardType: TextInputType.emailAddress,
                      //   label: getTranslated(context,'EMAIL_ADD'),
                      // ),
                      EntryField(
                        maxLength:9,
                        keyboardType: TextInputType.phone,
                        controller: _numberController,
                        label: getTranslated(context, 'ENTER_PHONE'),
                      ),
                      EntryField(
                        //  initialValue: name.toString(),
                        controller: passCon,
                        keyboardType: TextInputType.visiblePassword,
                        label: getTranslated(context, "PASSWORD")!,
                        obscureText: obscure,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure ? Icons.visibility : Icons.visibility_off,
                            color: MyColorName.primaryLite,
                          ),
                          onPressed: () {
                            setState(() {
                              obscure = !obscure;
                            });
                          },
                        ),
                      ),

                      Spacer(flex: 1),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            UI.commonButton(
                              loading: loading,
                              fontSize: 16.0,
                              onPressed: (){
                                if (_numberController.text == "" ||
                                    _numberController.text.length < 9) {
                                  UI.setSnackBar(
                                      "Please Enter Valid Mobile Number",
                                      context);
                                  return;
                                }
                                if (passCon.text == "" ||
                                    passCon.text.length < 5) {
                                  UI.setSnackBar(
                                      getTranslated(context, "ENTER_PASSWORD")!,
                                      context);
                                  return;
                                }
                                setState(() {
                                  loading = true;
                                });
                                loginUser();
                              },
                              title: "Login",
                            ),
                          ],
                        ),
                      ),
                      Spacer(flex: 1),

                    ],
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }

  Widget chooseType() {
    return Row(
      children: [
        Row(
          children: [
            Radio(
                value: "pass",
                groupValue: choose,
                onChanged: (val) {
                  setState(() {
                    choose = val;
                  });
                }),
            Text(getTranslated(context, "EMAIL")!),
          ],
        ),
        Row(
          children: [
            Radio(
                value: "otp",
                groupValue: choose,
                onChanged: (val) {
                  setState(() {
                    choose = val;
                    otpOnOff = true;
                  });
                }),
            Text(getTranslated(context, "MOBILE")!),
          ],
        )
      ],
    );
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool loading = false;

  loginUser() async {
    await App.init();
    isNetwork = await Common.checkInternet();
    if (isNetwork) {
      try {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print('Running on ${androidInfo.model}');
        Map data;
        data = {
          "user_email": _numberController.text.toString(),
          "pass": passCon.text.trim().toString(),
          "fcm_id": "",
          "device_id": androidInfo.id.toString(),
        };
        Map response =
        await apiBase.postAPICall(Uri.parse("${Constants.baseUrl}Authentication/userlogin"), data);
        print(response);
        bool status = true;
        String msg = response['message'];
        setState(() {
          loading = false;
        });
        UI.setSnackBar(msg, context);
        if (response['status']) {
          App.localStorage
              .setString("userId", response['data']['id'].toString());
          Constants.curUserId = response['data']['id'].toString();
          Navigator.popAndPushNamed(context, Constants.dashboardRoute);
          // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> SearchLocationPage()), (route) => false);
        } else {}
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
        setState(() {
          loading = false;
        });
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
      setState(() {
        loading = false;
      });
    }
  }


}
