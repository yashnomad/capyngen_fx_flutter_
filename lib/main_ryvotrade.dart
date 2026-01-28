
import 'config/flavor_config.dart';
import 'main_common.dart';

void main() async {
  FlavorConfig.appFlavor = Flavor.ryvotrade;
  await initializeApp();
}
