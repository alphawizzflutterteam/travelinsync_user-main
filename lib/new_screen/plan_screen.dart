import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:taxi_schedule_user/new_model/plan_model.dart';
import 'package:taxi_schedule_user/new_utils/ApiBaseHelper.dart';
import 'package:taxi_schedule_user/new_utils/colors.dart';
import 'package:taxi_schedule_user/new_utils/common_ui.dart';
import 'package:taxi_schedule_user/new_utils/constant.dart';
import 'package:taxi_schedule_user/new_utils/ui.dart';

class PlanScreen extends StatefulWidget {
  final bool selected;
  const PlanScreen({super.key,this.selected = false});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  bool loading = true, network = false;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPlan();
  }

  List<PlanModel> planList = [];
  Future getPlan() async {
    network = await Common.checkInternet();
    if (network) {
      Map param = {
        'user_id': Constants.curUserId,
      };
      Map response = await apiBaseHelper.getAPICall(
          Uri.parse("${Constants.baseUrl}Authentication/get_plans"),);
      planList.clear();
      if (response['status']) {
        for (var v in response['data']) {
          planList.add(PlanModel.fromJson(v));
        }
      } else {
        UI.setSnackBar(response['message'] ?? 'Something went wrong', context);
      }
    } else {
      UI.setSnackBar("No Internet Connection", context);
    }
    setState(() {
      loading = false;
    });
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
        title: Text("Subscriptions"),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          RefreshIndicator(
            onRefresh: () async {
              setState(() {
                loading = true;
              });
              await getPlan();
            },
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  Expanded(
                      child: ListView.builder(
                          itemCount: planList.length,
                          padding: const EdgeInsets.all(4.0),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            PlanModel model = planList[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                side: BorderSide(color: MyColorName.secondColor)
                              ),
                              color: Colors.white,
                              margin: EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ClipRRect(
                              borderRadius: BorderRadius.only(topLeft:Radius.circular(12),topRight: Radius.circular(12)),
                                    child: Container(
                                      height: 100,
                                      padding: const EdgeInsets.all(12.0),
                                      color: MyColorName.secondColor,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                (model.price??'0')+" AED",
                                                style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.white),
                                              ),
                                              Text(
                                                " / "+(model.type??'0'),
                                                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          UI.commonButton(
                                            title: model.title??'',
                                            onPressed: null,
                                            bgColor: Colors.white,
                                            fontColor: MyColorName.secondColor,
                                            borderColor: MyColorName.secondColor
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Html(
                                      data: model.description??"",
                                      style: {
                                        'p': Style(
                                          fontSize: FontSize(16),
                                        ),
                                        'li': Style(
                                          fontSize: FontSize(16),
                                        ),
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 20,),
                                  SizedBox(
                                    width: Common.getWidth(50, context),
                                    child: UI.commonButton(
                                        title: "Get Started",
                                       // bgColor: Colors.white,
                                      //  fontColor: MyColorName.mainColor,
                                        onPressed: (){

                                        }
                                    ),
                                  ),
                                  SizedBox(height: 20,),
                                ],
                              ),
                            );
                          })),
                ],
              ),
            ),
          ),
          if (loading) CircularProgressIndicator(),
        ],
      ),

    );
  }
}
