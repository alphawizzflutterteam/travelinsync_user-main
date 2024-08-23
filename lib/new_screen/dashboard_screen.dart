import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_schedule_user/new_screen/add_note_dialog.dart';
import 'package:taxi_schedule_user/new_screen/cancel_ride_dialog.dart';
import 'package:taxi_schedule_user/new_screen/update_flight_dialog.dart';
import 'package:taxi_schedule_user/new_utils/Demo_Localization.dart';

import 'package:taxi_schedule_user/new_utils/entry_field.dart';
import 'package:taxi_schedule_user/new_model/address_model.dart';
import 'package:taxi_schedule_user/new_model/schedule_model.dart';
import 'package:taxi_schedule_user/new_model/user_model.dart';
import 'package:taxi_schedule_user/new_screen/change_address_request.dart';
import 'package:taxi_schedule_user/new_screen/change_ride_time.dart';
import 'package:taxi_schedule_user/new_screen/change_schedule_time.dart';
import 'package:taxi_schedule_user/new_screen/drawer_screen.dart';
import 'package:intl/intl.dart';
import 'package:taxi_schedule_user/new_screen/set_weekoff_screen.dart';
import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/booking_view.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/firebase_msg.dart';
import 'package:taxi_schedule_user/new_utils/location_details.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

import '../new_model/AllScheduleModel.dart';

