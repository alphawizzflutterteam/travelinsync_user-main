import 'package:flutter/material.dart';
import 'package:taxi_schedule_user/new_model/address_model.dart';
import 'package:taxi_schedule_user/new_model/schedule_model.dart';
import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/booking_view.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

class RideHistoryScreen extends StatefulWidget {

  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  bool loading = true, network = false;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRides();
  }
  List<Booking> rideList = [];
  Future getRides() async {
    network = await Common.checkInternet();
    if (network) {
      Map param = {
        'user_id': Constants.curUserId,
        'status':'completed'
      };

      Map response = await apiBaseHelper.postAPICall(
          Uri.parse("${Constants.baseUrl}Authentication/getRides"), param);
      rideList.clear();
      if (response['status']) {
        for (var v in response['data']) {
          rideList.add(Booking.fromJson(v));
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
  Future deleteAddress(Booking model) async {
    network = await Common.checkInternet();
    if (network) {
      Map param = {
        'address_id': model.id??'',
      };
      Map response = await apiBaseHelper.postAPICall(
          Uri.parse("${Constants.baseUrl}Authentication/deleteuserAddress"), param);

      if (response['status']) {
        rideList.clear();
        UI.setSnackBar(response['message'], context,color: Colors.green);
        getRides();
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
  Booking? selectedAddress;
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
        title: Text("My Rides"),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          RefreshIndicator(
            onRefresh: () async {
              setState(() {
                loading = true;
              });
              await getRides();
            },
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  Expanded(
                      child: ListView.builder(
                          itemCount: rideList.length,
                          padding: const EdgeInsets.all(12.0),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return BookingView(model: rideList[index]);
                          })),
                ],
              ),
            ),
          ),
          if (loading) CircularProgressIndicator(),
          if (!loading && rideList.isEmpty)
            UI.commonButton(
                title: "No Rides Available",
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  getRides();
                }),
        ],
      ),
    );
  }
}
