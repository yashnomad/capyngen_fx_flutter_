import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/storage_service.dart';
import '../../../trade/model/trade_account.dart';


class SelectedAccountCubit extends Cubit<Account?> {
  SelectedAccountCubit() : super(StorageService.getSelectedAccount());

  void selectAccount(Account account) {
    StorageService.saveSelectedAccount(account); // ← save locally
    emit(account);
  }

  void clearAccount() {
    StorageService.deleteSelectedAccount(); // ← clear local storage
    emit(null);
  }
}