String name = "", loginType = "";

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    registerToken();
    getProfile();
    getSchedule();
    // convertDateTimeDispla();
    GetLocation location = GetLocation((result) {
      if (mounted) {
        setState(() {
          var first = result.first;
          address =
              '${first.name},${first.subLocality},${first.locality},${first.country}';
          latitude = latitudeFirst;
          longitude = longitudeFirst;
          if (googleMapController != null) {
            googleMapController!.moveCamera(
                CameraUpdate.newLatLng(LatLng(latitude, longitude)));
          }
          //pickupCon.text = address;
          // pickupCityCon.text = result.first.locality;
          //  print(pickupCityCon.text);
        });
      }
    });
    location.getLoc();
  }

  String? selectDays;

  var itemDays = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15'
  ];

  bool background = false;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (background) {
          background = false;
          getSchedule();
          print("app in resumed from background");
        }
        //you can add your codes here
        break;
      case AppLifecycleState.inactive:
        background = true;
        print("app is in inactive state");
        break;
      case AppLifecycleState.paused:
        background = true;
        print("app is in paused state");
        break;
      case AppLifecycleState.detached:
        background = true;
        print("app has been removed");
        break;
      case AppLifecycleState.hidden:
        background = true;
        print("app has been hidden");
        // TODO: Handle this case.
        break;
    }
  }

  ApiBaseHelper apiBase = ApiBaseHelper();
  bool loading = false;
  Future<void> getProfile() async {
    try {
      setState(() {
        loading = true;
      });
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      Map params = {
        "user_id": Constants.curUserId.toString(),
        "device_info": androidInfo.id.toString(),
      };
      Map response = await apiBase.postAPICall(
          Uri.parse("${Constants.baseUrl}Authentication/get_profile"), params);
      if (response['status'] && response["data"] != null) {
        Constants.imageBaseUrl = response['image_path'].toString();
        Constants.userModel = UserModel.fromJson(response['data']);
        setState(() {
          if (Constants.userModel != null) {
            Constants.userName = Constants.userModel!.username ?? '';
            Constants.userProfile = Constants.userModel!.userImage ?? '';
          }
        });
        print("IMAGE========" + Constants.imageBaseUrl.toString());
      } else {
        UI.setSnackBar(response['message'], context);
        // App.localStorage.clear();
        // Common.logoutApi();
        // Navigator.pushNamedAndRemoveUntil(context, Constants.loginRoute, (route) => false);
      }
    } on TimeoutException catch (_) {
      UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      setState(() {
        loading = false;
      });
    }
  }

  registerToken() async {
    String? deviceToken =
        await FireBaseMessagingService(context).setDeviceToken();
    Map data = {
      "user_id": Constants.curUserId.toString(),
      "device_id": deviceToken.toString(),
    };
    Map response = await apiBase.postAPICall(
        Uri.parse("${Constants.baseUrl}Authentication/update_Fcm_token_user"),
        data);
    if (response['status']) {
    } else {}
  }

  AddressModel? pickAddress;
  AddressModel? dropAddress;

  String initialRoute = Constants.homeRoute;
  GoogleMapController? googleMapController;

  var dateFormate;
  String? currentDate;
  String? timeData;
  bool isVisible = false;

  convertDateTimeDispla() async {
    var now = DateTime.now();
    var yesterday = now.add(Duration(days: 0));
    var formatter = DateFormat('yyyy-MM-dd');
    currentDate = formatter.format(yesterday);
    print("date before $currentDate");
    print("date before ${scheduleModel?.schedule}");
    print("date beforesssssss ${scheduleModel?.schedule?.endDate}");
    if (scheduleModel?.schedule != null &&
        scheduleModel!.schedule!.endDate != null) {
      print("ffdfdfd ${scheduleModel!.schedule!.endDate}");
      parsedDate =
          DateTime.parse('${scheduleModel?.schedule?.endDate.toString()}');
      isVisible = parsedDate!.isAfter(DateTime.parse(currentDate.toString()));
      print('isVisible ${isVisible} ${parsedDate} ${currentDate}');
    } else {
      isVisible = false;
    }
    setState(() {});
    //print("hehehehehehe ${parsedDate!.isBefore(DateTime.now())}");
  }

  DateTime? parsedDate;

  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    //print("object the value is ${scheduleModel!.booking!}");
    // print("object the value is ${scheduleModel!.booking!.isEmpty && !loading && !isVisible}");
    CameraPosition initialLocation = CameraPosition(
      zoom: 15,
      bearing: 30,
      tilt: 40,
      target: LatLng(20.5937, 78.9629),
    );
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: MyColorName.mainColor,
          leading: IconButton(
            onPressed: () {
              scaffoldKey.currentState!.openDrawer();
            },
            icon: Icon(
              Icons.menu,
            ),
          ),
          title: Text(Constants.userName),
          actions: [
            UI.commonIconButton(
              message: "Set Week-off Day",
              iconData: Icons.calendar_month,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return SetWeekOffScreen();
                    });
              },
            ),
            UI.commonIconButton(
              message: "Subscriptions",
              iconData: Icons.subscriptions,
              onPressed: () {
                Navigator.pushNamed(context, Constants.planRoute);
              },
            ),
            UI.commonIconButton(
              message: "Notifications",
              iconData: Icons.notifications_active,
              onPressed: () {
                Navigator.pushNamed(context, Constants.notificationRoute);
              },
            ),
          ],
        ),
        drawer: Drawer(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              //  topRight: Radius.circular(30),
              bottomRight: Radius.circular(60),
            ),
          ),
          child: DrawerScreen(
            onResult: (result) async {
              if (result != null) {
                if (result == 1) {
                  var data = await Navigator.pushNamed(
                      context, Constants.profileRoute);
                  if (data != null) {
                    getProfile();
                  }
                } else if (result == 5) {
                  Navigator.pushNamed(context, Constants.privacyRoute);
                } else if (result == 6) {
                  Navigator.pushNamed(context, Constants.termsRoute);
                } else if (result == 7) {
                  Navigator.pushNamed(context, Constants.faqRoute);
                } else if (result == 3) {
                  Navigator.pushNamed(context, Constants.manageAddressRoute);
                } else if (result == 4) {
                  Navigator.pushNamed(context, Constants.planRoute);
                } else if (result == 2) {
                  Navigator.pushNamed(context, Constants.rideHistoryRoute);
                } else if (result == 0) {
                  Navigator.pop(context);
                  setState(() {
                    loading = true;
                  });
                  getSchedule();
                }
              }
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton:
            (scheduleModel == null || scheduleModel!.booking!.isEmpty)
                ? mycardshow()
                : null,
        /*!loading && isVisible && (allScheduleModel?.bookings.isNotEmpty ?? false)
            ? Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(color: MyColorName.secondColor),
                ),
                color: Colors.white,
                margin: EdgeInsets.all(10.0),
                child: Container(
                  height: MediaQuery.of(context).size.height / 1.4,
                  color: Colors.transparent,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        allScheduleModel?.data?.id != null && (allScheduleModel?.bookings.isNotEmpty ?? false)
                            ? allschedule()
                            : SizedBox(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Create Schedule Ride",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(
                                    color: MyColorName.mainColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16.0,
                                  ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Pickup Address",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                    ),
                                    Tooltip(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: MyColorName.mainColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      message:
                                          "The pickup location at the start time and\nthe drop-off location at the dropping time.",
                                      triggerMode: TooltipTriggerMode.tap,
                                      child: Icon(
                                        Icons.info_outlined,
                                        color: MyColorName.mainColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                EntryField(
                                  readOnly: true,
                                  controller: pickupCon,
                                  onTap: () async {
                                    AddressModel? model =
                                        await callPickAddress();
                                    if (model != null) {
                                      setState(() {
                                        pickAddress = model;
                                        pickupCon.text =
                                            pickAddress!.address ?? '';
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
                                const SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Drop Address",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      ),
                                    ),
                                    Tooltip(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: MyColorName.mainColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      message:
                                          "The drop location at the start time and\nthe pickup location at the dropping time.",
                                      triggerMode: TooltipTriggerMode.tap,
                                      child: Icon(
                                        Icons.info_outlined,
                                        color: MyColorName.mainColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                EntryField(
                                  readOnly: true,
                                  controller: dropCon,
                                  onTap: () async {
                                    AddressModel? model =
                                        await callPickAddress();
                                    if (model != null) {
                                      setState(() {
                                        dropAddress = model;
                                        dropCon.text =
                                            dropAddress!.address ?? '';
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
                                const SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: EntryField(
                                        readOnly: true,
                                        controller: pickupTimeCon,
                                        onTap: () async {
                                          TimeOfDay? date =
                                              await selectTime(context);
                                          if (date != null) {
                                            setState(() {
                                              pickTime = DateFormat("HH:mm")
                                                  .format(DateTime(
                                                      DateTime.now().year,
                                                      DateTime.now().month,
                                                      DateTime.now().day,
                                                      date.hour,
                                                      date.minute));
                                              pickupTimeCon.text =
                                                  DateFormat("hh:mm a").format(
                                                      DateTime(
                                                          DateTime.now().year,
                                                          DateTime.now().month,
                                                          DateTime.now().day,
                                                          date.hour,
                                                          date.minute),
                                                  );
                                            });
                                          }
                                        },
                                        suffixIcon: IconButton(
                                          onPressed: null,
                                          icon: Icon(
                                            Icons.watch_later_outlined,
                                          ),
                                        ),
                                        hint: "start time",
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Expanded(
                                      child: EntryField(
                                        readOnly: true,
                                        controller: reachTimeCon,
                                        onTap: () async {
                                          TimeOfDay? date =
                                              await selectTime(context);
                                          if (date != null) {
                                            setState(() {
                                              reachTime  = DateFormat("HH:mm")
                                                  .format(DateTime(
                                                      DateTime.now().year,
                                                      DateTime.now().month,
                                                      DateTime.now().day,
                                                      date.hour,
                                                      date.minute));
                                              reachTimeCon.text =
                                                  DateFormat("hh:mm a").format(
                                                      DateTime(
                                                          DateTime.now().year,
                                                          DateTime.now().month,
                                                          DateTime.now().day,
                                                          date.hour,
                                                          date.minute));
                                            });
                                          }
                                        },
                                        suffixIcon: IconButton(
                                          onPressed: null,
                                          icon: Icon(
                                            Icons.watch_later_outlined,
                                          ),
                                        ),
                                        hint: "Reaching Time",
                                      ),
                                    ),
                                  ],
                                ),
                                EntryField(
                                  readOnly: true,
                                  controller: returnTimeCon,
                                  onTap: () async {
                                    TimeOfDay? date = await selectTime(context);
                                    if (date != null) {
                                      setState(() {
                                        dropTime = DateFormat("HH:mm").format(
                                          DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day,
                                              date.hour,
                                              date.minute),
                                        );
                                        returnTimeCon.text =
                                            DateFormat("hh:mm a").format(
                                                DateTime(
                                                    DateTime.now().year,
                                                    DateTime.now().month,
                                                    DateTime.now().day,
                                                    date.hour,
                                                    date.minute));
                                      });
                                    }
                                  },
                                  suffixIcon: IconButton(
                                    onPressed: null,
                                    icon: Icon(
                                      Icons.watch_later_outlined,
                                    ),
                                  ),
                                  hint: "End Time",
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                    "This time is scheduled for daily rides, and you can adjust it later or for a one-time change.",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .copyWith(color: Colors.red)),
                                const SizedBox(
                                  height: 12,
                                ),
                                EntryField(
                                  controller: flightCon,
                                  suffixIcon: IconButton(
                                    onPressed: null,
                                    icon: Icon(
                                      Icons.flight,
                                    ),
                                  ),
                                  hint: "Enter Flight No.",
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                if (rideStartCon.text != "")
                                  Text(
                                    "Rides Start Date - ${DateFormat("dd MMM yyyy").format(DateTime.parse(rideStartCon.text))}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge!
                                        .copyWith(
                                          color: MyColorName.mainColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16.0,
                                        ),
                                  ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  children: [
                                    Tooltip(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: MyColorName.mainColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      message: "Select Rides Start Date",
                                      triggerMode: TooltipTriggerMode.longPress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: MyColorName.mainColor,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: IconButton(
                                          onPressed: () async {
                                            DateTime? date =
                                                await selectDate(context);
                                            if (date != null) {
                                              setState(() {
                                                rideStartCon.text =
                                                    DateFormat("yyyy-MM-dd")
                                                        .format(date);
                                              });
                                            }
                                          },
                                          padding: EdgeInsets.all(1.0),
                                          visualDensity: VisualDensity.standard,
                                          icon: Icon(
                                            Icons.calendar_today,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Expanded(
                                      child: UI.commonButton(
                                          title: "Schedule",
                                          loading: loadingSchedule,
                                          onPressed: () {
                                            if (pickupCon.text == "") {
                                              UI.setSnackBar(
                                                  "Please Select Pickup Address",
                                                  context);
                                              return;
                                            }
                                            if (dropCon.text == "") {
                                              UI.setSnackBar(
                                                  "Please Select Drop Address",
                                                  context);
                                              return;
                                            }
                                            if (pickupTimeCon.text == "") {
                                              UI.setSnackBar(
                                                  "Please Select Start Time",
                                                  context);
                                              return;
                                            }
                                            // if (dropTimeCon.text == "") {
                                            //   UI.setSnackBar(
                                            //       "Please Select Drop-off Time", context);
                                            //   return;
                                            // }
                                            if (rideStartCon.text == "") {
                                              UI.setSnackBar(
                                                  "Please Select Rides Start date",
                                                  context);
                                              return;
                                            }
                                            if (flightCon.text == "") {
                                              UI.setSnackBar(
                                                  "Please Enter Flight No.",
                                                  context);
                                              return;
                                            }
                                            setState(() {
                                              loadingSchedule = true;
                                            });
                                            scheduleRide();
                                          }),
                                    ),
                                    SizedBox(width: 10),
                                    allScheduleModel?.data?.id != null ?
                                    Expanded(
                                      child: UI.commonButton(
                                          title: "Complete",
                                          // loading: loadingSchedule,
                                          onPressed: () {
                                            // if (pickupCon.text == "" || dropCon.text == "" || pickupTimeCon.text == "" || flightCon.text == "") {
                                            //   UI.setSnackBar("Please Create Any One Schedule", context);
                                            //   return;
                                            // }
                                            // setState(() {
                                            //   loadingSchedule = true;
                                            // });
                                           // allScheduleModel?.data?.id = null ;
                                           // allScheduleModel!.bookings = [];
                                            getSchedule();
                                          }),
                                    ):SizedBox(),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,*/
        body: Stack(
          alignment: Alignment.center,
          children: [
            RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  loading = true;
                });
                await getProfile();
                await getSchedule();
              },
              child: Container(
                width: double.infinity,
                child: GoogleMap(
                  myLocationEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController = controller;
                  },
                  compassEnabled: true,
                  scrollGesturesEnabled: true,
                  zoomControlsEnabled: false,
                  tiltGesturesEnabled: false,
                  mapType: MapType.normal,
                  initialCameraPosition: initialLocation,
                ),
              ),
            ),
            if (scheduleModel != null && isVisible)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 350,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: scheduleModel?.booking?.length ?? 0,
                      itemBuilder: (context, j) {
                        return Container(
                          // width: double.infinity,
                          //height: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    Text(
                                      "Rides Start Date - ${scheduleModel!.booking![j].pickupDate}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge!
                                          .copyWith(
                                            color: MyColorName.mainColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16.0,
                                          ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Pickup Address",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16.0,
                                                ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            var result = await showDialog(
                                                context: context,
                                                builder: (ctx) {
                                                  return ChangeAddressRequest(
                                                    model: scheduleModel!
                                                        .schedule!,
                                                    type: 'Pickup',
                                                  );
                                                });
                                            if (result != null) {
                                              setState(() {
                                                loading = true;
                                              });
                                              getSchedule();
                                            }
                                          },
                                          child: Text(
                                            "Change Request",
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
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.location_on,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            scheduleModel!.booking![j]
                                                    .pickupAddress ??
                                                '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontSize: 12.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        UI.commonIconButton(
                                            onPressed: null,
                                            iconData: Icons.swap_calls,
                                            iconColor: Colors.green,
                                            message:
                                                "The address remains the same at start time, as indicated."),
                                        UI.commonIconButton(
                                            onPressed: null,
                                            iconData: Icons.swap_calls,
                                            iconColor: Colors.red,
                                            message:
                                                "The address is switched upon drop time, as specified."),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Drop Address",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16.0,
                                                ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            var result = await showDialog(
                                                context: context,
                                                builder: (ctx) {
                                                  return ChangeAddressRequest(
                                                    model: scheduleModel!
                                                        .schedule!,
                                                    type: 'Drop',
                                                  );
                                                });
                                            if (result != null) {
                                              setState(() {
                                                loading = true;
                                              });
                                              getSchedule();
                                            }
                                          },
                                          child: Text(
                                            "Change Request",
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
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            scheduleModel!
                                                    .booking![j].dropAddress ??
                                                '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontSize: 12.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: UI.commonButton(
                                              title:
                                                  "Pickup: ${formatTime(scheduleModel!.booking![j].pickupTime)}",
                                              fontColor: Colors.white,
                                              bgColor: Colors.green,
                                              borderColor: Colors.green,
                                              onPressed: null),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        scheduleModel!.booking![j].dropTime !=
                                                    null &&
                                                scheduleModel!
                                                        .booking![j].dropTime !=
                                                    ''
                                            ? Expanded(
                                                child: UI.commonButton(
                                                    title:
                                                        "Reaching: ${formatTime(scheduleModel!.booking![j].dropTime)}",
                                                    fontColor: Colors.white,
                                                    bgColor: Colors.red,
                                                    borderColor: Colors.red,
                                                    onPressed: null),
                                              )
                                            : SizedBox(),
                                        /*const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: UI.commonButton(
                                        title:
                                        "Return: ${formatTime(scheduleModel!.booking![j].re)}",
                                        fontColor: Colors.white,
                                        bgColor: Colors.red,
                                        borderColor: Colors.red,
                                        onPressed: null),
                                  ),*/
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Tooltip(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: MyColorName.mainColor,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          message:
                                              "Need to update the flight number? Just tap on it and make your adjustments.",
                                          child: TextButton(
                                            onPressed: () async {
                                              var result = await showDialog(
                                                  context: context,
                                                  builder: (ctx) {
                                                    return UpdateFlightNo(
                                                      model: scheduleModel!
                                                          .schedule!,
                                                    );
                                                  });
                                              if (result != null) {
                                                setState(() {
                                                  loading = true;
                                                });
                                                getSchedule();
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Flight No.:- ${scheduleModel!.schedule!.flightNo ?? ""}  ",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium!
                                                      .copyWith(
                                                        color: MyColorName
                                                            .mainColor,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        fontSize: 12.0,
                                                      ),
                                                ),
                                                Icon(
                                                  Icons.edit,
                                                  color: MyColorName.mainColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: MyColorName.mainColor,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          message:
                                              "Adjustments to pickup and drop-off times will take effect on the next ride.",
                                          child: TextButton(
                                            onPressed: () async {
                                              var result = await showDialog(
                                                  context: context,
                                                  builder: (ctx) {
                                                    return ChangeScheduleTime(
                                                      model: scheduleModel!
                                                          .booking![j],
                                                    );
                                                  });
                                              if (result != null) {
                                                setState(() {
                                                  loading = true;
                                                });
                                                getSchedule();
                                              }
                                            },
                                            child: Text(
                                              "Change Timing",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .copyWith(
                                                    color:
                                                        MyColorName.mainColor,
                                                    decoration: TextDecoration
                                                        .underline,
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
                              SizedBox(
                                height: 5,
                              )
                            ],
                          ),
                        );
                      }),
                ),
              ),

            // Container(
            //   height: 400,
            //   child: ListView.builder(
            //       itemCount: allScheduleModel?.bookings.length,
            //       itemBuilder: (context, i){
            //         return Card(
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12.0),
            //             side: BorderSide(color: MyColorName.secondColor),
            //           ),
            //           color: Colors.white,
            //           margin: EdgeInsets.all(10.0),
            //           child: Container(
            //             color: Colors.transparent,
            //             width: double.infinity,
            //             padding: const EdgeInsets.all(12.0),
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisSize: MainAxisSize.min,
            //               children: [
            //                 Text(
            //                   "Schedule Ride",
            //                   style: Theme.of(context).textTheme.headlineLarge!.copyWith(
            //                     color: MyColorName.mainColor,
            //                     fontWeight: FontWeight.w800,
            //                     fontSize: 16.0,
            //                   ),
            //                 ),
            //                 const SizedBox(
            //                   height: 10,
            //                 ),
            //                 Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Row(
            //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                       children: [
            //                         Expanded(
            //                           child: Text(
            //                             "Pickup Address",
            //                             style:
            //                             Theme.of(context).textTheme.labelMedium,
            //                           ),
            //                         ),
            //                         Tooltip(
            //                           margin: EdgeInsets.symmetric(horizontal: 20),
            //                           decoration: BoxDecoration(
            //                             color: MyColorName.mainColor,
            //                             borderRadius: BorderRadius.circular(5),
            //                           ),
            //                           message: "The pickup location at the pickup time and\nthe drop-off location at the dropping time.",
            //                           triggerMode: TooltipTriggerMode.tap,
            //                           child: Icon(
            //                             Icons.info_outlined,
            //                             color: MyColorName.mainColor,
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                     SizedBox(
            //                       height: 5,
            //                     ),
            //                     EntryField(
            //                       readOnly: true,
            //                       controller: pickupCon,
            //                       onTap: () async {
            //                         pickupCon.text = allScheduleModel?.bookings[i].pickupAddress ?? '';
            //                         // AddressModel? model = await callPickAddress();
            //                         // if (model != null) {
            //                         //   setState(() {
            //                         //     pickAddress = model;
            //                         //     pickupCon.text = allScheduleModel?.bookings[i].pickupAddress ?? '';
            //                         //   });
            //                         // }
            //                       },
            //                       suffixIcon: IconButton(
            //                         onPressed: null,
            //                         icon: Icon(
            //                           Icons.location_searching,
            //                         ),
            //                       ),
            //                       hint:"${allScheduleModel?.bookings[i].pickupAddress}",
            //                     ),
            //                     const SizedBox(
            //                       height: 10,
            //                     ),
            //                     Row(
            //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                       children: [
            //                         Expanded(
            //                           child: Text(
            //                             "Drop Address",
            //                             style:
            //                             Theme.of(context).textTheme.labelMedium,
            //                           ),
            //                         ),
            //                         Tooltip(
            //                           margin: EdgeInsets.symmetric(horizontal: 20),
            //                           decoration: BoxDecoration(
            //                             color: MyColorName.mainColor,
            //                             borderRadius: BorderRadius.circular(5),
            //                           ),
            //                           message:
            //                           "The drop location at the pickup time and\nthe pickup location at the dropping time.",
            //                           triggerMode: TooltipTriggerMode.tap,
            //                           child: Icon(
            //                             Icons.info_outlined,
            //                             color: MyColorName.mainColor,
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                     SizedBox(
            //                       height: 5,
            //                     ),
            //                     EntryField(
            //                       readOnly: true,
            //                       controller: dropCon,
            //                       onTap: () async {
            //                         AddressModel? model = await callPickAddress();
            //                         if (model != null) {
            //                           setState(() {
            //                             dropAddress = model;
            //                             dropCon.text = allScheduleModel?.bookings[i].dropAddress ?? '';
            //                           });
            //                         }
            //                       },
            //                       suffixIcon: IconButton(
            //                         onPressed: null,
            //                         icon: Icon(
            //                           Icons.location_searching,
            //                         ),
            //                       ),
            //                       hint: "${allScheduleModel?.bookings[i].dropAddress}",
            //                     ),
            //                     const SizedBox(
            //                       height: 10,
            //                     ),
            //                     Row(
            //                       children: [
            //                         Expanded(
            //                           child: EntryField(
            //                             readOnly: true,
            //                             controller: pickupTimeCon,
            //                             onTap: () async {
            //                               TimeOfDay? date = await selectTime(context);
            //                               if (date != null) {
            //                                 setState(() {
            //                                   pickTime = DateFormat("HH:mm").format(
            //                                       DateTime(
            //                                           DateTime.now().year,
            //                                           DateTime.now().month,
            //                                           DateTime.now().day,
            //                                           date.hour,
            //                                           date.minute));
            //                                   pickupTimeCon.text =
            //                                       DateFormat("hh:mm a").format(
            //                                           DateTime(
            //                                               DateTime.now().year,
            //                                               DateTime.now().month,
            //                                               DateTime.now().day,
            //                                               date.hour,
            //                                               date.minute),
            //                                       );
            //                                 });
            //                               }
            //                             },
            //                             suffixIcon: IconButton(
            //                               onPressed: null,
            //                               icon: Icon(
            //                                 Icons.watch_later_outlined,
            //                               ),
            //                             ),
            //                             hint: "${allScheduleModel?.bookings[i].pickupTime}",
            //                           ),
            //                         ),
            //                         SizedBox(
            //                           height: 10,
            //                         ),
            //                         Expanded(
            //                           child: EntryField(
            //                             readOnly: true,
            //                             controller: reachTimeCon,
            //                             onTap: () async {
            //                               TimeOfDay? date = await selectTime(context);
            //                               if (date != null) {
            //                                 setState(() {
            //                                   dropTime = DateFormat("HH:mm").format(
            //                                       DateTime(
            //                                           DateTime.now().year,
            //                                           DateTime.now().month,
            //                                           DateTime.now().day,
            //                                           date.hour,
            //                                           date.minute));
            //                                   reachTimeCon.text = DateFormat("hh:mm a")
            //                                       .format(DateTime(
            //                                       DateTime.now().year,
            //                                       DateTime.now().month,
            //                                       DateTime.now().day,
            //                                       date.hour,
            //                                       date.minute));
            //                                 });
            //                               }
            //                             },
            //                             suffixIcon: IconButton(
            //                               onPressed: null,
            //                               icon: Icon(
            //                                 Icons.watch_later_outlined,
            //                               ),
            //                             ),
            //                             hint: "${allScheduleModel?.bookings[i].pickupTime}",
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                     EntryField(
            //                       readOnly: true,
            //                       controller: returnTimeCon,
            //                       onTap: () async {
            //                         TimeOfDay? date = await selectTime(context);
            //                         if (date != null) {
            //                           setState(() {
            //                             reachTime = DateFormat("HH:mm").format(
            //                               DateTime(
            //                                   DateTime.now().year,
            //                                   DateTime.now().month,
            //                                   DateTime.now().day,
            //                                   date.hour,
            //                                   date.minute),
            //                             );
            //                             returnTimeCon.text = DateFormat("hh:mm a")
            //                                 .format(DateTime(
            //                                 DateTime.now().year,
            //                                 DateTime.now().month,
            //                                 DateTime.now().day,
            //                                 date.hour,
            //                                 date.minute));
            //                           });
            //                         }
            //                       },
            //                       suffixIcon: IconButton(
            //                         onPressed: null,
            //                         icon: Icon(
            //                           Icons.watch_later_outlined,
            //                         ),
            //                       ),
            //                       hint: "Return Time",
            //                     ),
            //                     const SizedBox(height: 5,),
            //                     Text("This time is scheduled for daily rides, and you can adjust it later or for a one-time change.",
            //                         style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.red)),
            //                     const SizedBox(
            //                       height: 10,
            //                     ),
            //                     EntryField(
            //                       controller: flightCon,
            //                       suffixIcon: IconButton(
            //                         onPressed: null,
            //                         icon: Icon(
            //                           Icons.flight,
            //                         ),
            //                       ),
            //                       hint:"${allScheduleModel?.data?.flightNo}",
            //                     ),
            //                     SizedBox(height: 10,),
            //                     if (rideStartCon.text != "")
            //                       Text(
            //                         "Rides Start Date - ${DateFormat("dd MMM yyyy").format(DateTime.parse(rideStartCon.text))}",
            //                         style: Theme.of(context)
            //                             .textTheme
            //                             .headlineLarge!
            //                             .copyWith(
            //                           color: MyColorName.mainColor,
            //                           fontWeight: FontWeight.w800,
            //                           fontSize: 16.0,
            //                         ),
            //                       ),
            //                     const SizedBox(
            //                       height: 10,
            //                     ),
            //                     Row(
            //                       children: [
            //                         Tooltip(
            //                           margin: EdgeInsets.symmetric(horizontal: 20),
            //                           decoration: BoxDecoration(
            //                             color: MyColorName.mainColor,
            //                             borderRadius: BorderRadius.circular(5),
            //                           ),
            //                           message: "Select Rides Start Date",
            //                           triggerMode: TooltipTriggerMode.longPress,
            //                           child: Container(
            //                             decoration: BoxDecoration(
            //                                 color: MyColorName.mainColor,
            //                                 borderRadius: BorderRadius.circular(5)),
            //                             child: IconButton(
            //                               onPressed: () async {
            //                                 DateTime? date = await selectDate(context);
            //                                 if (date != null) {
            //                                   setState(() {
            //                                     // rideStartCon.text = DateFormat("yyyy-MM-dd").format(date);
            //                                     rideStartCon.text = allScheduleModel!.bookings[i].pickupDate.toString();
            //                                   });
            //                                 }
            //                               },
            //                               padding: EdgeInsets.all(1.0),
            //                               visualDensity: VisualDensity.standard,
            //                               icon: Icon(
            //                                 Icons.calendar_today,
            //                                 color: Colors.white,
            //                               ),
            //                             ),
            //                           ),
            //                         ),
            //                         const SizedBox(
            //                           width: 5,
            //                         ),
            //                         Expanded(
            //                           child: UI.commonButton(
            //                               title: "Edit Schedule",
            //                               loading: loadingSchedule,
            //                               onPressed: () {
            //                                 if (pickupCon.text == "") {
            //                                   UI.setSnackBar(
            //                                       "Please Select Pickup Address",
            //                                       context);
            //                                   return;
            //                                 }
            //                                 if (dropCon.text == "") {
            //                                   UI.setSnackBar(
            //                                       "Please Select Drop Address", context);
            //                                   return;
            //                                 }
            //                                 if (pickupTimeCon.text == "") {
            //                                   UI.setSnackBar(
            //                                       "Please Select Pickup Time", context);
            //                                   return;
            //                                 }
            //                                 // if (dropTimeCon.text == "") {
            //                                 //   UI.setSnackBar(
            //                                 //       "Please Select Drop-off Time", context);
            //                                 //   return;
            //                                 // }
            //                                 if (rideStartCon.text == "") {
            //                                   UI.setSnackBar(
            //                                       "Please Select Rides Start Time",
            //                                       context);
            //                                   return;
            //                                 }
            //                                 if (flightCon.text == "") {
            //                                   UI.setSnackBar(
            //                                       "Please Enter Flight No.",
            //                                       context);
            //                                   return;
            //                                 }
            //                                 setState(() {
            //                                   loadingSchedule = true;
            //                                 });
            //                                 scheduleRide();
            //                               }),
            //                         ),
            //                       ],
            //                     ),
            //                   ],
            //                 ),
            //               ],
            //             ),
            //           ),
            //         );
            //       }),
            // ),
            if (loading) CircularProgressIndicator(),
          ],
        ),
        bottomNavigationBar: isVisible &&
                scheduleModel != null &&
                scheduleModel!.booking!.isNotEmpty
            ? Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Your Next Ride",
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
                    scheduleModel!.booking == null ||
                            scheduleModel!.booking!.isEmpty
                        ? Container()
                        : BookingView(model: scheduleModel!.booking!.first),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Tooltip(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: MyColorName.mainColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          message: "Live Tracking.",
                          child: TextButton(
                            onPressed: () async {
                              var data = await Navigator.pushNamed(
                                  context, Constants.rideInfoRoute,
                                  arguments: scheduleModel!.booking);
                              if (data != null) {
                                setState(() {
                                  loading = true;
                                });
                                getSchedule();
                              }
                            },
                            child: Text(
                              "Live Track",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                    color: MyColorName.mainColor,
                                    decoration: TextDecoration.underline,
                                    fontSize: 12.0,
                                  ),
                            ),
                          ),
                        ),
                        Tooltip(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: MyColorName.mainColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          message: "Change request for reaching time.",
                          child: TextButton(
                            onPressed: () async {
                              var result = await showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return NoteRideScreen(
                                      model: scheduleModel!.booking ?? [],
                                    );
                                  });
                              if (result != null) {
                                setState(() {
                                  loading = true;
                                });
                                getSchedule();
                              }
                            },
                            child: Text(
                              "Note",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                    color: MyColorName.mainColor,
                                    decoration: TextDecoration.underline,
                                    fontSize: 12.0,
                                  ),
                            ),
                          ),
                        ),
                        Tooltip(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: MyColorName.mainColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          message: "Cancel Ride.",
                          child: TextButton(
                            onPressed: () async {
                              var result = await showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return CancelRideScreen(
                                      model: scheduleModel!.booking!,
                                    );
                                  });
                              if (result != null) {
                                setState(() {
                                  loading = true;
                                });
                                getSchedule();
                              }
                            },
                            child: Text(
                              "Cancel Ride",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                    color: MyColorName.mainColor,
                                    decoration: TextDecoration.underline,
                                    fontSize: 12.0,
                                  ),
                            ),
                          ),
                        ),
                        if (scheduleModel!.booking != null &&
                            scheduleModel!.booking!.isNotEmpty &&
                            enableButton(
                                scheduleModel!.booking!.first.pickupTime))
                          scheduleModel!.booking == null ||
                                  scheduleModel!.booking!.isEmpty
                              ? Container()
                              : Tooltip(
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: MyColorName.mainColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  message:
                                      "Until 2 hours before the pickup, you can make changes to the timing.",
                                  child: TextButton(
                                    onPressed: () async {
                                      if (scheduleModel!.booking != null &&
                                          scheduleModel!.booking!.isNotEmpty &&
                                          enableButton(scheduleModel!
                                              .booking!.first.pickupTime)) {
                                        var result = await showDialog(
                                            context: context,
                                            builder: (ctx) {
                                              return ChangeRideTime(
                                                model: scheduleModel!.booking!,
                                              );
                                            });
                                        if (result != null) {
                                          setState(() {
                                            loading = true;
                                          });
                                          getSchedule();
                                        }
                                      } else {
                                        UI.setSnackBar(
                                            "Until 2 hours before the pickup, you can make changes to the timing.",
                                            context);
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
              )
            : null,
      ),
    );
  }

  bool enableButton(String? time) {
    if (time == null) {
      return true;
    }
    if (!time.contains(":")) {
      return true;
    }
    List<String> formatTime = time.split(":");
    DateTime firstTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, int.parse(formatTime[0]), int.parse(formatTime[1]));
    DateTime secondTime = DateTime.now();
    Common.debugPrintApp(firstTime.difference(secondTime).inMinutes);
    return firstTime.difference(secondTime).inMinutes > 120;
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

  int selectedIndex = 0;
  Future<AddressModel?> callPickAddress() async {
    var result = await Navigator.pushNamed(
        context, Constants.manageAddressRoute,
        arguments: true);
    return result as AddressModel;
  }

  Future<DateTime?> selectDate(BuildContext context,
      {DateTime? startDate}) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2050),
        keyboardType: TextInputType.none,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        builder: (BuildContext? context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: MyColorName.primaryLite,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        });

    return picked;
  }

  /// Ankush Time type change
  Future<TimeOfDay?> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.inputOnly,
        builder: (BuildContext? context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
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
          );
        });
    return picked;
  }

  bool loadingSchedule = false, network = false;
  ScheduleModel? scheduleModel;

  Future getSchedule() async {
    network = await Common.checkInternet();
    if (network) {
      Map param = {
        'user_id': Constants.curUserId,
      };
      print("get schedule ${param}");
      Map response = await apiBase.postAPICall(
          Uri.parse("${Constants.baseUrl}Authentication/get_schedule"), param);
      setState(() {
        loading = false;
      });
      if (response['status'] && response['data'] != null) {
        scheduleModel = ScheduleModel.fromJson(response['data']);
        convertDateTimeDispla();
      } else {
        // UI.setSnackBar(response['message'] ?? 'Something went wrong', context);
      }
    } else {
      UI.setSnackBar("No Internet Connection", context);
    }
  }

  TextEditingController pickupCon = TextEditingController();
  TextEditingController dropCon = TextEditingController();
  TextEditingController flightCon = TextEditingController();
  TextEditingController pickupTimeCon = TextEditingController();
  TextEditingController reachTimeCon = TextEditingController();
  TextEditingController returnTimeCon = TextEditingController();
  TextEditingController rideStartCon = TextEditingController();

  List<TextEditingController> pickupConList = [];
  List<TextEditingController> dropConList = [];
  List<TextEditingController> flightConList = [];
  List<TextEditingController> pickupTimeConList = [];
  List<TextEditingController> reachTimeConList = [];
  //List<TextEditingController> returnTimeConList = [];
  List<TextEditingController> rideStartConList = [];

  String pickTime = "", dropTime = "", reachTime = "";

  AllScheduleModel? allScheduleModel;

  Future scheduleRide() async {
    network = await Common.checkInternet();
    if (network) {
      Map param = {
        'user_id': Constants.curUserId,
        'pickup_address': pickAddress!.id ?? '',
        'drop_address': dropAddress!.id ?? '',
        'pickup_time': pickTime.toString(),
        'drop_time': dropTime.toString(),
        'flight_no': flightCon.text.toString(),
        'start_date': rideStartCon.text.toString(),
        // 'days': '${selectDays.toString()}',
        'reaching_time': '${reachTime.toString()}',
      };
      print("schedule ride ${param}");
      var response = await apiBase.postAPICall(
          Uri.parse("${Constants.baseUrl}Authentication/create_schedule"),
          param);
      setState(() {
        loadingSchedule = false;
      });
      pickupConList = [];
      dropConList = [];
      flightConList = [];
      pickupTimeConList = [];
      reachTimeConList = [];
      // returnTimeConList = [];
      rideStartConList = [];

      if (response['status']) {
        allScheduleModel = AllScheduleModel.fromJson(response);

        for (int? i = 0; i! < allScheduleModel!.bookings.length; i++) {
          pickupConList.add(TextEditingController());
          dropConList.add(TextEditingController());
          flightConList.add(TextEditingController());
          pickupTimeConList.add(TextEditingController());
          reachTimeConList.add(TextEditingController());
          // returnTimeConList.add(TextEditingController());
          rideStartConList.add(TextEditingController());

          pickupConList[i].text =
              allScheduleModel?.bookings[i].pickupAddress ?? "";
          dropConList[i].text = allScheduleModel?.bookings[i].dropAddress ?? "";
          pickupTimeConList[i].text =
              allScheduleModel?.bookings[i].pickupTime ?? "";

          if (allScheduleModel?.bookings[i].reachTime == null ||
              allScheduleModel?.bookings[i].reachTime == 'null') {
            reachTimeConList[i].text = '';
          } else {
            reachTimeConList[i].text =
                allScheduleModel?.bookings[i].reachTime ?? "";
          }

          print('${reachTimeConList[i].text}______reachTime');

          flightConList[i].text = allScheduleModel?.data?.flightNo ?? "";
          rideStartConList[i].text =
              allScheduleModel?.bookings[i].pickupDate.toString() ?? "";
          //returnTimeConList[i].text = allScheduleModel!.bookings[i].pickupTime ?? "";
        }
        pickupCon.clear();
        dropCon.clear();
        pickupTimeCon.clear();
        reachTimeCon.clear();
        returnTimeCon.clear();
        flightCon.clear();
        rideStartCon.clear();
        dropTime = '';
        //getSchedule();
        UI.setSnackBar(response['message'], context, color: Colors.green);
      } else {
        UI.setSnackBar(response['message'] ?? 'Something went wrong', context);
      }
    } else {
      UI.setSnackBar("No Internet Connection", context);
    }
  }

  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  bool loadingWeek = false;

  Future updateRideTime(String? id, String? pickTime, String? date) async {
    network = await Common.checkInternet();
    if (network) {
      Map param = {
        'booking_id': id.toString(),
        'pickup_time': pickTime,
        'pickup_date': date
      };
      print("update time ${param}");
      Map response = await apiBaseHelper.postAPICall(
          Uri.parse("${Constants.baseUrl}Authentication/update_booking_time"),
          param);
      setState(() {
        loadingWeek = false;
      });
      if (response['status']) {
        scheduleRide();
        // Navigator.pop(context,true);
        UI.setSnackBar(response['message'], context, color: Colors.green);
      } else {
        UI.setSnackBar(response['message'] ?? 'Something went wrong', context);
      }
    } else {
      UI.setSnackBar("No Internet Connection", context);
    }
  }

  Widget allschedule() {
    return Container(
      height: 530,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
          //shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: allScheduleModel?.bookings.length ?? 0,
          itemBuilder: (context, i) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(color: MyColorName.secondColor),
              ),
              color: Colors.white,
              margin: EdgeInsets.all(10.0),
              child: Container(
                //height: 500,
                color: Colors.transparent,
                width: MediaQuery.of(context).size.width / 1.2,
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text(
                    //   "Schedule Ride",
                    //   style:
                    //       Theme.of(context).textTheme.headlineLarge!.copyWith(
                    //             color: MyColorName.mainColor,
                    //             fontWeight: FontWeight.w800,
                    //             fontSize: 16.0,
                    //           ),
                    // ),
                    // const SizedBox(
                    //   height: 12,
                    // ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Pickup Address",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                            Tooltip(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: MyColorName.mainColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              message:
                                  "The pickup location at the pickup time and\nthe drop-off location at the dropping time.",
                              triggerMode: TooltipTriggerMode.tap,
                              child: Icon(
                                Icons.info_outlined,
                                color: MyColorName.mainColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        EntryField(
                          readOnly: true,
                          controller: pickupConList[i],
                          onTap: () async {
                            /*AddressModel? model = await callPickAddress();
                            if (model != null) {
                              setState(() {
                              //  pickAddress = model;
                                pickupConList[i].text = model.address ?? '';//allScheduleModel?.bookings[i].pickupAddress ??'';
                              });
                            }*/
                          },
                          suffixIcon: IconButton(
                            onPressed: null,
                            icon: Icon(
                              Icons.location_searching,
                            ),
                          ),
                          hint:
                              "${allScheduleModel?.bookings[i].pickupAddress}",
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Drop Address",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                            Tooltip(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: MyColorName.mainColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              message:
                                  "The drop location at the pickup time and\nthe pickup location at the dropping time.",
                              triggerMode: TooltipTriggerMode.tap,
                              child: Icon(
                                Icons.info_outlined,
                                color: MyColorName.mainColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        EntryField(
                          readOnly: true,
                          controller: dropConList[i],
                          onTap: () async {
                            /*AddressModel? model = await callPickAddress();
                            if (model != null) {
                              setState(() {
                                //dropAddress = model;
                                dropConList[i].text = model.address ?? '';
                                   */ /* allScheduleModel?.bookings[i].dropAddress ??
                                        '';*/ /*
                              });
                            }*/
                          },
                          suffixIcon: IconButton(
                            onPressed: null,
                            icon: Icon(
                              Icons.location_searching,
                            ),
                          ),
                          hint: "${allScheduleModel?.bookings[i].dropAddress}",
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: EntryField(
                                readOnly: true,
                                controller: pickupTimeConList[i],
                                onTap: () async {
                                  bool isEnable =
                                      enableButton(pickupTimeConList[i].text);

                                  if (isEnable) {
                                    TimeOfDay? date = await selectTime(context);
                                    if (date != null) {
                                      setState(() {
                                        pickTime = DateFormat("HH:mm").format(
                                            DateTime(
                                                DateTime.now().year,
                                                DateTime.now().month,
                                                DateTime.now().day,
                                                date.hour,
                                                date.minute));
                                        pickupTimeConList[i].text =
                                            DateFormat("hh:mm a").format(
                                                DateTime(
                                                    DateTime.now().year,
                                                    DateTime.now().month,
                                                    DateTime.now().day,
                                                    date.hour,
                                                    date.minute));
                                      });
                                    }
                                  } else {
                                    UI.setSnackBar(
                                        "Until 2 hours before the pickup, you can make changes to the timing.",
                                        context);
                                  }
                                },
                                suffixIcon: IconButton(
                                  onPressed: null,
                                  icon: Icon(
                                    Icons.watch_later_outlined,
                                  ),
                                ),
                                hint:
                                    "${allScheduleModel?.bookings[i].pickupTime}",
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            reachTimeConList[i].text == ''
                                ? SizedBox()
                                : Expanded(
                                    child: EntryField(
                                      readOnly: true,
                                      controller: reachTimeConList[i],
                                      // onTap: () async {
                                      //   TimeOfDay? date = await selectTime(context);
                                      //   if (date != null) {
                                      //     setState(() {
                                      //       dropTime = DateFormat("HH:mm").format(
                                      //           DateTime(
                                      //               DateTime.now().year,
                                      //               DateTime.now().month,
                                      //               DateTime.now().day,
                                      //               date.hour,
                                      //               date.minute));
                                      //       reachTimeCon.text = DateFormat("hh:mm a")
                                      //           .format(DateTime(
                                      //               DateTime.now().year,
                                      //               DateTime.now().month,
                                      //               DateTime.now().day,
                                      //               date.hour,
                                      //               date.minute));
                                      //     });
                                      //   }
                                      // },
                                      suffixIcon: IconButton(
                                        onPressed: null,
                                        icon: Icon(
                                          Icons.watch_later_outlined,
                                        ),
                                      ),
                                      hint: "Reaching Time",
                                    ),
                                  ),
                          ],
                        ),
                        // EntryField(
                        //   readOnly: true,
                        //   controller: returnTimeCon,
                        //   onTap: () async {
                        //     TimeOfDay? date = await selectTime(context);
                        //     if (date != null) {
                        //       setState(() {
                        //         reachTime = DateFormat("HH:mm").format(
                        //           DateTime(
                        //               DateTime.now().year,
                        //               DateTime.now().month,
                        //               DateTime.now().day,
                        //               date.hour,
                        //               date.minute),
                        //         );
                        //         returnTimeCon.text = DateFormat("hh:mm a")
                        //             .format(DateTime(
                        //                 DateTime.now().year,
                        //                 DateTime.now().month,
                        //                 DateTime.now().day,
                        //                 date.hour,
                        //                 date.minute));
                        //       });
                        //     }
                        //   },
                        //   suffixIcon: IconButton(
                        //     onPressed: null,
                        //     icon: Icon(
                        //       Icons.watch_later_outlined,
                        //     ),
                        //   ),
                        //   hint: "Return Time",
                        // ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                            "This time is scheduled for daily rides, and you can adjust it later or for a one-time change.",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(color: Colors.red)),
                        const SizedBox(
                          height: 12,
                        ),
                        EntryField(
                          readOnly: true,
                          controller: flightConList[i],
                          suffixIcon: IconButton(
                            onPressed: null,
                            icon: Icon(
                              Icons.flight,
                            ),
                          ),
                          hint: "${allScheduleModel?.data?.flightNo}",
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (rideStartConList[i].text != "")
                          Text(
                            /*"Rides Start Date " + rideStartConList[i].text ,*/ "Rides Start Date - ${DateFormat("dd MMM yyyy").format(DateTime.parse(rideStartConList[i].text))}",
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .copyWith(
                                  color: MyColorName.mainColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16.0,
                                ),
                          ),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          children: [
                            Tooltip(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: MyColorName.mainColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              message: "Select Rides Start Date",
                              triggerMode: TooltipTriggerMode.longPress,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: MyColorName.mainColor,
                                    borderRadius: BorderRadius.circular(5)),
                                child: IconButton(
                                  onPressed: () async {
                                    DateTime? date = await selectDate(context);
                                    if (date != null) {
                                      setState(() {
                                        rideStartConList[i].text =
                                            DateFormat("yyyy-MM-dd")
                                                .format(date);
                                        //rideStartConList[i].text = allScheduleModel!.bookings[i].pickupDate.toString();
                                      });
                                    }
                                  },
                                  padding: EdgeInsets.all(1.0),
                                  visualDensity: VisualDensity.standard,
                                  icon: Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: UI.commonButton(
                                  title: "Edit Schedule Ride",
                                  loading: loadingSchedule,
                                  onPressed: () {
                                    if (rideStartConList[i].text == "") {
                                      UI.setSnackBar(
                                          "Please Select Rides Start Time",
                                          context);
                                      return;
                                    }
                                    setState(() {
                                      loadingSchedule = true;
                                    });
                                    updateRideTime(
                                        allScheduleModel!.bookings[i].id
                                            .toString(),
                                        pickupTimeConList[i].text,
                                        rideStartConList[i].text);
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget mycardshow() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: MyColorName.secondColor),
      ),
      color: Colors.white,
      margin: EdgeInsets.all(10.0),
      child: Container(
        height: MediaQuery.of(context).size.height / 1.4,
        color: Colors.transparent,
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              allScheduleModel != null &&
                      (allScheduleModel?.bookings.isNotEmpty ?? false)
                  ? allschedule()
                  : SizedBox(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Create Schedule Ride",
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                          color: MyColorName.mainColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16.0,
                        ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Pickup Address",
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                          Tooltip(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: MyColorName.mainColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            message:
                                "The pickup location at the pickup time and\nthe drop-off location at the dropping time.",
                            triggerMode: TooltipTriggerMode.tap,
                            child: Icon(
                              Icons.info_outlined,
                              color: MyColorName.mainColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
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
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Drop Address",
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                          Tooltip(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: MyColorName.mainColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            message:
                                "The drop location at the pickup time and\nthe pickup location at the dropping time.",
                            triggerMode: TooltipTriggerMode.tap,
                            child: Icon(
                              Icons.info_outlined,
                              color: MyColorName.mainColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      EntryField(
                        readOnly: true,
                        controller: dropCon,
                        onTap: () async {
                          AddressModel? model = await callPickAddress();
                          if (model != null) {
                            setState(() {
                              dropAddress = model;
                              dropCon.text = dropAddress!.address ?? '';
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
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: EntryField(
                              readOnly: true,
                              controller: pickupTimeCon,
                              onTap: () async {
                                TimeOfDay? date = await selectTime(context);
                                if (date != null) {
                                  setState(() {
                                    pickTime = DateFormat("HH:mm").format(
                                        DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                            date.hour,
                                            date.minute));
                                    pickupTimeCon.text =
                                        DateFormat("hh:mm a").format(
                                      DateTime(
                                          DateTime.now().year,
                                          DateTime.now().month,
                                          DateTime.now().day,
                                          date.hour,
                                          date.minute),
                                    );
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
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Expanded(
                            child: EntryField(
                              readOnly: true,
                              controller: reachTimeCon,
                              onTap: () async {
                                TimeOfDay? date = await selectTime(context);
                                if (date != null) {
                                  setState(() {
                                    reachTime = DateFormat("HH:mm").format(
                                        DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                            date.hour,
                                            date.minute));
                                    reachTimeCon.text = DateFormat("hh:mm a")
                                        .format(DateTime(
                                            DateTime.now().year,
                                            DateTime.now().month,
                                            DateTime.now().day,
                                            date.hour,
                                            date.minute));
                                  });
                                }
                              },
                              suffixIcon: IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.watch_later_outlined,
                                ),
                              ),
                              hint: "Reaching Time",
                            ),
                          ),
                        ],
                      ),
                      EntryField(
                        readOnly: true,
                        controller: returnTimeCon,
                        onTap: () async {
                          TimeOfDay? date = await selectTime(context);
                          if (date != null) {
                            setState(() {
                              dropTime = DateFormat("HH:mm").format(
                                DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                    date.hour,
                                    date.minute),
                              );
                              returnTimeCon.text = DateFormat("hh:mm a").format(
                                  DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                      date.hour,
                                      date.minute));
                            });
                          }
                        },
                        suffixIcon: IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.watch_later_outlined,
                          ),
                        ),
                        hint: "End Time",
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                          "This time is scheduled for daily rides, and you can adjust it later or for a one-time change.",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(color: Colors.red)),
                      const SizedBox(
                        height: 12,
                      ),
                      EntryField(
                        controller: flightCon,
                        suffixIcon: IconButton(
                          onPressed: null,
                          icon: Icon(
                            Icons.flight,
                          ),
                        ),
                        hint: "Enter Flight No.",
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      if (rideStartCon.text != "")
                        Text(
                          "Rides Start Date - ${DateFormat("dd MMM yyyy").format(DateTime.parse(rideStartCon.text))}",
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(
                                color: MyColorName.mainColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 16.0,
                              ),
                        ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          Tooltip(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: MyColorName.mainColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            message: "Select Rides Start Date",
                            triggerMode: TooltipTriggerMode.longPress,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: MyColorName.mainColor,
                                  borderRadius: BorderRadius.circular(5)),
                              child: IconButton(
                                onPressed: () async {
                                  DateTime? date = await selectDate(context);
                                  if (date != null) {
                                    setState(() {
                                      rideStartCon.text =
                                          DateFormat("yyyy-MM-dd").format(date);
                                    });
                                  }
                                },
                                padding: EdgeInsets.all(1.0),
                                visualDensity: VisualDensity.standard,
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: UI.commonButton(
                                title: "Schedule",
                                loading: loadingSchedule,
                                onPressed: () {
                                  if (pickupCon.text == "") {
                                    UI.setSnackBar(
                                        "Please Select Pickup Address",
                                        context);
                                    return;
                                  }
                                  if (dropCon.text == "") {
                                    UI.setSnackBar(
                                        "Please Select Drop Address", context);
                                    return;
                                  }
                                  if (pickupTimeCon.text == "") {
                                    UI.setSnackBar(
                                        "Please Select Start Time", context);
                                    return;
                                  }
                                  // if (dropTimeCon.text == "") {
                                  //   UI.setSnackBar(
                                  //       "Please Select Drop-off Time", context);
                                  //   return;
                                  // }
                                  if (rideStartCon.text == "") {
                                    UI.setSnackBar(
                                        "Please Select Rides Start date",
                                        context);
                                    return;
                                  }
                                  if (flightCon.text == "") {
                                    UI.setSnackBar(
                                        "Please Enter Flight No.", context);
                                    return;
                                  }
                                  setState(() {
                                    loadingSchedule = true;
                                  });
                                  scheduleRide();
                                }),
                          ),
                          SizedBox(width: 10),
                          allScheduleModel?.data?.id != null
                              ? Expanded(
                                  child: UI.commonButton(
                                      title: "Complete",
                                      // loading: loadingSchedule,
                                      onPressed: () {
                                        // if (pickupCon.text == "" || dropCon.text == "" || pickupTimeCon.text == "" || flightCon.text == "") {
                                        //   UI.setSnackBar("Please Create Any One Schedule", context);
                                        //   return;
                                        // }
                                        // setState(() {
                                        //   loadingSchedule = true;
                                        // });
                                        allScheduleModel?.data?.id = null;
                                        allScheduleModel!.bookings = [];
                                        getSchedule();
                                      }),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
