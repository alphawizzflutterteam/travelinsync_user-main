import 'package:flutter/material.dart';
import 'package:taxi_schedule_user/new_model/address_model.dart';
import 'package:taxi_schedule_user/new_model/schedule_model.dart';
import 'package:taxi_schedule_user/new_screen/add_address_screen.dart';


import 'package:taxi_schedule_user/new_screen/dashboard_screen.dart';
import 'package:taxi_schedule_user/new_screen/faq_page.dart';
import 'package:taxi_schedule_user/new_screen/login_screen.dart';
import 'package:taxi_schedule_user/new_screen/manage_address_screen.dart';
import 'package:taxi_schedule_user/new_screen/notification_list.dart';
import 'package:taxi_schedule_user/new_screen/plan_screen.dart';
import 'package:taxi_schedule_user/new_screen/privacy_policy.dart';
import 'package:taxi_schedule_user/new_screen/profile_page.dart';
import 'package:taxi_schedule_user/new_screen/ride_history_screen.dart';
import 'package:taxi_schedule_user/new_screen/splash_screen.dart';
import 'package:taxi_schedule_user/new_screen/terms.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';

import '../new_screen/ride_info_screen.dart';








Route<dynamic> generateRoute(RouteSettings settings) {
  Common.debugPrintApp("routs${settings.name}");

  switch (settings.name) {

    // case Constants.profileRoute:
    //    List param = ["",""];
    //   if(settings.arguments!=null){
    //     param = settings.arguments as List;
    //   }
    //   return MaterialPageRoute(builder: (context) => ProfileScreen(userId: param[0],type: param[1],),settings: settings);
    case Constants.profileRoute:
      return MaterialPageRoute(builder: (context) =>const ProfilePage(),settings: settings);
    case Constants.planRoute:
      return MaterialPageRoute(builder: (context) =>const PlanScreen(),settings: settings);
    case Constants.rideHistoryRoute:
      return MaterialPageRoute(builder: (context) =>const RideHistoryScreen(),settings: settings);
    case Constants.rideInfoRoute:
      if(settings.arguments!=null){
        // Booking  model = settings.arguments as Booking;
        List <Booking>  model = settings.arguments as  List <Booking>;
        return MaterialPageRoute(builder: (context) => RideInfoScreen( model: model),settings: settings);
      }else{
        return MaterialPageRoute(builder: (context) => SizedBox(),settings: settings);
      }

    case Constants.manageAddressRoute:
      bool selected = false;
      if(settings.arguments!=null){
        selected = settings.arguments as bool;
      }
      return MaterialPageRoute(builder: (context) => ManageAddress(selected: selected,),settings: settings);
    case Constants.addAddressRoute:
      if(settings.arguments!=null){
        AddressModel addressModel = settings.arguments as AddressModel;
        return MaterialPageRoute(builder: (context) => AddAddress(addressModel: addressModel,),settings: settings,);
      }else{
        return MaterialPageRoute(builder: (context) =>const AddAddress(),settings: settings);
      }

    case Constants.termsRoute:
      return MaterialPageRoute(builder: (context) =>const Terms(),settings: settings);
    case Constants.privacyRoute:
      return MaterialPageRoute(builder: (context) =>const PrivacyPolicy(),settings: settings);
    case Constants.faqRoute:
      return MaterialPageRoute(builder: (context) =>const FaqPage(),settings: settings);
    case Constants.notificationRoute:
      return MaterialPageRoute(builder: (context) =>const NotificationScreen(),settings: settings);
    case Constants.dashboardRoute:
      return MaterialPageRoute(builder: (context) =>const DashBoardScreen(),settings: settings);
    // case Constants.homeRoute:
    //   return MaterialPageRoute(builder: (context) =>const HomeScreen(),settings: settings);
    case Constants.loginRoute:
      return MaterialPageRoute(builder: (context) =>const LoginScreen(),settings: settings);
    case Constants.splashRoute:
      return MaterialPageRoute(builder: (context) =>const SplashScreen(),settings: settings);
    default:
      return MaterialPageRoute(builder: (context) => const SplashScreen(),settings: settings);

  }
}

