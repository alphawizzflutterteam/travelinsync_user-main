import 'dart:async';
import 'dart:convert';


import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/Demo_Localization.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';

import 'package:flutter/material.dart';



import 'package:http/http.dart' as http;
import 'package:taxi_schedule_user/new_utils/ui.dart';

class NotificationModel {
  String? title;
  String? message;
  String? bookingId;
  String? added_notify_date;
  NotificationModel({this.title, this.message, this.bookingId});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    message = json['message'];
    bookingId = json['booking_id'];
    added_notify_date = json['added_notify_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['message'] = this.message;
    data['booking_id'] = this.bookingId;
    return data;
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen();
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    getNotification();
  }

  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool loading = true;
  List<NotificationModel> notificationList = [];
  getNotification() async {
    await App.init();
    isNetwork = await Common.checkInternet();
    if (isNetwork) {
      try {
        Map data;
        setState(() {
          loading = true;
        });
        data = {
          "user_id": Constants.curUserId,
        };
        print(data);
        var res = await http
            .post(Uri.parse("${Constants.baseUrl}payment/noti_user_list"), body: data);
        print(res.body);
        Map response = jsonDecode(res.body);
        print(response);
        print(response);
        bool status = true;
        String msg = response['message'];
        UI.setSnackBar(msg, context);
        setState(() {
          loading = false;
          notificationList.clear();
        });
        if (response['status']) {
          for (var v in response['data']) {
            setState(() {
              notificationList.add(new NotificationModel.fromJson(v));
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

  getTime(date) {
    String temp = "";
    if (date != "" && date != null) {
      int time =
          DateTime.now().difference(DateTime.parse(date.toString())).inHours;
      if (time > 0) {
        return time.toString() + " ${getTranslated(context, "HOURS")}";
      } else {
        time = DateTime.now()
            .difference(DateTime.parse(date.toString()))
            .inMinutes;
        return time.toString() + " ${getTranslated(context, "MINUTES_AGO")!}";
      }
    }
    return temp;
  }

  bool saveStatus = false;
  getDelete() async {
    try {
      setState(() {
        saveStatus = true;
      });
      Map params = {
        "user_id": Constants.curUserId.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse( "${Constants.baseUrl}Authentication/clearNotification"), params);
      setState(() {
        saveStatus = false;
      });
      if (response['status']) {
        getNotification();
      } else {
        // setSnackbar(response['message'], context);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        saveStatus = true;
      });
    }
  }

  Future<bool> onWill() {
    Navigator.pop(context, "yes");

    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return WillPopScope(
      onWillPop: onWill,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: MyColorName.mainColor,
          title: Text(
            getTranslated(context, "NOTIFICATION")!,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getTranslated(context, "YOUR_NOTIFICATION")!,
                      style: theme.textTheme.titleMedium!
                          .copyWith(color: theme.hintColor),
                    ),
                    notificationList.length > 0
                        ? !saveStatus
                        ?TextButton(
                      onPressed: () async {
                        getDelete();
                      },
                      child: Text(
                        getTranslated(context, "CLEAR_ALL")??"Clear All",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                          color: MyColorName.mainColor,
                          decoration: TextDecoration.underline,
                          fontSize: 12.0,
                        ),
                      ),
                    ): CircularProgressIndicator()
                        : SizedBox(),
                  ],
                ),
              ),
              !loading
                  ? notificationList.length > 0
                      ? Container(
                          color: theme.backgroundColor,
                          padding: EdgeInsets.only(top: 16),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: notificationList.length,
                            itemBuilder: (context, index) => Container(
                              decoration:
                                  BoxDecoration(borderRadius: BorderRadius.circular(10), ),
                              margin: EdgeInsets.all(10),
                              child: Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color:MyColorName.mainColor.withOpacity(0.1) )
                                  ),

                                  onTap: () {
                                    /*Navigator.pop(
                                        context,
                                        notificationList[index]
                                            .bookingId
                                            .toString());*/
                                  },
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 4),
                                  title: Text(
                                    Common.getString1(
                                        notificationList[index].title.toString()),
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  subtitle: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      Common.getString1(notificationList[index]
                                          .message
                                          .toString()),
                                      style: theme.textTheme.bodySmall!,
                                    ),
                                  ),
                                  trailing: Text(
                                    getTime(notificationList[index]
                                        .added_notify_date),
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: UI.commonButton(
                              title:getTranslated(context, "NO_NOTIFICATION")!,
                              fontSize: 12.0,
                          ),
                        )
                  : Center(
                      child: CircularProgressIndicator(),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
