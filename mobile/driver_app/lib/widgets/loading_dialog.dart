import 'package:flutter/material.dart';
import 'package:driver_app/utils/my_color.dart';

// ignore: must_be_immutable
class LoadingDialog extends StatelessWidget {
  LoadingDialog({
    super.key,
    required this.messageText,
  });

  String messageText;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: MyColor.white,
      child: Container(
        margin: const EdgeInsets.all(15),
        width: double.infinity,
        decoration: BoxDecoration(
          //color: MyColor.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(children: [
            const SizedBox(
              width: 5,
            ),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(MyColor.green),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              messageText,
              style: TextStyle(
                  fontSize: screenSize.height / 55, color: MyColor.green),
            ),
          ]),
        ),
      ),
    );
  }
}
