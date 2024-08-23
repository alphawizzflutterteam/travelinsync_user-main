class AllScheduleModel {
  AllScheduleModel({
    required this.status,
    required this.message,
    required this.data,
    required this.bookings,
  });

  final bool? status;
  final String? message;
   AllSchedule? data;
     List<Booking> bookings;

  factory AllScheduleModel.fromJson(Map<String, dynamic> json){
    return AllScheduleModel(
      status: json["status"],
      message: json["message"],
      data: json["data"] == null ? null : AllSchedule.fromJson(json["data"]),
      bookings: json["bookings"] == null ? [] : List<Booking>.from(json["bookings"]!.map((x) => Booking.fromJson(x))),
    );
  }

}

class Booking {
  Booking({
    required this.id,
    required this.userId,
    required this.username,
    required this.pickupAddress,
    required this.dropAddress,
    required this.latitude,
    required this.longitude,
    required this.dropLatitude,
    required this.dropLongitude,
    required this.pickupTime,
    required this.reachTime,
    required this.pickupDate,
    required this.status,
    required this.createdDate,
    required this.bookingOtp,
    required this.assignedFor,
  });

  final String? id;
  final String? userId;
  final String? username;
  final String? pickupAddress;
  final String? dropAddress;
  final String? latitude;
  final String? longitude;
  final String? dropLatitude;
  final String? dropLongitude;
  final String? pickupTime;
  final String? reachTime;
  final DateTime? pickupDate;
  final String? status;
  final DateTime? createdDate;
  final String? bookingOtp;
  final String? assignedFor;

  factory Booking.fromJson(Map<String, dynamic> json){
    return Booking(
      id: json["id"],
      userId: json["user_id"],
      username: json["username"],
      pickupAddress: json["pickup_address"],
      dropAddress: json["drop_address"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      dropLatitude: json["drop_latitude"],
      dropLongitude: json["drop_longitude"],
      reachTime: json["reach_time"],
      pickupTime: json["pickup_time"],
      pickupDate: DateTime.tryParse(json["pickup_date"] ?? ""),
      status: json["status"],
      createdDate: DateTime.tryParse(json["created_date"] ?? ""),
      bookingOtp: json["booking_otp"],
      assignedFor: json["assigned_for"],
    );
  }

}

class AllSchedule {
  AllSchedule({
    this.id,
    this.userId,
    this.dataAddress1,
    this.dataAddress2,
    this.startDate,
    this.pickupTime,
    this.reachTime,
    this.dropTime,
    this.flightNo,
    this.days,
    this.endDate,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.address1,
    this.address2,
  });

   String? id;
   String? userId;
   String? dataAddress1;
   String? dataAddress2;
   DateTime? startDate;
   String? pickupTime;
   String? reachTime;
   String? dropTime;
   String? flightNo;
   dynamic days;
   DateTime? endDate;
   String? status;
   DateTime? createdAt;
   DateTime? updatedAt;
   String? address1;
   String? address2;

  factory AllSchedule.fromJson(Map<String, dynamic> json){
    return AllSchedule(
      id: json["id"],
      userId: json["user_id"],
      dataAddress1: json["address_1"],
      dataAddress2: json["address_2"],
      startDate: DateTime.tryParse(json["start_date"] ?? ""),
      pickupTime: json["pickup_time"],
      reachTime: json["reach_time"],
      dropTime: json["drop_time"],
      flightNo: json["flight_no"],
      days: json["days"],
      endDate: DateTime.tryParse(json["end_date"] ?? ""),
      status: json["status"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      address1: json["address1"],
      address2: json["address2"],
    );
  }

}
