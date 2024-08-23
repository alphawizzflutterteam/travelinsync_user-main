



import 'package:flutter/material.dart';
import 'package:taxi_schedule_user/generated/assets.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/firebase_msg.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
 void initState() {
    // TODO: implement initState
    super.initState();
    changePage();

  }
  changePage()async{
    await Future.delayed(const Duration(seconds: 1));
    await App.init();
    await FireBaseMessagingService(context).init();
    if(context.mounted){
      if(App.localStorage.getString("userId")!=null){
        Constants.curUserId = App.localStorage.getString("userId");
        Navigator.popAndPushNamed(context, Constants.dashboardRoute);
      }else{
        Navigator.popAndPushNamed(context, Constants.loginRoute);
      }}
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Common.getWidth(100, context),
      height: Common.getHeight(100, context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: Common.getWidth(100, context),
            height: Common.getHeight(100, context),
            decoration:const BoxDecoration(
              color: MyColorName.mainColor
            ),
            child: Center(
              child: Image.asset(
                Assets.assetsAppIcons,
                height: 200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
