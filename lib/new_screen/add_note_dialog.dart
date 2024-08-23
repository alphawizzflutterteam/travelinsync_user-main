

import 'package:flutter/material.dart';


import 'package:taxi_schedule_user/new_utils/entry_field.dart';
import 'package:taxi_schedule_user/new_model/address_model.dart';
import 'package:taxi_schedule_user/new_model/schedule_model.dart';
import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

class NoteRideScreen extends StatefulWidget {

  final List<Booking> model;
  const NoteRideScreen({super.key,required this.model});

  @override
  State<NoteRideScreen> createState() => _NoteRideScreenState();
}

class _NoteRideScreenState extends State<NoteRideScreen> {
  TextEditingController remarkCon = TextEditingController();
  AddressModel? pickAddress;
  bool loading = true, network = false;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool loadingWeek = false;
  String pickTime = "";
  Future noteRideApi()async{
    network = await Common.checkInternet();
    if(network){
      Map param = {
        'user_id':Constants.curUserId,
        'booking_id':widget.model.first.id,
        'remark':remarkCon.text,
      };
      Map response = await apiBaseHelper.postAPICall(Uri.parse("${Constants.baseUrl}Authentication/booking_remark"), param);
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
        "Add Note",
      ),
      content:  SizedBox(
        width: Common.getWidth(100, context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EntryField(
              controller: remarkCon,
              minLines: 2,
              maxLines: 5,
              suffixIcon: IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.message,
                ),
              ),
              hint: "Enter Note",
            ),
            Text(
              "Please provide a note for any query related to ride.",
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
              if(remarkCon.text==""){
                UI.setSnackBar("Please Enter Remark", context);
                return;
              }
              setState(() {
                loadingWeek = true;
              });
              noteRideApi();
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
