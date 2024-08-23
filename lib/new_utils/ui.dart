
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';



import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/toast_widget.dart';

class UI {
  static ThemeData getLightTheme() {
    return ThemeData(
        useMaterial3: true,
        primaryColor: MyColorName.mainColor,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 0, foregroundColor: Colors.white),
        brightness: Brightness.light,
        scaffoldBackgroundColor: MyColorName.scaffoldColor,
        dividerColor:
            UI.parseColor(MyColorName.colorTextSecondary, opacity: 0.3),
        focusColor: UI.parseColor(MyColorName.accentColor),
        hintColor: UI.parseColor(MyColorName.colorTextPrimary),
        appBarTheme: AppBarTheme(
            backgroundColor: MyColorName.mainColor,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 16.0,
                decoration: TextDecoration.none)),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
          textStyle: MaterialStateTextStyle.resolveWith((states) =>
              TextStyle(fontSize: 10.0, fontWeight: FontWeight.w500)),
          iconSize: MaterialStateProperty.all(16.0),
          overlayColor: MaterialStateProperty.resolveWith(
            (states) {
              return states.contains(MaterialState.pressed)
                  ? Colors.white10
                  : null;
            },
          ),
        )),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: UI.parseColor(MyColorName.colorTextPrimary)),
        ),
        scrollbarTheme: ScrollbarThemeData(
            thumbVisibility: MaterialStateProperty.all(true),
            thickness: MaterialStateProperty.all(2),
            thumbColor: MaterialStateProperty.all<Color>(Colors.black54)),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(
            fontSize: 12.0,
            color: const Color(0xFF928F8F),
            fontWeight: FontWeight.w400,
          ),
          labelStyle: TextStyle(
            fontSize: 14.0,
            color: const Color(0xFF928F8F),
            fontWeight: FontWeight.w400,
          ),
          fillColor: MyColorName.colorEdit,
          isDense: true,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: UI.parseColor(MyColorName.colorHintFour, opacity: 1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: UI.parseColor(
                MyColorName.mainColor,
              ),
            ),
          ),
        ),
        colorScheme: ColorScheme.light(
          primary: UI.parseColor(
            MyColorName.mainColor,
          ),
          secondary: UI.parseColor(
            MyColorName.secondColor,
          ),
        ),
       
    );
  }

  static Widget rowItem(
      {String title = "",
      String content = "",
      Color color = Colors.black,
      FontWeight fontWeight = FontWeight.w400}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              color: const Color(0xFF928F8F),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 0,
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 3,
          child: Text(
            content,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: fontWeight,
              height: 0,
            ),
          ),
        ),
      ],
    );
  }

  static Widget commonIconButton({String? message,required IconData iconData,Color? iconColor,VoidCallback? onPressed}){
    return Tooltip(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: MyColorName.mainColor,
        borderRadius: BorderRadius.circular(5),
      ),
      triggerMode: onPressed==null?TooltipTriggerMode.tap:null,
      message: message,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          iconData,
          color: iconColor,
        ),
      ),
    );
  }

  static Widget commonDialog(BuildContext context,
      {String title = "Logout",
      String content = "Do You Want to Proceed ?",
      String noText = "No",
      String yesText = "Yes",
      VoidCallback? onYesPressed,
      VoidCallback? onNoPressed}) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Text(
        title,
      ),
      content: Row(
        children: [
          SelectableText(
            content,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: onNoPressed ??
              () {
                Navigator.pop(context);
              },
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
              backgroundColor: Colors.red),
          child: Text(
            noText,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontSize: 12.0, color: Colors.white),
          ),
        ),
        boxWidth(0.5, context),
        ElevatedButton(
          onPressed: onYesPressed,
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
              backgroundColor: Colors.green),
          child: Text(
            yesText,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontSize: 12.0, color: Colors.white),
          ),
        ),
      ],
    );
  }

  static void setSnackBar(String msg, BuildContext context1,
      {double right = 20.0,
      double bottom = 50.0,
      String title = "",
      Color color = Colors.red}) {
    var overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        right:  null,
        bottom: 30,
        top: null,
        //left: MediaQuery.of(context).size.width * 0.2,
        child: Align(
          alignment:
               Alignment.bottomCenter,
          child: SlideToast(
            onRemove: () {
              overlayEntry.remove();
            },
            title: title,
            message: msg,
            color: color,
          ),
        ),
      ),
    );
    Overlay.of(context1).insert(overlayEntry);
  }

  static Color parseColor(Color hexCode,
      {double? opacity, String? transColor}) {
    if (transColor != null) {
      try {
        return Color(int.parse(transColor.replaceAll("#", "0xFF")))
            .withOpacity(opacity ?? 1);
      } catch (e) {
        return hexCode.withOpacity(opacity ?? 1);
      }
    } else {
      return hexCode.withOpacity(opacity ?? 1);
    }
  }

  static Widget boxWidth(double width, BuildContext context) {
    return SizedBox(
      width: Common.getWidth(width, context),
    );
  }

  static Widget boxHeight(double height, BuildContext context) {
    return SizedBox(
      height: Common.getHeight(height, context),
    );
  }



  static Widget commonButton(
      {String title = "Btn",
      double fontSize = 14.0,
      double borderRadius = 10.0,
      bool loading = false,
      Color bgColor = MyColorName.mainColor,
      Color borderColor = MyColorName.mainColor,
      Color fontColor = Colors.white,
      VoidCallback? onPressed}) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(bgColor),
          side: MaterialStateProperty.all(BorderSide(color: borderColor)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius))),
          overlayColor: MaterialStateProperty.resolveWith(
            (states) {
              return states.contains(MaterialState.pressed)
                  ? Colors.white10
                  : null;
            },
          ),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
          elevation: MaterialStateProperty.all(0),
        ),
        child: !loading
            ? Text(
                title,
                style: TextStyle(
                    color: fontColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600),
              )
            : CircularProgressIndicator(
                color: fontColor,
              ));
  }

  static Widget commonImage(url,  context,
      {
        double? height, double? width,
       // String placeHolder = Assets.svgEye,
      //String errorImage = Assets.svgPending,
      bool click = true,
        double radius = 100,
      BoxFit? boxFit}) {
    return InkWell(
      onTap: () {
        if (click) {
          showDialog(
              context: context,
              builder: (ctx) => Dialog(
                  child: Container(
                      height: 400,
                      width: 400,
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: InteractiveViewer(
                              panEnabled: true, // Set it to false
                              boundaryMargin: const EdgeInsets.all(100),
                              minScale: 0.5,
                              maxScale: 2,
                              child: commonImage(url,  context,height:300.0,width: 300.0,
                                  click: false))))));
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
           Constants.imageBaseUrl + url,
          height: height,
          width: width,
          fit: boxFit,
        ),
      ),
    );
  }
}
