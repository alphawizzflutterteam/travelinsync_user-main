import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_schedule_user/new_model/schedule_model.dart';
import 'package:taxi_schedule_user/new_screen/change_ride_time.dart';
import 'package:taxi_schedule_user/new_utils/booking_view.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/custom_map.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

class RideInfoScreen extends StatefulWidget {
  // final Booking model;
  final List <Booking>? model;
  const RideInfoScreen({super.key, this.model, });

  @override
  State<RideInfoScreen> createState() => _RideInfoScreenState();
}

class _RideInfoScreenState extends State<RideInfoScreen> {
  late final List <Booking>? model;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = widget.model;
  }
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
        title: Text("Ride Info"),
      ),
      body: MapPage(
        true,
        live: widget.model?.first.status=="Started"?true:false,
        id: widget.model!.first.assignedFor,
        zoom: 16,
        pick: widget.model?.first.pickupAddress.toString() ?? '',
        dest: widget.model!.first.dropAddress.toString(),
        model: widget.model!.first.dropAddress == null ||
            widget.model!.first.dropAddress == ""
            ? widget.model!.first
            : null,
        onResult: (result) {

        },
        carType: "2",
        status1: widget.model!.first.status,
        SOURCE_LOCATION: LatLng(
            double.parse(widget.model!.first.latitude??'0'),
            double.parse(widget.model!.first.longitude??'0')),
        DEST_LOCATION: LatLng(
            double.parse(
                widget.model!.first.dropLatitude??'0'),
            double.parse(
                widget.model!.first.dropLongitude??'0'))),
      bottomNavigationBar:Container(
        padding: const EdgeInsets.all(10),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Ride Details",
              style:
              Theme.of(context).textTheme.headlineLarge!.copyWith(
                color: MyColorName.mainColor,
                fontWeight: FontWeight.w800,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            BookingView(model: model!.first ,disable: true,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Tooltip(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: MyColorName.mainColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  message:
                  "Cancel Ride.",
                  child: TextButton(
                    onPressed: () async {

                    },
                    child: Text(
                      "Cancel Ride",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(
                        color: MyColorName.mainColor,
                        decoration:
                        TextDecoration.underline,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
                if(enableButton(model!.first.pickupTime))
                  Tooltip(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: MyColorName.mainColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    message:
                    "Until 2 hours before the pickup, you can make changes to the timing.",
                    child: TextButton(
                      onPressed: () async {
                        if(enableButton(model?.first.pickupTime)){
                          var result = await showDialog(
                              context: context,
                              builder: (ctx) {
                                return ChangeRideTime(
                                  model: widget.model ?? [],
                                );
                              });
                          if (result != null) {
                            Navigator.pop(context,true);
                          }
                        }else{
                          UI.setSnackBar("Until 2 hours before the pickup, you can make changes to the timing.", context);
                        }

                      },
                      child: Text(
                        "Change Timing",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                          color: MyColorName.mainColor,
                          decoration:
                          TextDecoration.underline,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  bool enableButton(String? time){
    if (time == null) {
      return true;
    }
    if (!time.contains(":")) {
      return true;
    }
    List<String> formatTime = time.split(":");
    DateTime firstTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        int.parse(formatTime[0]),
        int.parse(formatTime[1]));
    DateTime secondTime = DateTime.now();
    Common.debugPrintApp(firstTime.difference(secondTime).inMinutes);
    return firstTime.difference(secondTime).inMinutes>120;
  }
}
