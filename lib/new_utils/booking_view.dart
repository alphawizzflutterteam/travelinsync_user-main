import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxi_schedule_user/new_model/schedule_model.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingView extends StatelessWidget {
  final Booking model;
  final bool disable;
  const BookingView({super.key, required this.model, this.disable = false});
  @override
  Widget build(BuildContext context) {
    String? estTime = Common.estimateTime(model.latitude, model.longitude,
        model.driverLatitude, model.driverLangitude, model.driverSpeed);
    return Material(
      color: Colors.transparent,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(color: MyColorName.mainColor.withOpacity(0.1))),
        child: InkWell(
          onTap: disable
              ? null
              : () async {
                  var data = await Navigator.pushNamed(
                      context, Constants.rideInfoRoute,
                      arguments: model);
                  if (data != null) {}
                },
          child: Column(
            children: [
              ListTile(
                tileColor: Colors.white,
                leading: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Trip ID",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          fontSize: 10.0, color: MyColorName.secondColor),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "${model.id}",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: MyColorName.secondColor),
                    ),
                  ],
                ),
                trailing: UI.commonButton(
                    title: "${model.status}",
                    fontColor: Colors.white,
                    bgColor: model.status == "Pending"
                        ? Colors.orange
                        : model.status == "Started"
                            ? Colors.deepPurple
                            : model.status == "Completed"
                                ? Colors.green
                                : Colors.red,
                    borderColor: model.status == "Pending"
                        ? Colors.orange
                        : model.status == "Started"
                            ? Colors.deepPurple
                            : model.status == "Completed"
                                ? Colors.green
                                : Colors.red,
                    onPressed: null),
                title: Text(
                  /*"${Common.getString1(model.type ?? '')} Ride",*/ "",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 16.0,
                      ),
                ),
                subtitle: Text(
                  "Start Ride OTP: ${model.bookingOtp}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (estTime != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Estimate Reached Time: $estTime",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: MyColorName.secondColor,
                          fontSize: 12.0,
                        ),
                  ),
                ),
              model.driveruserName != null
                  ? ListTile(
                      tileColor: Colors.white,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            child: Image.network(
                              model.driverImage ?? "",
                              fit: BoxFit.cover,
                            )),
                      ),
                      trailing: UI.commonIconButton(
                          iconData: Icons.call,
                          iconColor: MyColorName.secondColor,
                          message: "Call To Driver",
                          onPressed: () {
                            launchUrl(Uri.parse("tel://${model.drivermobile}"));
                          }),
                      title: Text(
                        model.driveruserName ?? "",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      subtitle: Text(
                        model.drivermobile ?? "",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "Driver not assigned.",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: Colors.red),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Date: ${model.pickupDate}",
                        style:
                            Theme.of(context).textTheme.headlineLarge!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.0,
                                ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Time: ${formatTime(model.pickupTime)}",
                        textAlign: TextAlign.end,
                        style:
                            Theme.of(context).textTheme.headlineLarge!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.0,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              if (model.userRemark != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Note: ${model.userRemark}",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: MyColorName.secondColor,
                          fontSize: 12.0,
                        ),
                  ),
                ),
              if (model.remark != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Remark: ${model.remark}",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: MyColorName.secondColor,
                          fontSize: 12.0,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
}
