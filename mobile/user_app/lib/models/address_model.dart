class AddressModel {
  String? addressId;
  String? addressName;
  String? addressCoverted; //Địa chỉ đầy đủ tên, quận huyện tỉnh bla bla
  double? latitude;
  double? longitude;

  AddressModel({
    this.addressId,
    this.addressName,
    this.addressCoverted,
    this.latitude,
    this.longitude,
  });
}
