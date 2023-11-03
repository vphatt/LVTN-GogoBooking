import 'package:flutter/material.dart';
import 'package:user_app/utils/my_color.dart';

class InfoDialog extends StatefulWidget {
  final String? title;
  final String? description;
  const InfoDialog({this.title, this.description, super.key});

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: MyColor.white,
      child: Container(
        //height: screenSize.height / 2,
        width: double.infinity,
        decoration: BoxDecoration(
          color: MyColor.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: screenSize.height / 50),
                  child: Text(
                    widget.title!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MyColor.black,
                      fontSize: screenSize.height / 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    widget.description!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MyColor.black,
                      fontSize: screenSize.height / 60,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: screenSize.height / 50),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "XÁC NHẬN",
                        style: TextStyle(
                            fontSize: screenSize.height / 50,
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
      ),
    );
  }
}
