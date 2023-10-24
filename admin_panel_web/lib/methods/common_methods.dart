import 'package:flutter/material.dart';

import '../utils/my_color.dart';

class CommonMethods {
  //Header cho bảng
  Widget headerData(int flex, String title) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: MyColor.white),
          color: MyColor.green,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            title,
            style: const TextStyle(color: MyColor.white),
          ),
        ),
      ),
    );
  }

  //Phần thân bảng
  Widget bodyData(int flex, Widget widget) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: MyColor.black),
          color: MyColor.white,
        ),
        child: Padding(padding: const EdgeInsets.all(15), child: widget),
      ),
    );
  }
}
