
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

import 'package:taxi_schedule_user/new_model/address_model.dart';
import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/Demo_Localization.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/entry_field.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';


class AddAddress extends StatefulWidget {
  final AddressModel? addressModel;
  const AddAddress({super.key,this.addressModel});

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  TextEditingController addressCon = TextEditingController();
  double lat=0,lng = 0;
  String selectedType = "Home";
  bool loading = false,network = false;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  Future addAddress(String url)async{
    network = await Common.checkInternet();
    if(network){
      Map param = {
        'user_id':Constants.curUserId,
        'address':addressCon.text,
        'type':selectedType,
        'lat':lat.toString(),
        'lang':lng.toString(),
      };
      if(widget.addressModel!=null){
        param['address_id'] = widget.addressModel!.id??'';
      }
      Map response = await apiBaseHelper.postAPICall(Uri.parse("${Constants.baseUrl}Authentication/$url"), param);
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
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.addressModel!=null){
      addressCon.text = widget.addressModel!.address??'';
     selectedType = widget.addressModel!.type??'';
      lat = double.parse(widget.addressModel!.lat??'0');
      lng = double.parse(widget.addressModel!.lang??'0');
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: MyColorName.mainColor,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
        title: Text(
            widget.addressModel!=null?"Edit Address":"Add Address"
        ),
      ),
      body: Container(
        padding:const EdgeInsets.all(10),
        child: Column(
          children: [
            EntryField(
              readOnly: true,
              controller: addressCon,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlacePicker(
                      apiKey: Platform.isAndroid
                          ? "AIzaSyBPFf5uo0zrJwx1BaLFZonJaQ7vNHVbQkw"
                          : "AIzaSyBPFf5uo0zrJwx1BaLFZonJaQ7vNHVbQkw",
                      onPlacePicked: (result) {
                        lat = result.geometry!.location.lat;
                        lng = result.geometry!.location.lng;
                        addressCon.text =
                            result.formattedAddress.toString();
                        Navigator.of(context).pop();
                      },
                      initialPosition: LatLng(latitude, longitude),
                      useCurrentLocation: true,
                    ),
                  ),
                );
              },
              suffixIcon: IconButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlacePicker(
                        apiKey: Platform.isAndroid
                            ? "AIzaSyBPFf5uo0zrJwx1BaLFZonJaQ7vNHVbQkw"
                            : "AIzaSyBPFf5uo0zrJwx1BaLFZonJaQ7vNHVbQkw",
                        onPlacePicked: (result) {
                          lat = result.geometry!.location.lat;
                          lng = result.geometry!.location.lng;
                          addressCon.text =
                              result.formattedAddress.toString();
                          Navigator.of(context).pop();
                        },
                        initialPosition: LatLng(latitude, longitude),
                        useCurrentLocation: true,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.location_searching,
                ),
              ),
              hint: "Select Address",
              label: getTranslated(context, "Address")??'Address',
            ),
            const SizedBox(height: 12,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Type",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Theme.of(context).hintColor),
                  ),
                  Row(
                    children: ['Home','Work','Other'].map((e){
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: UI.commonButton(
                          title: e,
                          fontColor: selectedType!=e?MyColorName.mainColor:Colors.white,
                          bgColor: selectedType==e?MyColorName.mainColor:Colors.white,
                          onPressed: (){
                              setState(() {
                                selectedType=e;
                              });
                          }
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12,),
            SizedBox(
              width: Common.getWidth(50, context),
              child: UI.commonButton(
                title: widget.addressModel!=null?"Update Address":"Save Address",
                loading: loading,
                onPressed: (){
                  if(addressCon.text==""){
                    UI.setSnackBar("Please Select Address", context);
                    return;
                  }
                  setState(() {
                    loading = true;
                  });
                  addAddress(widget.addressModel!=null?"updateAddress":"addAddress");
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
