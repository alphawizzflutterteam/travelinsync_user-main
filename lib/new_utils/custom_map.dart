import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:taxi_schedule_user/new_model/schedule_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/Demo_Localization.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

const double CAMERA_TILT = 40;
const double CAMERA_BEARING = 30;



class MapPage extends StatefulWidget {
  bool status;
  LatLng? SOURCE_LOCATION;
  LatLng? DEST_LOCATION;
  String pick, dest;
  String? carType;

  Booking? model;
  String? status1;
  bool live;
  String? id;
  double zoom;
  ValueChanged? onResult;
  MapPage(this.status,
      {this.SOURCE_LOCATION,
      this.DEST_LOCATION,
      required this.live,
      this.model,
      this.zoom = 15,
      this.id,
      this.pick = "",
      this.dest = "",
      this.onResult,
      this.carType,
      this.status1});

  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Completer<GoogleMapController> _controller = Completer();
  // this set will hold my markers
  Set<Marker> _markers = {};
  // this will hold the generated polylines
  Set<Polyline> _polylines = {};
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];
  // this is the key object - the PolylinePoints
  // which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();
  //todo change google map api
  String googleAPIKey = "AIzaSyBPFf5uo0zrJwx1BaLFZonJaQ7vNHVbQkw";
  // for my custom icons
  BitmapDescriptor? sourceIcon;
  BitmapDescriptor? driverIcon;
  BitmapDescriptor? destinationIcon;
  LatLng? SOURCE_LOCATION;
  LatLng? DEST_LOCATION;
  Timer? timer;
  double zoom = 0;
  String km = "", time = "";
  double driveLat = 0, driveLng = 0,heading = 0;
  @override
  void initState() {
    super.initState();

    driveLat = 0;
    zoom = widget.zoom;
    driveLng = 0;
    if (widget.live) {
      getDriver(true);
      timer = Timer.periodic(Duration(seconds: 5), (timer) {
        getDriver(false);
      });
    } else {
      setSourceAndDestinationIcons();
    }
  }
  double _calculateBearing(LatLng start, LatLng end) {
    double startLat = _degreesToRadians(start.latitude);
    double startLng = _degreesToRadians(start.longitude);
    double endLat = _degreesToRadians(end.latitude);
    double endLng = _degreesToRadians(end.longitude);

    double deltaLng = endLng - startLng;

    double y = sin(deltaLng) * cos(endLat);
    double x = cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(deltaLng);
    double bearing = atan2(y, x);

    return _radiansToDegrees(bearing);
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  double _radiansToDegrees(double radians) {
    return radians * (180 / pi);
  }
  ApiBaseHelper apiBase = new ApiBaseHelper();
  bool isNetwork = false;
  bool acceptStatus = false;
  getDriver(bool first) async {
    await App.init();
    isNetwork = await Common.checkInternet();
    if (isNetwork) {
      try {
        Map data;
        data = {
          "driver_id": widget.id.toString(),
        };
        Map response = await apiBase.postAPICall(
            Uri.parse("${Constants.baseUrl}Authentication/get_driver_tracking"), data);
        print(response);
        print(response);
        bool status = true;
        String msg = response['message'];
        // UI.setSnackBar(msg, context);
        if (response['status']) {
          Map data = response['data'];
          driveLat = double.parse(data['lat']??'0');
          driveLng = double.parse(data['lang']??'0');
          heading = double.parse(data['heading']??'0');
          if (widget.onResult != null) {
            widget.onResult!({
              "lat": driveLat,
              "lng": driveLng,
            });
          }
          if (first) {
            setSourceAndDestinationIcons();
            updatePinOnMap();
          } else {
            updatePinOnMap();
          }
          if (!acceptStatus) {
            acceptStatus = true;
          }
          //      setSourceAndDestinationIcons();

          //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> OfflinePage("")), (route) => false);
        } else {}
      } on TimeoutException catch (_) {
        UI.setSnackBar(getTranslated(context, "WRONG")!, context);
      }
    } else {
      UI.setSnackBar(getTranslated(context, "NO_INTERNET")!, context);
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  late LatLng latLng;


  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    int index = _markers.toList().indexWhere((element) => element.markerId.value == 'drivePin');
    double bearing = _calculateBearing(_markers.elementAt(index).position, LatLng(driveLat, driveLng));
    CameraPosition cPosition = CameraPosition(
      zoom: zoom,
      tilt: CAMERA_TILT,
      bearing: bearing,
      target: LatLng(driveLat, driveLng),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due

    if (mounted&&driverIcon!=null){
      setState(() {
        // updated position
        var pinPosition = LatLng(driveLat, driveLng);
        /*_markers.elementAt(index).copyWith(
          positionParam: pinPosition,
          rotationParam: heading,
        );*/
        // the trick is to remove the marker (by id)
        // and add it again at the updated location
        _markers.removeWhere((m) => m.markerId.value == 'drivePin');
        _markers.add(Marker(
            markerId: MarkerId('drivePin'),
            rotation: heading,
            position: pinPosition, // updated position
            icon: driverIcon!));
      });
    }else{

    }

  }
  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');
    if (widget.live) {
      if (widget.carType == "1") {
        driverIcon = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5), 'assets/driver.png');
      } else {
        driverIcon = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5), 'assets/driver.png');
      }
    }

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
    if (widget.status) {
      SOURCE_LOCATION = widget.SOURCE_LOCATION;
      DEST_LOCATION = widget.DEST_LOCATION;
      setMapPins();
      setPolylines();

      /* if (widget.live) {

      }*/
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (widget.live) timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
        zoom: zoom,
        bearing: CAMERA_BEARING,
        tilt: CAMERA_TILT,
        target: widget.SOURCE_LOCATION!);
    return GoogleMap(
        myLocationEnabled: !widget.live,
        compassEnabled: true,
        zoomControlsEnabled: false,
        tiltGesturesEnabled: false,
        markers: _markers,
        polylines: _polylines,
        mapType: MapType.normal,
        initialCameraPosition: initialLocation,
        onMapCreated: onMapCreated);
  }

  void onMapCreated(GoogleMapController controller) async {
    // controller.setMapStyle(Utils.mapStyles);
    _controller.complete(controller);
    var nLat, nLon, sLat, sLon;
    SOURCE_LOCATION = widget.SOURCE_LOCATION;
    DEST_LOCATION = widget.DEST_LOCATION;
    if (widget.status && SOURCE_LOCATION != null && DEST_LOCATION != null) {
      if (DEST_LOCATION!.latitude <= SOURCE_LOCATION!.latitude) {
        sLat = DEST_LOCATION!.latitude;
        nLat = SOURCE_LOCATION!.latitude;
      } else {
        sLat = SOURCE_LOCATION!.latitude;
        nLat = DEST_LOCATION!.latitude;
      }
      if (DEST_LOCATION!.longitude <= SOURCE_LOCATION!.longitude) {
        sLon = DEST_LOCATION!.longitude;
        nLon = SOURCE_LOCATION!.longitude;
      } else {
        sLon = SOURCE_LOCATION!.longitude;
        nLon = DEST_LOCATION!.longitude;
      }
      LatLngBounds bound = LatLngBounds(
          southwest: LatLng(sLat, sLon), northeast: LatLng(nLat, nLon));
      CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 150);
      controller.animateCamera(u2).then((void v) {});
    }
    if (widget.status) {
      //setMapPins();
      //setPolylines();
    }
  }

  void setMapPins() async {
    setState(() {
      // source pin
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: SOURCE_LOCATION!,
          infoWindow: InfoWindow(
            title: "Pickup Location",
            snippet: widget.pick,
          ),
          icon: sourceIcon!));
      if (widget.live) {
        _markers.add(Marker(
            markerId: MarkerId('drivePin'),
            infoWindow: InfoWindow(title: "Driver Location"),
            position: SOURCE_LOCATION!,
            icon: driverIcon!));
      }
      // destination pin
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: DEST_LOCATION!,
          infoWindow: InfoWindow(
            title: "Destination Location",
            snippet: widget.dest,
          ),
          icon: destinationIcon!));
    });
  }

  setPolylines() async {
    _polylines.clear();
    if (widget.live && widget.status1 != null && widget.status1 == "1") {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleAPIKey,
          PointLatLng(driveLat, driveLng),
          PointLatLng(SOURCE_LOCATION!.latitude, SOURCE_LOCATION!.longitude),
          travelMode: TravelMode.driving,
          optimizeWaypoints: true);
      print("${result.points} >>>>>>>>>>>>>>>>..");
      print("$SOURCE_LOCATION >>>>>>>>>>>>>>>>..");
      print("$DEST_LOCATION >>>>>>>>>>>>>>>>..");
      print(result.errorMessage);
      if (result.points.isNotEmpty) {
        // loop through all PointLatLng points and convert them
        // to a list of LatLng, required by the Polyline
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        print("Failed");
      }
      setState(() {
        // create a Polyline instance
        // with an id, an RGB color and the list of LatLng pairs
        Polyline polyline = Polyline(
            width: 5,
            polylineId: PolylineId("poly"),
            color: MyColorName.mainColor,
            points: polylineCoordinates);
        // add the constructed polyline as a set of points
        // to the polyline set, which will eventually
        // end up showing up on the map
        _polylines.add(polyline);
      });
    } else {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleAPIKey,
          PointLatLng(SOURCE_LOCATION!.latitude, SOURCE_LOCATION!.longitude),
          PointLatLng(DEST_LOCATION!.latitude, DEST_LOCATION!.longitude),
          travelMode: TravelMode.driving,
          optimizeWaypoints: true);
      print("${result.points} >>>>>>>>>>>>>>>>..");
      print("$SOURCE_LOCATION >>>>>>>>>>>>>>>>..");
      print("$DEST_LOCATION >>>>>>>>>>>>>>>>..");
      print(result.errorMessage);
      if (result.points.isNotEmpty) {
        // loop through all PointLatLng points and convert them
        // to a list of LatLng, required by the Polyline
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        print("Failed");
      }
      setState(() {
        // create a Polyline instance
        // with an id, an RGB color and the list of LatLng pairs
        Polyline polyline = Polyline(
            width: 5,
            polylineId: PolylineId("poly"),
            color: MyColorName.mainColor,
            points: polylineCoordinates);
        // add the constructed polyline as a set of points
        // to the polyline set, which will eventually
        // end up showing up on the map
        _polylines.add(polyline);
      });
    }

    /*if (widget.status1 != null &&
        widget.status1 == "1" &&
        driveLat != 0 &&
        widget.live) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleAPIKey,
          PointLatLng(driveLat, driveLng),
          PointLatLng(SOURCE_LOCATION!.latitude, SOURCE_LOCATION!.longitude),
          travelMode: TravelMode.driving,
          optimizeWaypoints: true);
      print("${result.points} >>>>>>>>>>>>>>>>..");
      print("$SOURCE_LOCATION >>>>>>>>>>>>>>>>..");
      print("$DEST_LOCATION >>>>>>>>>>>>>>>>..");
      print(result.errorMessage);
      if (result.points.isNotEmpty) {
        // loop through all PointLatLng points and convert them
        // to a list of LatLng, required by the Polyline
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        print("Failed");
      }
      setState(() {
        // create a Polyline instance
        // with an id, an RGB color and the list of LatLng pairs
        Polyline polyline = Polyline(
            width: 5,
            polylineId: PolylineId("poly"),
            color: AppTheme.primaryColor,
            points: polylineCoordinates);
        // add the constructed polyline as a set of points
        // to the polyline set, which will eventually
        // end up showing up on the map
        _polylines.add(polyline);
      });
    } else {

    }*/
  }
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}
