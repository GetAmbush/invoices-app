import 'package:injectable/injectable.dart';
import 'package:invoice_app/src/core/domain/data_models/invoice.dart';
import 'package:invoice_app/src/core/domain/usecases/get_invoice_list.dart';
import 'package:invoice_app/src/core/domain/usecases/validate_invoice_settings.dart';
import 'package:mobx/mobx.dart';

part 'list_page_viewmodel.g.dart';

@injectable
class ListPageViewModel extends _ListPageViewModelBase
    with _$ListPageViewModel {
  ListPageViewModel(
    super._getInvoiceList,
    super._validateInvoiceSettings,
  );
}

abstract class _ListPageViewModelBase with Store {
  final IGetInvoiceList _getInvoiceList;
  final IValidateInvoiceSettings _validateInvoiceSettings;

  _ListPageViewModelBase(
    this._getInvoiceList,
    this._validateInvoiceSettings,
  ) {
    // Get initial value
    updateList(_getInvoiceList.get());

    // if(_validateInvoiceSettings.validate() != InvoiceSettingsStatus.ok) {
    //   showInfoFillAlert();
    // }

    // Observe for changes
    _observeChanges();
  }


  @observable
  ObservableList<Invoice> invoiceList = ObservableList();

  @action
  void updateList(List<Invoice> list) {
    invoiceList.clear();
    invoiceList
        .addAll(list..sort((a, b) => -a.createdAt.compareTo(b.createdAt)));
  }


  
  void _observeChanges() {
    _getInvoiceList.observe().listen((event) {
      updateList(event);
    });
  }

  InvoiceSettingsStatus validateSettings() =>
      _validateInvoiceSettings.validate();
}
