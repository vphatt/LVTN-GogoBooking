import 'package:flutter/material.dart';
import 'package:user_app/models/address_model.dart';

class AppInfo extends ChangeNotifier {
  AddressModel? startLocation;
  AddressModel? endLocation;

  void updateStartLocation(AddressModel startLocationModel) {
    startLocation = startLocationModel;
    notifyListeners();
  }

  void updateEndLocation(AddressModel endLocationModel) {
    endLocation = endLocationModel;
    notifyListeners();
  }
}
