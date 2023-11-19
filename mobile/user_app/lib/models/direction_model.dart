//Thông tin dự trên JSON của Direction API : https://docs.goong.io/rest/directions/

class DirectionModel {
  String? distanceText;
  String? durationText;
  int? distanceValue;
  int? durationValue;
  String? encodedPoint;
  String? startAddress;
  String? endAddress;

  DirectionModel({
    this.distanceText,
    this.durationText,
    this.distanceValue,
    this.durationValue,
    this.encodedPoint,
    this.startAddress,
    this.endAddress,
  });
}
