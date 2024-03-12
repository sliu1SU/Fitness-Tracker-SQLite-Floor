import 'package:flutter/material.dart';

enum WidgetStyle {
  material,
  cupertino
}

class AppOptions {
  WidgetStyle widgetStyle;

  AppOptions(this.widgetStyle);
}