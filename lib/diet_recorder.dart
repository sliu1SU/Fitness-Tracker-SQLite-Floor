import 'package:fitness_tracker_sqlite_floor/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_options.dart';
import 'diet_event.dart';
import 'diet_recorder_edit_form.dart';

class DietRecorder extends StatefulWidget {
  const DietRecorder({super.key});

  @override
  State<DietRecorder> createState() => _DietRecorder();
}

class _DietRecorder extends State<DietRecorder> {
  String? dropdown;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController dietInputController = TextEditingController();
  final TextEditingController unitInputController = TextEditingController();
  final TextEditingController editValController = TextEditingController();
  Set<String> dietHistory = {};
  List<String> dietHistoryArr = [];
  int i = 0;

  @override
  void initState() {
    super.initState();
    fetchDietHistory().then((value) {
      if (context.read<AppOptions>().widgetStyle == WidgetStyle.cupertino) {
        // when its apple UI and arr is not empty, you have to init dropdown with
        // the 1st element in the list
        if (dietHistory.isNotEmpty) {
          print('succeed!!');
          setState(() {
            dropdown = dietHistoryArr[0];
          });
        }
      }
    });
  }

  // create a function here
  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      DateTime curDatetime = DateTime.now();
      if (dietInputController.text.isNotEmpty) {
        // user text input higher priority
        DietEvent event = DietEvent(
          null,
          dietInputController.text,
          int.parse(unitInputController.text),
          curDatetime,
          0,
        );
        dietHistory.add(dietInputController.text);
        dietHistoryArr = dietHistory.toList();
        dropdown = dietHistoryArr[i]; // for cupertino, set dropdown to not NULL
        context.read<ViewModel>().addOneDietEvent(event);
      } else {
        // user did not enter new food in text box, choose from history instead
        DietEvent event = DietEvent(
          null,
          dropdown!,
          int.parse(unitInputController.text),
          curDatetime,
          0,
        );
        context.read<ViewModel>().addOneDietEvent(event);
      }
      _formKey.currentState!.reset();
      print('checking if state has been reset... dropdown = $dropdown');
      // need to do manual reset coz of TextFormField bug
      dietInputController.clear();
      unitInputController.clear();
    }
  }

  Future<void> fetchDietHistory() async {
    try {
      // Fetch diet events from the database
      List<DietEvent> dietEvents = await context.read<ViewModel>().getAllDietEvents();
      // Extract diet names from diet events and update the diet history set and array
      setState(() {
        dietHistory = dietEvents.map((event) => event.diet).toSet();
        if (dietHistory.isNotEmpty) {
          dietHistoryArr = dietHistory.toList();
        }
      });
    } catch (e) {
      print('Error fetching diet history: $e');
    }
  }

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appOptions = context.watch<AppOptions>();
    // fetch data from db to populate diet history
    Future<List<DietEvent>> futureDietEvents = context.select<ViewModel, Future<List<DietEvent>>>(
            (viewModel) => viewModel.getAllDietEvents()
    );

    // apple version
    if (appOptions.widgetStyle == WidgetStyle.cupertino) {
      return SingleChildScrollView(
          child: Column(
              children: [
                // form widget to handle user inputs
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // diet text input
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: CupertinoTextFormFieldRow(
                          prefix: Text(AppLocalizations.of(context)!.enterADiet),
                          controller: dietInputController,
                          placeholder: AppLocalizations.of(context)!.dietHintTextDiet,
                          keyboardType: TextInputType.text,
                          validator: (newValue) {
                            if (dropdown == null && (newValue == null || newValue.isEmpty)) {
                              return AppLocalizations.of(context)!.errorMsgDietTextInput;
                            }
                            return null;
                          },
                        ),
                      ),

                      if(dietHistoryArr.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppLocalizations.of(context)!.previousDiets),
                                CupertinoButton(
                                  onPressed: () => _showDialog(
                                    CupertinoPicker(
                                      magnification: 1.22,
                                      squeeze: 1.2,
                                      useMagnifier: true,
                                      itemExtent: 32.0,
                                      // This sets the initial item.
                                      scrollController: FixedExtentScrollController(
                                        initialItem: i,
                                      ),
                                      // This is called when selected item is changed.
                                      onSelectedItemChanged: (int selectedItem) {
                                        setState(() {
                                          i = selectedItem;
                                          dropdown = dietHistoryArr[selectedItem];
                                        });
                                      },
                                      children:
                                      List<Widget>.generate(dietHistoryArr.length, (int index) {
                                        return Center(child: Text(dietHistoryArr[index]));
                                      }),
                                    ),
                                  ),
                                  // This displays the selected fruit name.
                                  child: Text(
                                    dietHistoryArr[i],
                                    style: const TextStyle(
                                      fontSize: 22.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // unit text input
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: CupertinoTextFormFieldRow(
                          prefix: Text(AppLocalizations.of(context)!.unit),
                          controller: unitInputController,
                          placeholder: AppLocalizations.of(context)!.dietHintTextUnit,
                          keyboardType: TextInputType.number,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)!.errorMsgDietUnitInput;
                            }
                            return null;
                          },
                        ),
                      ),

                      // submit button
                      CupertinoButton.filled(
                        onPressed: _onSavePressed,
                        // child - put something in the button, EX: save
                        child: Text(AppLocalizations.of(context)!.save),
                      ),
                    ],
                  ),
                ),

                // column widget to print a list of food and dates history
                FutureBuilder(
                    future: futureDietEvents,
                    builder: (context, snapshot) {
                      if(snapshot.hasData) {
                        final events = snapshot.data!;
                        return Column(
                          children: events.map((event) => CupertinoFormRow(
                            prefix: Column(
                              children: [
                                Wrap(
                                  children: [Text(event.diet),
                                    const SizedBox(width: 5),
                                    Text("${event.unit}"),],
                                ),
                                Wrap(children: [
                                  Text(DateFormat().format(event.date)),
                                ],),
                              ],
                            ),
                            child: Wrap(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    context.read<ViewModel>().deleteOneDietEventById(event.id!);
                                  },
                                  icon: const Icon(CupertinoIcons.delete),
                                  color: Colors.red,
                                ),
                                IconButton(
                                  icon: const Icon(CupertinoIcons.create),
                                  color: Colors.black,
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return DietRecorderEditForm(event);
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          )).toList(),
                        );
                      } else if (snapshot.hasError) {
                        return Text(AppLocalizations.of(context)!.errorMsgFetching);
                      } else {
                        return const Center(
                          child: CupertinoActivityIndicator(
                              radius: 20.0, color: CupertinoColors.activeBlue),
                        );
                      }
                    }
                ),
            ]
        )
    );
  }

    // android version
    return SingleChildScrollView(
        child: Column(
            children: [
              // form widget to handle user inputs
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // diet text input
                    Text(AppLocalizations.of(context)!.enterADiet, style: const TextStyle(fontSize: 15),),
                    TextFormField(
                      key: const Key("dietFoodInput"),
                      controller: dietInputController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: AppLocalizations.of(context)!.dietHintTextDiet,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            // clear the text box
                            dietInputController.clear();
                          },
                        ),
                      ),
                      validator: (newValue) {
                        if (dropdown == null && (newValue == null || newValue.isEmpty)) {
                          return AppLocalizations.of(context)!.errorMsgDietTextInput;
                        }
                        return null;
                      },
                    ),

                    // dropdown menu
                    if(dietHistory.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(AppLocalizations.of(context)!.previousDiets, style: const TextStyle(fontSize: 15),),
                            DropdownButtonFormField(
                              key: const Key("dietDropdown"),
                              //style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!.selectAValue,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              items: dietHistory.map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item, style: const TextStyle(fontSize: 10)),
                                );
                              }).toList(),
                              onChanged: (String? newVal) {
                                setState(() {
                                  dropdown = newVal;
                                });
                              },
                              validator: (newValue) {
                                if (dietInputController.text.isEmpty
                                    && dropdown == null) {
                                  return AppLocalizations.of(context)!.errorMsgDietDropdown;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                    // unit text input
                    Text(AppLocalizations.of(context)!.unit, style: const TextStyle(fontSize: 15),),
                    TextFormField(
                      key: const Key("dietUnitInput"),
                      controller: unitInputController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: AppLocalizations.of(context)!.dietHintTextUnit,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            // clear the text box
                            unitInputController.clear();
                          },
                        ),
                      ),
                      validator: (newValue) {
                        if (newValue == null || newValue.isEmpty) {
                          return AppLocalizations.of(context)!.errorMsgDietUnitInput;
                        }
                        return null;
                      },
                    ),

                    // submit button
                    ElevatedButton(
                        key: const Key("dietSubmitBt"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.black87,
                        ),
                        onPressed: _onSavePressed,
                        // child - put something in the button, EX: save
                        child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(fontWeight: FontWeight.bold),)
                    ),
                  ],
                ),
              ),

              // column widget to print a list of food and dates history
              FutureBuilder(
                  future: futureDietEvents,
                  builder: (context, snapshot) {
                    if(snapshot.hasData) {
                      final dietEvents = snapshot.data!;
                      return Column(
                        children: dietEvents.map((event) => Wrap(
                          children: [
                            Column(
                              children: [
                                Wrap(
                                  children: [
                                    Text(event.diet),
                                    const SizedBox(width: 5),
                                    Text("${event.unit}"),],
                                ),
                                Wrap(
                                  children: [
                                    Text(DateFormat().format(event.date)),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                context.read<ViewModel>().deleteOneDietEventById(event.id!);
                              },
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                            ),
                            IconButton(
                              icon: const Icon(Icons.create),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return DietRecorderEditForm(event);
                                  },
                                );
                              },
                            ),
                          ],
                        )).toList(),
                      );
                    } else if (snapshot.hasError) {
                      return Text(AppLocalizations.of(context)!.errorMsgFetching);
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }
              ),
            ]
        ),
    );
  }
}