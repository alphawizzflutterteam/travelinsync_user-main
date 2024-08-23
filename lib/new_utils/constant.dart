import 'package:taxi_schedule_user/new_model/user_model.dart';

class Constants {
  static const appName = "TravelinSync";
  static String userName = "Guest";
  static UserModel? userModel;
  static String userProfile = "";
  static String? curUserId;
  static double latitude = 0;
  static double longitude = 0;
  static const String rupeesSymbol = '₹';
  static const splashRoute = "/splash";
  static const loginRoute = "/login";
  static const profileRoute = "/profile";
  static const planRoute = "/plan";
  static const manageAddressRoute = "/manage-address";
  static const rideInfoRoute = "/ride-info";
  static const rideHistoryRoute = "/ride-history";
  static const addAddressRoute = "/add-manage-address";
  static const privacyRoute = "/privacy";
  static const termsRoute = "/terms";
  static const faqRoute = "/faq";
  static const notificationRoute = "/notification";
  static const dashboardRoute = "/dashboard";
  static const homeRoute = "/home";
  // static const baseUrl = "https://developmentalphawizz.com/travel_in_sync/api/";
  static const baseUrl = "https://cozylimos.com/api/";
  static String imageBaseUrl = "https://cozylimos.com/api/";
  // static String imageBaseUrl = "https://developmentalphawizz.com/travel_in_sync/api/";
  static String imageUrl = "${imageBaseUrl}uploads/";
}

double latitude = 0;
double longitude = 0;
double latitudeFirst = 0;
double longitudeFirst = 0;
String address = "";
