import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LocaleOptions with ChangeNotifier{
  Locale _curLocale;

  LocaleOptions(this._curLocale);

  Locale getCurLocale() {
    return _curLocale;
  }

  void changeLanguage(Locale locale) {
    _curLocale = locale;
    notifyListeners();
  }
}