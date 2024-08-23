import 'dart:async';
import 'dart:convert';


import 'package:taxi_schedule_user/new_screen/privacy_policy.dart';
import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/Demo_Localization.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:taxi_schedule_user/new_utils/ui.dart';



class FaqPage extends StatefulWidget {
  const FaqPage();
  @override
  _FaqPageState createState() => _FaqPageState();


}

class _FaqPageState extends State<FaqPage> {
  bool loading = true;
  @override
  void initState() {
    super.initState();
    getRules();
  }
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  List<PrivacyModel> ruleList = [];
  getRules() async {
    await App.init();
    isNetwork = await Common.checkInternet();
    if (isNetwork) {
      try {
        Map data = {
          "user_id": Constants.curUserId,
        };
        var res = await http.get(Uri.parse(Constants.baseUrl + "Authentication/get_faqs"));
        Map response = jsonDecode(res.body);
        print(response);
        print(response);
        setState(() {
          loading = false;
        });
        if (response['status']) {
          for(var v in response['data']){
            setState(() {
              ruleList.add(new PrivacyModel(v['id'], v['title']??"Privacy Policy", v['description']));
            });
          }
        } else {}
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColorName.mainColor,
        title: Text(
          getTranslated(context, 'FAQS')!,

        ),
      ),
      //drawer: AppDrawer(false),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ruleList.length,
                  itemBuilder: (context, index) => Container(
                    decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10), ),
                    margin: EdgeInsets.all(10),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      title: Text(
                        Common.getString1(ruleList[index].title),
                        style: theme.textTheme.titleMedium,
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            Common.getString1(ruleList[index].description),
                          ),
                        )
                      ],
                      expandedAlignment: Alignment.centerLeft,
                      trailing: Icon(
                        Icons.keyboard_arrow_down,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (loading) CircularProgressIndicator(),
        ],
      ),
    );
  }
}
