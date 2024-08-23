import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxi_schedule_user/new_utils/entry_field.dart';
import 'package:taxi_schedule_user/new_model/schedule_model.dart';
import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

class ChangeScheduleTime extends StatefulWidget {
  // final Schedule model;
  final Booking model;
  const ChangeScheduleTime({super.key, required this.model});

  @override
  State<ChangeScheduleTime> createState() => _ChangeScheduleTimeState();
}

class _ChangeScheduleTimeState extends State<ChangeScheduleTime> {
  TextEditingController pickupTimeCon = TextEditingController();
  TextEditingController dropTimeCon = TextEditingController();
  String pickTime = "", dropTime = "";
  bool loading = true, network = false;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pickTime = widget.model.pickupTime ?? '';
    pickupTimeCon.text = formatTime(widget.model.pickupTime);
    dropTime = widget.model.dropTime ?? '';
    dropTimeCon.text = formatTime(widget.model.dropTime);
  }

  String formatTime(String? time) {
    if (time == null) {
      return "";
    }
    if (!time.contains(":")) {
      return "";
    }
    List<String> formatTime = time.split(":");
    return DateFormat("hh:mm a").format(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(formatTime[0]),
        int.parse(formatTime[1])));
  }

  bool loadingWeek = false;

  Future changeScheduleTime() async {
    network = await Common.checkInternet();
    if (network) {
      Map param = {
        'schedule_id': widget.model.id,
        'pickup_time': pickTime,
        'drop_time': dropTime,
      };
      Map response = await apiBaseHelper.postAPICall(
          Uri.parse("${Constants.baseUrl}Authentication/update_schedule_time"),
          param);
      setState(() {
        loadingWeek = false;
      });
      if (response['status']) {
        Navigator.pop(context, true);
        UI.setSnackBar(response['message'], context, color: Colors.green);
      } else {
        UI.setSnackBar(response['message'] ?? 'Something went wrong', context);
      }
    } else {
      UI.setSnackBar("No Internet Connection", context);
    }
  }

  Future updateRideTime() async {
    network = await Common.checkInternet();
    if (network) {
      Map param = {
        'booking_id': widget.model.id,
        'pickup_time': pickTime,
        'pickup_date': dropTime
      };
      print("update time ${param}");
      Map response = await apiBaseHelper.postAPICall(
          Uri.parse("${Constants.baseUrl}Authentication/update_booking_time"),
          param);
      setState(() {
        loadingWeek = false;
      });
      if (response['status']) {
        // Navigator.pop(context,true);
        Navigator.pop(context, true);

        UI.setSnackBar(response['message'], context, color: Colors.green);
      } else {
        UI.setSnackBar(response['message'] ?? 'Something went wrong', context);
      }
    } else {
      UI.setSnackBar("No Internet Connection", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 10),
      title: Text(
        "Change Schedule Time",
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: EntryField(
                  readOnly: true,
                  controller: pickupTimeCon,
                  onTap: () async {
                    TimeOfDay? date = await selectTime(context);
                    if (date != null) {
                      setState(() {
                        pickTime = DateFormat("HH:mm").format(DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            date.hour,
                            date.minute));
                        pickupTimeCon.text = DateFormat("hh:mm a").format(
                            DateTime(DateTime.now().year, DateTime.now().month,
                                DateTime.now().day, date.hour, date.minute));
                      });
                    }
                  },
                  suffixIcon: IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.watch_later_outlined,
                    ),
                  ),
                  hint: "Start Time",
                ),
              ),
              SizedBox(
                height: 12,
              ),
              dropTimeCon.text == ''
                  ? SizedBox()
                  : Expanded(
                      child: EntryField(
                        readOnly: true,
                        controller: dropTimeCon,
                        onTap: () async {
                          TimeOfDay? date = await selectTime(context);
                          if (date != null) {
                            setState(() {
                              dropTime = DateFormat("HH:mm").format(DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  date.hour,
                                  date.minute));
                              dropTimeCon.text = DateFormat("hh:mm a").format(
                                  DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                      date.hour,
                                      date.minute));
                            });
                          }
                        },
                        suffixIcon: IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.watch_later_outlined,
                          ),
                        ),
                        hint: "Reaching Time",
                      ),
                    ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            "Adjustments to pickup and drop-off times will take effect on the next ride.",
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: Colors.red),
          ),
        ],
      ),
      actions: [
        UI.commonButton(
            title: "Cancel",
            loading: false,
            bgColor: MyColorName.secondColor,
            borderColor: MyColorName.secondColor,
            onPressed: () {
              Navigator.pop(context);
            }),
        UI.commonButton(
            title: "Confirm",
            loading: loadingWeek,
            onPressed: () {
              if (pickupTimeCon.text == "") {
                UI.setSnackBar("Please Select Start Time", context);
                return;
              }
              /*if (dropTimeCon.text == "") {
                UI.setSnackBar("Please Select reach Time", context);
                return;
              }*/
              setState(() {
                loadingWeek = true;
              });
              //changeScheduleTime();
              updateRideTime();
            }),
      ],
    );
  }

  Future<TimeOfDay?> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext? context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: MyColorName.primaryLite,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: MediaQuery(
              data: MediaQuery.of(context!).copyWith(
                alwaysUse24HourFormat: true,
              ),
              child: child!,
            ),
          );
        });

    return picked;
  }
}
