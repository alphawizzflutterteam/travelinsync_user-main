

import 'package:flutter/material.dart';


import 'package:taxi_schedule_user/new_utils/entry_field.dart';
import 'package:taxi_schedule_user/new_model/address_model.dart';
import 'package:taxi_schedule_user/new_model/schedule_model.dart';
import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

class UpdateFlightNo extends StatefulWidget {

  final Schedule model;
  const UpdateFlightNo({super.key,required this.model});

  @override
  State<UpdateFlightNo> createState() => _UpdateFlightNoState();
}

class _UpdateFlightNoState extends State<UpdateFlightNo> {
  TextEditingController flightCon = TextEditingController();
  AddressModel? pickAddress;
  bool loading = true, network = false;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    flightCon.text = widget.model.flightNo??'';
  }

  bool loadingWeek = false;
  String pickTime = "";
  Future updateFlightInfo()async{
    network = await Common.checkInternet();
    if(network){
      Map param = {
        'user_id':Constants.curUserId,
        'schedule_id':widget.model.id,
        'flight_no':flightCon.text,
      };
      Map response = await apiBaseHelper.postAPICall(Uri.parse("${Constants.baseUrl}Authentication/update_flight_info"), param);
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
        "Update Flight No",
      ),
      content:  SizedBox(
        width: Common.getWidth(100, context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EntryField(
              controller: flightCon,
              minLines: 1,
              suffixIcon: IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.flight,
                ),
              ),
              hint: "Enter Flight No.",
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
              if(flightCon.text==""){
                UI.setSnackBar("Please Enter Flight No", context);
                return;
              }
              setState(() {
                loadingWeek = true;
              });
              updateFlightInfo();
            }
        ),
      ],
    );
  }
  Future<AddressModel?> callPickAddress() async {
    var result = await Navigator.pushNamed(
        context, Constants.manageAddressRoute,
        arguments: true);
    return result as AddressModel;
  }
}
