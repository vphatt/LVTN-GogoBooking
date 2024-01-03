import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

String flutterURL =
    "https://gogobooking-5ade1-default-rtdb.asia-southeast1.firebasedatabase.app";

String adminEmail = '';

final formatVND = NumberFormat("###,###,###");
