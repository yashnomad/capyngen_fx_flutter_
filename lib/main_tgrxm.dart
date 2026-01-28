
import 'config/flavor_config.dart';
import 'main_common.dart';

void main() async {
  FlavorConfig.appFlavor = Flavor.tgrxm;
  await initializeApp();
}
