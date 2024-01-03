import 'package:user_app/models/active_nearby_driver_model.dart';

class DriverManagerMethod {
  static List<ActiveNearbyDriverModel> activeNearbyDriverList = [];

  //Xoá tài xế khi tài xế ngưng hoạt động
  static void removeDriverFromList(String driverId) {
    int index = activeNearbyDriverList
        .indexWhere((driver) => driver.uidDriver == driverId);

    if (activeNearbyDriverList.isNotEmpty) {
      activeNearbyDriverList.removeAt(index);
    }
  }

  //Cập nhật tài xế lân cận
  static void updateActiveNearbyDriverLocation(
      ActiveNearbyDriverModel activeNearbyDriverModel) {
    int index = activeNearbyDriverList.indexWhere(
        (driver) => driver.uidDriver == activeNearbyDriverModel.uidDriver);

    activeNearbyDriverList[index].latDriver = activeNearbyDriverModel.latDriver;
    activeNearbyDriverList[index].lngDriver = activeNearbyDriverModel.lngDriver;
  }
}
