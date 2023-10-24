import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:user_app/methods/common_methods.dart';
import 'package:user_app/models/prediction_model.dart';
import 'package:user_app/utils/my_color.dart';
import 'package:user_app/widgets/start_prediction_result.dart';
import 'package:user_app/widgets/end_prediction_result.dart';

import '../global/global_var.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  List<PredictionModel> startPredictionList = [];
  List<PredictionModel> endPredictionList = [];

  //focus node
  FocusNode? startFocusNode;
  FocusNode? endFocusNode;

  //biến thời gian để tạo độ trễ khi nhập tìm kiếm, hạn chế API bị gọi liên tục
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startFocusNode = FocusNode();
    endFocusNode = FocusNode();
  }

  //Đầu - Tìm kiếm địa điểm, tự động gợi ý hoàn thành địa điểm
  searchStartLocation(String locationTyped) async {
    if (locationTyped.length > 1) {
      String apiPlaceUrl =
          "https://rsapi.goong.io/Place/AutoComplete?api_key=$goongMapKey&input=$locationTyped";

      var responseFromPlacesAPI =
          await CommonMethods.sendRequestToAPI(apiPlaceUrl);

      if (responseFromPlacesAPI == "error") {
        return;
      }
      if (responseFromPlacesAPI["status"] == "OK") {
        var predictionResult = responseFromPlacesAPI["predictions"];

        var predictionList = (predictionResult as List)
            .map((placePrediction) => PredictionModel.fromJson(placePrediction))
            .toList();

        setState(() {
          startPredictionList = predictionList;
        });
        //print("KẾT QUẢ GỢI Ý: $predictionResult");
      }
    }
  }

  //Cuối - Tìm kiếm địa điểm, tự động gợi ý hoàn thành địa điểm
  searchEndLocation(String locationTyped) async {
    if (locationTyped.length > 1) {
      String apiPlaceUrl =
          "https://rsapi.goong.io/Place/AutoComplete?api_key=$goongMapKey&input=$locationTyped";

      var responseFromPlacesAPI =
          await CommonMethods.sendRequestToAPI(apiPlaceUrl);

      if (responseFromPlacesAPI == "error") {
        return;
      }
      if (responseFromPlacesAPI["status"] == "OK") {
        var predictionResult = responseFromPlacesAPI["predictions"];

        var predictionList = (predictionResult as List)
            .map((placePrediction) => PredictionModel.fromJson(placePrediction))
            .toList();

        setState(() {
          endPredictionList = predictionList;
        });
        //print("KẾT QUẢ GỢI Ý: $predictionResult");
      }
    }
  }

  Position? currentPositionOfUser;
  String placeIDCurrent = "";
  getLocationCurrent() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;

    // ignore: use_build_context_synchronously
    var address = CommonMethods.convertCoordinateToAddress(
        context, currentPositionOfUser!);
    return address;
  }

  @override
  void dispose() {
    super.dispose();
    startController.dispose();
    endController.dispose();
    startFocusNode!.dispose();
    endFocusNode!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // String userAddress = Provider.of<AppInfo>(context, listen: false)
    //         .startLocation!
    //         .addressCoverted ??
    //     "";
    // startController.text = userAddress;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 0.0,
          iconTheme: const IconThemeData(color: MyColor.white),
          centerTitle: true,
          title: const Text(
            'Tìm kiếm địa điểm',
            style: TextStyle(color: MyColor.white),
          ),
          backgroundColor: MyColor.green,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              //Phần chọn điểm đầu và điểm cuối
              Container(
                //height: 50,
                decoration: const BoxDecoration(
                  color: MyColor.green,
                  boxShadow: [
                    BoxShadow(
                      color: MyColor.black,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: TextField(
                          controller: startController,
                          focusNode: startFocusNode,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(fontSize: 20),
                          onChanged: (value) {
                            if (_timer?.isActive ?? false) _timer?.cancel();
                            _timer = Timer(const Duration(seconds: 1), () {
                              searchStartLocation(value);
                            });
                            // Future.delayed(const Duration(seconds: 2), () {
                            //   searchStartLocation(value);
                            // });
                          },
                          decoration: InputDecoration(
                              hintText: 'Vị trí đầu',
                              filled: true,
                              fillColor: MyColor.white,
                              hintStyle: const TextStyle(
                                color: MyColor.grey,
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons.my_location,
                                color: MyColor.green,
                              ),
                              suffixIcon: RichText(
                                  text: TextSpan(children: [
                                WidgetSpan(
                                  child: IconButton(
                                    onPressed: () async {
                                      //print("ĐỊA CHỈ HIỆN TẠI: $address");
                                      String addr = await getLocationCurrent();
                                      var placeId =
                                          // ignore: use_build_context_synchronously
                                          await CommonMethods.getCurrentPlaceID(
                                              context, currentPositionOfUser!);
                                      placeIDCurrent = placeId;
                                      //print("PLACEID: $placeIDCurrent");
                                      // ignore: use_build_context_synchronously
                                      CommonMethods.placeCurrentDetail(
                                          context, placeIDCurrent);
                                      startController.text = addr;
                                      //     Provider.of<AppInfo>(context,
                                      //             listen: false)
                                      //         .startLocation!
                                      //         .addressName!;
                                      // print("ĐỊA CHỈ ĐÃ CHỌNNNNN: " +
                                      //     Provider.of<AppInfo>(context,
                                      //             listen: false)
                                      //         .startLocation!
                                      //         .addressName!);
                                      //placeDetail(widget.predictionModel!.placeId.toString());
                                    },
                                    icon: const Text(
                                      'Tại đây',
                                      style: TextStyle(
                                          color: MyColor.green,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                WidgetSpan(
                                  child: IconButton(
                                    onPressed: () {
                                      startController.text = "";
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              ]))),
                        ),
                      ),
                      TextField(
                        controller: endController,
                        focusNode: endFocusNode,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(fontSize: 20),
                        onChanged: (value) {
                          if (_timer?.isActive ?? false) _timer?.cancel();
                          _timer = Timer(const Duration(seconds: 1), () {
                            searchEndLocation(value);
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Vị trí đích',
                          filled: true,
                          fillColor: MyColor.white,
                          hintStyle: const TextStyle(
                            color: MyColor.grey,
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          prefixIcon: const Icon(
                            Icons.location_on,
                            color: MyColor.rose,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              endController.text = "";
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //Phần hiện thị kết quả tìm kiếm
              (startPredictionList.isNotEmpty || endPredictionList.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 30),
                      child: startFocusNode!.hasFocus
                          ? ListView.separated(
                              itemCount: startPredictionList.length,
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return StartPredictionResult(
                                  predictionModel: startPredictionList[index],
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const SizedBox(
                                height: 3,
                              ),
                            )
                          : ListView.separated(
                              itemCount: endPredictionList.length,
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return EndPredictionResult(
                                  predictionModel: endPredictionList[index],
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const SizedBox(
                                height: 3,
                              ),
                            ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
