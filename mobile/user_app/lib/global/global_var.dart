import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//Thông tin user lưu toàn cục
String userNameGB = '';
String userPhoneGB = '';
String userIdGB = FirebaseAuth.instance.currentUser!.uid;

String flutterURL =
    "https://gogobooking-5ade1-default-rtdb.asia-southeast1.firebasedatabase.app";
String googleMapKey = "AIzaSyBBe_0Hm2yhj1kjBr1swX8l51hQgI4r6PQ";

String goongMapKey = "H6kU854UuaIgC8OnW0Dh8K2cVGjl9PbQEUPpjWQr";

String serverKeyFCM =
    "key=AAAAZLxD70c:APA91bFf6AAnpbvSTzqr2BVV5cam1COrsa1hi-mfz2x3qWi24il0ClUjKzLgFzSmyZzIFEvUNwobctXYNvrzlib_Q3Do1Nf8Fg5cnoc-Ddu_xk5t7wo1qiIe81AOGxDor_nb8XXBTiOA";

const CameraPosition googleMapInitialPosition = CameraPosition(
  target: LatLng(9.614758, 105.973307),
  zoom: 15,
);
