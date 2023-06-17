import 'package:injectable/injectable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invoice_app/src/core/data/models/hive_client_info.dart';
import 'package:invoice_app/src/core/data/models/hive_company_info.dart';
import 'package:invoice_app/src/core/data/models/hive_bank_info.dart';
import 'package:invoice_app/src/core/data/models/hive_invoice.dart';
import 'package:invoice_app/src/core/data/models/hive_invoice_list.dart';
import 'package:invoice_app/src/core/data/models/hive_service_info.dart';
import 'package:invoice_app/src/core/domain/data_models/invoice.dart';

const _appBoxName = 'AppBox';
const _keyCompanyInfo = 'companyInfo';
const _keyBankInfo = 'bankInfo';
const _keyServiceInfo = 'serviceInfo';
const _keyClientInfo = 'clientInfo';
const _keyInvoiceList = 'invoiceList';
const _keyOnboardingStatus = 'onboardingStatus';
const _keyInfoAlertStatus = 'infoAlertStatus';

abstract class ILocalDataSource {
  Future initLocalDataSource();

  HiveCompanyInfo? getCompanyInfo();

  HiveBankInfo? getBankInfo();

  HiveServiceInfo? getServiceInfo();

  HiveClientInfo? getClientInfo();

  List<Invoice> getInvoiceList();

  bool getOnboardingStatus();

  bool getInfoAlertStatus();

  Future<void> saveClientInfo(HiveClientInfo value);

  Future<void> saveCompanyInfo(HiveCompanyInfo value);

  Future<void> saveBankInfo(HiveBankInfo value);

  Future<void> saveServiceInfo(HiveServiceInfo value);

  Future<void> saveInvoice(Invoice invoice);

  Future<void> saveOnboardingStatus(bool status);

  Future<void> saveInfoAlertStatus(bool status);

  Stream<List<Invoice>> observeInvoiceList();
}

@Singleton(as: ILocalDataSource)
class LocalDataSource implements ILocalDataSource {
  late Box _appBox;

  @override
  Future initLocalDataSource() async {
    await Hive.initFlutter();
    Hive.registerAdapter(HiveCompanyInfoAdapter());
    Hive.registerAdapter(HiveBankInfoAdapter());
    Hive.registerAdapter(HiveServiceInfoAdapter());
    Hive.registerAdapter(HiveClientInfoAdapter());
    Hive.registerAdapter(HiveInvoiceAdapter());
    Hive.registerAdapter(HiveInvoiceListAdapter());

    _appBox = await _getAppBox();
  }

  Future<Box> _getAppBox() async => await Hive.openBox(_appBoxName);

  @override
  HiveCompanyInfo? getCompanyInfo() => _appBox.get(_keyCompanyInfo);

  @override
  HiveBankInfo? getBankInfo() => _appBox.get(_keyBankInfo);

  @override
  HiveServiceInfo? getServiceInfo() => _appBox.get(_keyServiceInfo);

  @override
  HiveClientInfo? getClientInfo() => _appBox.get(_keyClientInfo);

  @override
  bool getInfoAlertStatus() => _appBox.get(_keyInfoAlertStatus, defaultValue: false);

  @override
  List<Invoice> getInvoiceList() {
    HiveInvoiceList hiveInvoiceList =
        _appBox.get(_keyInvoiceList, defaultValue: HiveInvoiceList([]));

    return hiveInvoiceList.invoiceList.map((e) => e.toInvoice()).toList();
  }

  @override
  Future<void> saveCompanyInfo(HiveCompanyInfo value) =>
      _appBox.put(_keyCompanyInfo, value);

  @override
  Future<void> saveBankInfo(HiveBankInfo value) =>
      _appBox.put(_keyBankInfo, value);

  @override
  Future<void> saveServiceInfo(HiveServiceInfo value) =>
      _appBox.put(_keyServiceInfo, value);

  @override
  Future<void> saveClientInfo(HiveClientInfo value) =>
      _appBox.put(_keyClientInfo, value);

  @override
  Future<void> saveInvoice(Invoice invoice) async {
    var hiveList = getInvoiceList();
    hiveList.add(invoice);

    return _appBox.put(
      _keyInvoiceList,
      HiveInvoiceList(
        hiveList.map((e) => HiveInvoice.fromInvoice(e)).toList(),
      ),
    );
  }

  @override
  Stream<List<Invoice>> observeInvoiceList() {
    //TODO: how to emit value on each subscribe? stream.startWith ??
    return _appBox.watch(key: _keyInvoiceList).map((event) {
      HiveInvoiceList listObj = event.value;
      return listObj.invoiceList.map((e) => e.toInvoice()).toList();
    });
  }

  @override
  bool getOnboardingStatus() => _appBox.get(_keyOnboardingStatus) ?? false;

  @override
  Future<void> saveOnboardingStatus(bool status) =>
      _appBox.put(_keyOnboardingStatus, status);

  @override
  Future<void> saveInfoAlertStatus(bool status) =>
      _appBox.put(_keyInfoAlertStatus, status);
}
