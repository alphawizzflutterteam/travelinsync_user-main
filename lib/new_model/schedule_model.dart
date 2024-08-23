import 'dart:math';

class ScheduleModel {
  Schedule? schedule;
  // Booking? booking;
  List<Booking>? booking;

  ScheduleModel({this.schedule, this.booking});

  ScheduleModel.fromJson(Map<String, dynamic> json) {
    schedule = json['schedule'] != null
        ? new Schedule.fromJson(json['schedule'])
        : null;
    // booking =
    // json['booking'] != null ? new Booking.fromJson(json['booking']) : null;
    if (json['booking'] != null) {
      booking = <Booking>[];
      json['booking'].forEach((v) {
        booking!.add(new Booking.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.schedule != null) {
      data['schedule'] = this.schedule!.toJson();
    }

    // if (this.booking != null) {
    //   data['booking'] = this.booking!.toJson();
    // }
    if (this.booking != null) {
      data['booking'] = this.booking!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Schedule {
  String? id;
  String? userId;
  String? pickupTime;
  String? dropTime;
  String? pickupAddress;
  String? dropAddress;
  String? endDate;
  String? flightNo;
  Schedule(
      {this.id,
        this.userId,
        this.flightNo,
        this.pickupTime,
        this.dropTime,
        this.endDate,
        this.pickupAddress,
        this.dropAddress});

  Schedule.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    flightNo = json['flight_no'];
    pickupTime = json['pickup_time'];
    dropTime = json['drop_time'];
    endDate = json['end_date'];
    pickupAddress = json['pickup_address'];
    dropAddress = json['drop_address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['pickup_time'] = this.pickupTime;
    data['drop_time'] = this.dropTime;
    data['end_date'] = this.endDate;
    data['pickup_address'] = this.pickupAddress;
    data['drop_address'] = this.dropAddress;
    return data;
  }
}

class Booking {
  String? id;
  String? userId;
  String? username;
  String? pickupAddress;
  String? dropAddress;
  String? dropTime;
  String? latitude;
  String? longitude;
  String? dropLatitude;
  String? dropLongitude;
  String? pickupTime;
  String? pickupDate;
  String? type;
  String? status;
  String? createdDate;
  String? bookingOtp;
  String? assignedFor;
  String? remark;
  String? driverImage;
  String? drivermobile;
  String? driveruserName;
  String? driverLatitude;
  String? driverLangitude;
  String? driverHeading;
  String? driverSpeed;
  String? userRemark;

  Booking(
      {this.id,
        this.userId,
        this.username,
        this.userRemark,
        this.pickupAddress,
        this.dropAddress,
        this.latitude,
        this.longitude,
        this.dropTime,
        this.dropLatitude,
        this.dropLongitude,
        this.pickupTime,
        this.pickupDate,
        this.type,
        this.status,
        this.createdDate,
        this.bookingOtp,
        this.assignedFor,
        this.remark,
        this.driverImage,
        this.drivermobile,
        this.driveruserName,this.driverLatitude,
        this.driverLangitude,
        this.driverHeading,
        this.driverSpeed});

  Booking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    userRemark = json['user_remark'];
    username = json['username'];
    driverLatitude = json['driver_latitude'];
    driverLangitude = json['driver_langitude'];
    driverHeading = json['driver_heading'];
    driverSpeed = json['driver_speed'];
    pickupAddress = json['pickup_address'];
    dropAddress = json['drop_address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    dropLatitude = json['drop_latitude'];
    dropTime = json['drop_time'];
    dropLongitude = json['drop_longitude'];
    pickupTime = json['pickup_time'];
    pickupDate = json['pickup_date'];
    type = json['type'];
    status = json['status'];
    createdDate = json['created_date'];
    bookingOtp = json['booking_otp'];
    assignedFor = json['assigned_for'];
    remark = json['remark'];
    driverImage = json['driver_image'];
    drivermobile = json['drivermobile'];
    driveruserName = json['driveruser_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['username'] = this.username;
    data['pickup_address'] = this.pickupAddress;
    data['drop_address'] = this.dropAddress;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['drop_latitude'] = this.dropLatitude;
    data['drop_longitude'] = this.dropLongitude;
    data['pickup_time'] = this.pickupTime;
    data['pickup_date'] = this.pickupDate;
    data['type'] = this.type;
    data['status'] = this.status;
    data['created_date'] = this.createdDate;
    data['drop_time'] = this.dropTime;
    data['booking_otp'] = this.bookingOtp;
    data['assigned_for'] = this.assignedFor;
    data['remark'] = this.remark;
    data['driver_image'] = this.driverImage;
    data['drivermobile'] = this.drivermobile;
    data['driveruser_name'] = this.driveruserName;
    return data;
  }

}

