import 'package:flutter/material.dart';

import '../global/global_var.dart';
import '../methods/common_methods.dart';
import '../utils/my_color.dart';

class PaymentDialog extends StatefulWidget {
  const PaymentDialog({
    super.key,
    required this.actualFareAmount,
    required this.userName,
    required this.actualDistanceText,
  });

  final double actualFareAmount;
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
                  "${formatVND.format(widget.actualFareAmount)} đ",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const ListTile(
                title: Text(
                  "Phí phụ: ",
                  style: TextStyle(fontSize: 15),
                ),
                trailing: Text(
                  "0 đ",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              const ListTile(
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
                  "${formatVND.format(widget.actualFareAmount)} đ",
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: MyColor.red),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    "Vui lòng thanh toán số tiền ${formatVND.format(widget.actualFareAmount)} đồng\ncho tài xế trước khi xuống xe",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  //Tắt dialog và phản hồi thông điệp "paid" cho trang chủ
                  Navigator.pop(context, 'paid');
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: MyColor.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Center(
                    child: Text(
                      "ĐÃ TRẢ TIỀN",
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
