

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxi_schedule_user/new_utils/entry_field.dart';
import 'package:taxi_schedule_user/new_model/schedule_model.dart';
import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

class ChangeRideTime extends StatefulWidget {
  final List <Booking> model;
  const ChangeRideTime({super.key,required this.model});

  @override
  State<ChangeRideTime> createState() => _ChangeRideTimeState();
}

class _ChangeRideTimeState extends State<ChangeRideTime> {
  TextEditingController pickupTimeCon = TextEditingController();
  bool loading = true, network = false;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pickTime = widget.model.first.pickupTime??'';
    pickupTimeCon.text = formatTime(widget.model.first.pickupTime);
  }
  String formatTime(String? time){
    if(time==null){
      return "";
    }
    if(!time.contains(":")){
      return "";
    }
    List<String> formatTime = time.split(":");
    return DateFormat("hh:mm a").format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,int.parse(formatTime[0]),int.parse(formatTime[1])));
  }
  bool loadingWeek = false;
  String pickTime = "";

  Future changeRideTime() async {
    network = await Common.checkInternet();
    if(network){

      Map param = {
        'booking_id':widget.model.first.id,
        'pickup_time':pickTime,
      };
      Map response = await apiBaseHelper.postAPICall(Uri.parse("${Constants.baseUrl}Authentication/update_booking_time"), param);
      setState(() {
        loadingWeek = false;
      });
      if(response['status']){
        Navigator.pop(context,true);

        UI.setSnackBar(response['message'], context,color: Colors.green);
      }else{
        UI.setSnackBar(response['message']??'Something went wrong', context);
      }
    }else{
      UI.setSnackBar("No Internet Connection", context);
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 10),
      title: Text(
        "Change Ride Time",
      ),
      content:  Padding(
        padding: const EdgeInsets.symmetric(horizontal:10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Start Time",
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 5,),
            EntryField(
              readOnly: true,
              controller: pickupTimeCon,
              onTap: ()async {
                TimeOfDay? date = await selectTime(context);
                if (date != null) {
                  setState(() {
                    pickTime = DateFormat("HH:mm").format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,date.hour,date.minute));
                    pickupTimeCon.text = DateFormat("hh:mm a").format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,date.hour,date.minute));
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
            Text(
              "Until 2 hours before the pickup, you can make changes to the timing.",
              style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.red),
            ),
          ],
        ),
      ),
      actions: [
        UI.commonButton(
            title: "Cancel",
            loading: false,
            bgColor: MyColorName.secondColor,
            borderColor: MyColorName.secondColor,
            onPressed: (){
              Navigator.pop(context);
            }
        ),
        UI.commonButton(
            title: "Confirm",
            loading: loadingWeek,
            onPressed: (){
              if(pickupTimeCon.text==""){
                UI.setSnackBar("Please Select Start Time", context);
                return;
              }
              setState(() {
                loadingWeek = true;
              });
              changeRideTime();
            }
        ),
      ],
    );
  }
  Future<TimeOfDay?> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(), builder: (BuildContext? context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme:const ColorScheme.light(
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
      );});

    return picked;
  }
}
