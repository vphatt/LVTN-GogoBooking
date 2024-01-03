import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/global/global_var.dart';
import 'package:user_app/methods/common_methods.dart';
import 'package:user_app/models/address_model.dart';
import 'package:user_app/models/prediction_model.dart';
import 'package:user_app/widgets/loading_dialog.dart';
import '../utils/app_info.dart';
import '../utils/my_color.dart';

// ignore: must_be_immutable
class EndPredictionResult extends StatefulWidget {
  EndPredictionResult({super.key, this.predictionModel});

  PredictionModel? predictionModel;

  @override
  State<EndPredictionResult> createState() => _EndPredictionResultState();
}

class _EndPredictionResultState extends State<EndPredictionResult> {
  //Chi tiết địa điểm
  placeDetail(String placeId) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Chi tiết địa chỉ..."),
    );

    String urlPlaceDetail =
        "https://rsapi.goong.io/Place/Detail?place_id=$placeId&api_key=$goongMapKey";

    var responseFromPlaceAPI =
        await CommonMethods.sendRequestToAPI(urlPlaceDetail);

    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    if (responseFromPlaceAPI == "error") {
      return;
    }
    if (responseFromPlaceAPI["status"] == "OK") {
      AddressModel address = AddressModel();

      address.addressId = placeId;
      address.addressName = responseFromPlaceAPI["result"]["name"];
      address.addressCoverted =
          responseFromPlaceAPI["result"]["formatted_address"];
      address.latitude =
          responseFromPlaceAPI["result"]["geometry"]["location"]["lat"];
      address.longitude =
          responseFromPlaceAPI["result"]["geometry"]["location"]["lng"];

      // ignore: use_build_context_synchronously
      Provider.of<AppInfo>(context, listen: false).updateEndLocation(address);
      // ignore: use_build_context_synchronously
      Navigator.pop(context, "placeSelected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                placeDetail(widget.predictionModel!.placeId.toString());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.share_location,
                    color: MyColor.black,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.predictionModel!.mainText.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: MyColor.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          widget.predictionModel!.secondaryText.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: MyColor.black54,
                              fontSize: 16,
                              fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 2,
            ),
          ],
        ),
      ),
      // const SizedBox(
      //   height: 10,
      // ),
    );
  }
}
