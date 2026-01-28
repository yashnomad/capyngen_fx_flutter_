import 'package:exness_clone/config/flavor_config.dart';
import 'package:exness_clone/main_common.dart';

void main() async {
  FlavorConfig.appFlavor = Flavor.bluegatemarket;
  await initializeApp();
}
