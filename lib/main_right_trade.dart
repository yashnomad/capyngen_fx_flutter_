import 'package:exness_clone/config/flavor_config.dart';
import 'package:exness_clone/main_common.dart';
import 'package:flutter/material.dart';

void main() async {
  FlavorConfig.appFlavor = Flavor.righttrade;
  await initializeApp();
}
