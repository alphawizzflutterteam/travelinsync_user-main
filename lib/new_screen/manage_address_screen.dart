import 'package:flutter/material.dart';
import 'package:taxi_schedule_user/new_model/address_model.dart';
import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

class ManageAddress extends StatefulWidget {
  final bool selected;
  const ManageAddress({super.key,this.selected = false});

  @override
  State<ManageAddress> createState() => _ManageAddressState();
}

class _ManageAddressState extends State<ManageAddress> {
  bool loading = true, network = false;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAddress();
  }
  List<AddressModel> addressList = [];
  Future getAddress() async {
    network = await Common.checkInternet();
    if (network) {
      Map param = {
        'user_id': Constants.curUserId,
      };
      Map response = await apiBaseHelper.postAPICall(
          Uri.parse("${Constants.baseUrl}Authentication/getAddress"), param);
      addressList.clear();
      if (response['status']) {
        for (var v in response['data']) {
          addressList.add(AddressModel.fromJson(v));
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
  Future deleteAddress(AddressModel model) async {
    network = await Common.checkInternet();
    if (network) {
      Map param = {
        'address_id': model.id??'',
      };
      Map response = await apiBaseHelper.postAPICall(
          Uri.parse("${Constants.baseUrl}Authentication/deleteuserAddress"), param);

      if (response['status']) {
        addressList.clear();
        UI.setSnackBar(response['message'], context,color: Colors.green);
        getAddress();
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
  AddressModel? selectedAddress;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColorName.mainColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
        title: Text("Manage Address"),
      ),

      body: Stack(
        alignment: Alignment.center,
        children: [
          RefreshIndicator(
            onRefresh: () async {
              setState(() {
                loading = true;
              });
              await getAddress();
            },
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  Expanded(
                      child: ListView.builder(
                          itemCount: addressList.length,
                          padding: const EdgeInsets.all(12.0),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    if(widget.selected)
                                    Radio(value: addressList[index], groupValue: selectedAddress, onChanged: (AddressModel? model){

                                        Navigator.pop(context,model);
                                    }),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            addressList[index].type ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Text(
                                              addressList[index].address ?? ''),
                                        ],
                                      ),
                                    ),
                                    if(!widget.selected)
                                      IconButton(
                                      onPressed: () async {
                                        var data = await Navigator.pushNamed(
                                            context, Constants.addAddressRoute,
                                            arguments: addressList[index]);
                                        if (data != null) {
                                          setState(() {
                                            loading = true;
                                          });
                                          getAddress();
                                        }
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                      ),
                                    ),
                                    if(!widget.selected)
                                      IconButton(
                                      onPressed: () async {
                                        showDialog(context: context, builder: (context){
                                          return   UI.commonDialog(
                                              context,
                                              title: "Delete Address",
                                              content:
                                              "Do you want to delete address?",
                                              yesText: 'Confirm',
                                              noText: 'Cancel',
                                              onNoPressed: (){
                                                Navigator.pop(context);
                                              },
                                              onYesPressed: (){
                                                Navigator.pop(context);
                                                setState(() {
                                                  loading = true;
                                                });
                                                deleteAddress(addressList[index]);
                                              }
                                          );
                                        });

                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })),
                ],
              ),
            ),
          ),
          if (loading) CircularProgressIndicator(),
          if (!loading && addressList.isEmpty)
            UI.commonButton(
                title: "Add Address",
                onPressed: () async {
                  var data = await Navigator.pushNamed(
                      context, Constants.addAddressRoute);
                  if (data != null) {
                    setState(() {
                      loading = true;
                    });
                    getAddress();
                  }
                }),
        ],
      ),
      bottomNavigationBar: !loading && addressList.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  UI.commonButton(
                      title: "Add Address",
                      onPressed: () async {
                        var data = await Navigator.pushNamed(
                            context, Constants.addAddressRoute);
                        if (data != null) {
                          setState(() {
                            loading = true;
                          });
                          getAddress();
                        }
                      }),
                ],
              ),
            )
          : null,
    );
  }
}
