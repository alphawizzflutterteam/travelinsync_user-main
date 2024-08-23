



import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

import '../new_utils/common_ui.dart';

class DrawerScreen extends StatefulWidget {
  final ValueChanged? onResult;
  const DrawerScreen({super.key,this.onResult});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: Common.getHeight(100, context),
      decoration:const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            //  topRight: Radius.circular(30),
              bottomRight: Radius.circular(60)
          )
      ),
      duration: const Duration(milliseconds: 200),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: MyColorName.mainColor,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Constants.userProfile!=""?UI.commonImage(
                      Constants.userProfile,
                    context,
                    height: 100,
                    width: 100
                  ):Icon(
                    Icons.supervised_user_circle,
                    size: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8,),
                  Text(
                      "${Constants.userName}",
                    style:const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      decoration: TextDecoration.none
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                drawerTile(
                    title: "Home",
                    pos: 0,
                    icon:Icons.home_filled
                ),
                drawerTile(
                    title: "Profile",
                    pos: 1,
                    icon:Icons.person
                ),
                drawerTile(
                    title: "My Rides",
                    pos: 2,
                    icon:Icons.history
                ),
                drawerTile(
                    title: "Manage Address",
                    pos: 3,
                    icon:Icons.location_on_rounded
                ),

                drawerTile(
                    title: "Subscriptions",
                    pos: 4,
                    icon:Icons.subscriptions
                ),
                drawerTile(
                    title: "Privacy Policy",
                    pos: 5,
                    icon:Icons.privacy_tip
                ),
                drawerTile(
                    title: "Terms and Conditions",
                    pos: 6,
                    icon:Icons.admin_panel_settings
                ),
                drawerTile(
                    title: "FAQs",
                    pos: 7,
                    icon:Icons.face
                ),
                drawerTile(
                    title: "Logout",
                    pos: -2,
                    icon:Icons.logout
                ),
              ],
            ),
            const SizedBox(height: 50,),
          ],
        ),
      ),
    );
  }
  int selectedIndex = 0;
  Widget drawerTile({String title = "title", int pos = -1,IconData icon = Icons.home}){
    return  Column(
      children: [
        Material(
          color: Colors.transparent,
          child: ListTile(
            minVerticalPadding: 0,
            dense: true,
            horizontalTitleGap: 5,
            contentPadding: const EdgeInsets.all(0),
            tileColor:const Color(0x7AF8F8FA),
            onTap: (){
              if(pos>=0){
                setState(() {
                  selectedIndex = pos;
                });
                widget.onResult!(selectedIndex);
              }

              if(pos==0){

              }else if(pos==-1){

              }else if(pos==-2){
                logoutDialog(context);
              }else if(pos==6){

              }
            },
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                selectedIndex == pos
                    ? Container(
                  height: 50,
                  width: 5,
                  color: MyColorName.mainColor,
                )
                    : const SizedBox(),
                IconButton(
                  onPressed: null,
                  icon: Icon(
                      icon,
                      color: MyColorName.mainColor,
                      size: 24
                  ),
                ),
              ],
            ),
            title: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500
              ),
            ),
          ),
        ),
        const Divider(
          color: Colors.transparent,
          height: 5,
        ),
      ],
    );
  }
}
logoutDialog(BuildContext context){
  showDialog(context: context, builder: (BuildContext ctx){
    return UI.commonDialog(
        context,
        onYesPressed: ()async{
          Navigator.pop(context);
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          Map data = {
            "user_id":Constants.curUserId,
            "device_id":androidInfo.id.toString(),
          };
          ApiBaseHelper().postAPICall(Uri.parse("${Constants.baseUrl}Authentication/logout_user"), data).then((value){
            App.localStorage.clear();
            Navigator.popAndPushNamed(context, Constants.loginRoute);
            UI.setSnackBar(value['message'], context,color: Colors.green);
          });
        }
    );
  });
}