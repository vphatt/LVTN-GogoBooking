//Thông tin model lấy từ https://developers.google.com/maps/documentation/places/web-service/autocomplete?hl=vi#json

class PredictionModel {
  String? placeId;
  String? mainText;
  String? secondaryText;

  PredictionModel({this.placeId, this.mainText, this.secondaryText});

  PredictionModel.fromJson(Map<String, dynamic> json) {
    placeId = json["place_id"];
    mainText = json["structured_formatting"]["main_text"];
    secondaryText = json["structured_formatting"]["secondary_text"];
  }
}
