import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_options.dart';
import 'main.dart';

class SettingPage extends StatefulWidget {
  // constructor
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> {
  String? dropdownLocale;
  String? dropdownStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // locale dropdown
              const Text(
                'Select Language:',
                style: TextStyle(fontSize: 18),
              ),
              DropdownButton<String>(
                value: dropdownLocale,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? value) {
                // This is called when the user selects an item.
                  setState(() {
                    dropdownLocale = value!;
                    //MyApp.setLocale(context, Locale(value));
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: 'en',
                    child: Text('EN'),
                  ),
                  DropdownMenuItem(
                    value: 'es',
                    child: Text('ES'),
                  ),
                ],
              ),

              // style dropdown
              const Text(
                'Select Style:',
                style: TextStyle(fontSize: 18),
              ),
              DropdownButton<String>(
                value: dropdownStyle,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    dropdownStyle = value!;
                    if (value == 'cupertino') {
                      context.read<AppOptions>().widgetStyle = WidgetStyle.cupertino;
                    } else {
                      context.read<AppOptions>().widgetStyle = WidgetStyle.material;
                    }
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: 'cupertino',
                    child: Text('cupertino'),
                  ),
                  DropdownMenuItem(
                    value: 'material',
                    child: Text('material'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ]
    );
  }
}