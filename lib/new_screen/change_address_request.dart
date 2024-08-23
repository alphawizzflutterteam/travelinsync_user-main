

import 'package:flutter/material.dart';

import 'package:taxi_schedule_user/new_utils/entry_field.dart';
import 'package:taxi_schedule_user/new_model/address_model.dart';
import 'package:taxi_schedule_user/new_model/schedule_model.dart';
import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

class ChangeAddressRequest extends StatefulWidget {
  final String type;
  final Schedule model;
  const ChangeAddressRequest({super.key,required this.type,required this.model});

  @override
  State<ChangeAddressRequest> createState() => _ChangeAddressRequestState();
}

class _ChangeAddressRequestState extends State<ChangeAddressRequest> {
  TextEditingController pickupCon = TextEditingController();
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
  Future changeAddressRequest()async{
    network = await Common.checkInternet();
    if(network){
      Map param = {
        'schedule_id':widget.model.id,
        'address_id':pickAddress!.id,
        'type':widget.type.toLowerCase(),
      };
      Map response = await apiBaseHelper.postAPICall(Uri.parse("${Constants.baseUrl}Authentication/update_schedule_address"), param);
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
        "Change ${widget.type} Address Request",
      ),
      content:  Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EntryField(
            readOnly: true,
            controller: pickupCon,
            onTap: () async {
              AddressModel? model = await callPickAddress();
              if (model != null) {
                setState(() {
                  pickAddress = model;
                  pickupCon.text = pickAddress!.address ?? '';
                });
              }
            },
            suffixIcon: IconButton(
              onPressed: null,
              icon: Icon(
                Icons.location_searching,
              ),
            ),
            hint: "Select Address",
          ),
          Text(
            "Adjustments to pickup and drop address will take effect on the next ride.",
            style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.red),
          ),
        ],
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
              if (pickupCon.text == "") {
                UI.setSnackBar(
                    "Please Select Address",
                    context);
                return;
              }
              setState(() {
                loadingWeek = true;
              });
              changeAddressRequest();
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
