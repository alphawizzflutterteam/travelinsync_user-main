import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';


import 'constant.dart';
String token="123";
class ApiBaseHelper {

  Future<dynamic> postAPICall(Uri url, var param) async {
    await App.init();
    if(App.localStorage.getString("user_id")!=null){
      token = App.localStorage.getString("user_id").toString();
    }


    try {
      Common.debugPrintApp(
          "API : $url \n parameter : $param   \n ");
      final response = await post(url,
          body: param,headers: {
           // 'Content-Type': 'application/json',
             'Accept': '*/*',
             //'Content-Type':'application/x-www-form-urlencoded',
             'authorization':token.toString(),
          })
          .timeout(const Duration(seconds: 60));

      Common.debugPrintApp(
          "API : $url \n parameter : ${param}  \n header: ${{
            'authorization':token.toString(),
          }}\n response:  ${response.body.toString()}yuj ");
     var responseJson = _response(response);
      return responseJson;
    } on SocketException {
      return {"status":false,"message":"No Internet connection"};
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      return {"status":false,"message":"Something went wrong, try again later"};
      throw FetchDataException('Something went wrong, try again later');
    } on Exception{
      return {"status":false,"message":"Something went wrong, try again later"};
    }

  }

  Future<dynamic> whatsappAPICall(var param) async {
    await App.init();
    if(App.localStorage.getString("user_id")!=null){
      token = App.localStorage.getString("user_id").toString();
    }
    var responseJson;
    try {
      Common.debugPrintApp(
          "API :  \n parameter : $param   \n ");
      final response = await post(Uri.parse("https://graph.facebook.com/v17.0/144879505371989/messages"),
          body: jsonEncode(param),headers: {
             'Content-Type': 'application/json',
            'Accept': '*/*',
            //'Content-Type':'application/x-www-form-urlencoded',
            'Authorization':"Bearer EAAeGSmd4AHcBO64ZCXE0gLDCZB6HgEs0F275iW7BBKQ95ZAUvoIZBgO23BANdvCfZAchNM8DnWYi8y1TZALW61lZABRIxASpM4vZAauZCFZAMIR8y69XDG612NdWOVgGmz2qtrA2KKhZCVeSh4pExGtEVFnk1Fxlz6G5loeJdq8HNvDAmo7YUZCkSPoK6l8GZC1UqW6xZCsaNcBPGeotPIuBDPM39xiU5ULBTbiFS9wZBgZAiLFZBZAmIZD",
          })
          .timeout(const Duration(seconds: 60));

      Common.debugPrintApp(
          "API : ${Uri.parse("https://graph.facebook.com/v17.0/144879505371989/messages")} \n parameter : ${param}  \n header: ${{
            'authorization':token.toString(),
          }}\n response:  ${response.body.toString()}yuj ");
      responseJson = _response(response);
    } on SocketException {
      return {"status":false,"message":"No Internet connection"};
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      return {"status":false,"message":"Something went wrong, try again later"};
      throw FetchDataException('Something went wrong, try again later');
    } on Exception{
      return {"status":false,"message":"Something went wrong, try again later"};
    }
    return responseJson;
  }
  Future<dynamic> patchAPICall(Uri url, var param) async {
    await App.init();
    if(App.localStorage.getString("user_id")!=null){
      token = App.localStorage.getString("user_id").toString();
    }
    var responseJson;
    try {
      Common.debugPrintApp(
          "API : $url \n parameter : $param   \n ");
      final response = await patch(url,
          body: param,headers: {
            'Content-Type': 'application/json',
            // 'Accept': '*/*',
             //'Content-Type':'application/x-www-form-urlencoded',
            'authorization':token.toString(),
          })
          .timeout(const Duration(seconds: 60));
     /* Common.debugPrintApp(
          "API : $url \n parameter : ${param}   \n response:  ${response.body.toString()}yuj ");*/
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw FetchDataException('Something went wrong, try again later');
    }
    return responseJson;
  }
  Future<dynamic> getAPICall(Uri url, {String? extraParam}) async {
    await App.init();
    if(App.localStorage.getString("user_id")!=null){
       token = App.localStorage.getString("user_id").toString();
    }
    if(extraParam!=null){
      token ="${token}_$extraParam";
    }


    var responseJson;
    try {
      /*Common.debugPrintApp(
          "API : $url \n parameter :    \n ");*/
      final response = await get(url,
          headers: {
            'Content-Type': 'application/json',
           // 'Content-Type':'application/x-www-form-urlencoded',
            'authorization':token.toString(),
          })
          .timeout(const Duration(seconds: 60));

      Common.debugPrintApp(
          "API : $url \n Headers : ${{
            'Content-Type':'application/x-www-form-urlencoded',
            'authorization':token.toString(),
          }}   \n response:  ${response.body.toString()}yuj ");
      responseJson = _response(response);
    } on SocketException {
      return {"status":false,"message":"No Internet connection"};
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      return {"status":false,"message":"Something went wrong, try again later"};
      throw FetchDataException('Something went wrong, try again later');
    } on Exception{
      return {"status":false,"message":"Something went wrong, try again later"};
    }
    return responseJson;
  }
  Future<dynamic> deleteAPICall(Uri url) async {
    await App.init();
    if(App.localStorage.getString("token")!=null){
      token = App.localStorage.getString("token").toString();
    }

    var responseJson;
    try {
      Common.debugPrintApp(
          "API : $url \n parameter :    \n ");
      final response = await delete(url,
          headers: {
            'Content-Type': 'application/json',
           // 'Content-Type':'application/x-www-form-urlencoded',
            'authorization':"Bearer $token",
          })
          .timeout(const Duration(seconds: 60));
      Common.debugPrintApp(
          "API : $url \n Headers : ${{
            'Accept': '*/*',
            'Content-Type':'application/x-www-form-urlencoded',
            'authorization':Constants.curUserId.toString(),
          }}   \n response:  ${response.body.toString()}yuj ");
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on TimeoutException {
      throw FetchDataException('Something went wrong, try again later');
    }
    return responseJson;
  }
  dynamic _response(Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      case 400:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      case 401:
      case 403:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      case 500:
      default:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
    }
  }
}

class CustomException implements Exception {
  final _message;
  final _prefix;
  CustomException([this._message, this._prefix]);
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends CustomException {
  InvalidInputException([message]) : super(message, "Invalid Input: ");
}
