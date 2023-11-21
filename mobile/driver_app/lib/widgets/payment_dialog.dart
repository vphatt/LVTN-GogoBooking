import 'package:driver_app/methods/common_methods.dart';
import 'package:driver_app/utils/my_color.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

import '../global/global_var.dart';

class PaymentDialog extends StatefulWidget {
  const PaymentDialog({
    super.key,
    required this.actualFareAmount,
    required this.userName,
    required this.actualDistanceText,
  });

  final String actualFareAmount;
  final String userName;
  final String actualDistanceText;

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  CommonMethods cMethod = CommonMethods();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: MyColor.white,
      child: Container(
        //width: screenSize.width / 2,
        decoration: BoxDecoration(
          color: MyColor.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              const Center(
                  child: Text(
                "THANH TOÁN",
                style: TextStyle(
                    color: MyColor.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              )),
              const Divider(color: MyColor.grey),
              Row(
                children: [
                  const Text("Khách hàng: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.userName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.white70, width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: MyColor.black,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        "Tiền mặt",
                        style: TextStyle(color: MyColor.white),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: MyColor.grey),
              ListTile(
                title: const Text(
                  "Tổng km di chuyển: ",
                  style: TextStyle(fontSize: 15),
                ),
                trailing: Text(
                  widget.actualDistanceText,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              ListTile(
                title: const Text(
                  "Phí theo km: ",
                  style: TextStyle(fontSize: 15),
                ),
                trailing: Text(
                  "${formatVND.format(double.parse(widget.actualFareAmount))} đ",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              ListTile(
                title: Text(
                  "Phí phụ: ",
                  style: TextStyle(fontSize: 15),
                ),
                trailing: Text(
                  "0 đ",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              ListTile(
                title: Text(
                  "Khuyến mại: ",
                  style: TextStyle(fontSize: 15),
                ),
                trailing: Text(
                  "0 đ",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              const Divider(color: MyColor.grey),
              ListTile(
                title: const Text(
                  "TỔNG CỘNG:",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  "${formatVND.format(double.parse(widget.actualFareAmount))} đ",
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: MyColor.red),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  cMethod.enableUpdateLocationDriver();
                  Restart.restartApp();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Center(
                    child: Text(
                      "ĐÃ THU TIỀN",
                      style: TextStyle(
                          fontSize: screenSize.height / 65,
                          fontWeight: FontWeight.bold,
                          color: MyColor.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
