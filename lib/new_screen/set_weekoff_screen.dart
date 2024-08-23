import 'package:flutter/material.dart';
import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

class SetWeekOffScreen extends StatefulWidget {
  const SetWeekOffScreen({super.key});

  @override
  State<SetWeekOffScreen> createState() => _SetWeekOffScreenState();
}

class _SetWeekOffScreenState extends State<SetWeekOffScreen> {
  List<String> selectedDay = [];
  bool loading = true, network = false;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWeekDay();
  }
  bool loadingWeek = false;
  Future setWeekOff()async{
    network = await Common.checkInternet();
    if(network){
      Map param = {
        'user_id':Constants.curUserId,
        'week_off_day':selectedDay.join(','),
      };
      Map response = await apiBaseHelper.postAPICall(Uri.parse("${Constants.baseUrl}Authentication/set_week_off"), param);
      setState(() {
        loadingWeek = false;
      });
      if(response['status']){

        UI.setSnackBar(response['message'], context,color: Colors.green);
      }else{
        UI.setSnackBar(response['message']??'Something went wrong', context);
      }
    }else{
      UI.setSnackBar("No Internet Connection", context);
    }
  }
  Future getWeekDay() async {
    network = await Common.checkInternet();
    if (network) {
      Map param = {
        'user_id': Constants.curUserId,
      };
      Map response = await apiBaseHelper.postAPICall(
          Uri.parse("${Constants.baseUrl}Authentication/get_week_off"), param);
      selectedDay.clear();
      if (response['status']&&response['data']!=null&&response['data']['days']!=null) {
        for (var v in response['data']['days'].toString().split(",")) {
          selectedDay.add(v);
        }
      } else {
        UI.setSnackBar(response['message'] ?? 'Something went wrong', context);
      }
    } else {
      UI.setSnackBar("No Internet Connection", context);
    }
    setState(() {
      loading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 10),
      title: Text(
        "Set Week-off Days",
      ),
      content:  Padding(
        padding: const EdgeInsets.symmetric(horizontal:10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Week Days",
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: Theme.of(context).hintColor),
            ),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'].map((e){
                return UI.commonButton(
                    title: e,
                    fontColor: !selectedDay.contains(e)?MyColorName.mainColor:Colors.white,
                    bgColor: selectedDay.contains(e)?MyColorName.mainColor:Colors.white,
                    onPressed: (){
                      setState(() {
                        if(selectedDay.contains(e)){
                          selectedDay.remove(e);
                        }else{
                          selectedDay.add(e);
                        }
                      });
                    }
                );
              }).toList(),
            ),
            if(loading)
             const Center(child: CircularProgressIndicator(),)
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
            title: "Save",
            loading: loadingWeek,
            onPressed: (){
              if(selectedDay.isEmpty){
                UI.setSnackBar("Please select day by tapping", context);
                return;
              }
              setState(() {
                loadingWeek = true;
              });
              setWeekOff();
            }
        ),
      ],
    );
  }
}
