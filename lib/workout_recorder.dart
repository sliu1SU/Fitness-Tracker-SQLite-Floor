import 'package:fitness_tracker_sqlite_floor/view_model.dart';
import 'package:fitness_tracker_sqlite_floor/workout_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'app_options.dart';

class WorkoutRecorder extends StatefulWidget {
  // constructor
  const WorkoutRecorder({super.key});

  @override
  State<WorkoutRecorder> createState() => _WorkoutRecorder();
}

class _WorkoutRecorder extends State<WorkoutRecorder> {
  String? selectedWorkout;
  final TextEditingController numController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> workouts = [
    'Bench press',
    'Cycling',
    'Pullup',
    'Pushups',
    'Pulldown',
    'Swimming',
    'Bicep curls',
    'Running'
  ];
  int workoutIdx = 0;

  @override
  void initState() {
    super.initState();
    if (context.read<AppOptions>().widgetStyle == WidgetStyle.cupertino) {
      setState(() {
        selectedWorkout = workouts[0];
      });
    }
  }

  // create a function here
  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      DateTime curDatetime = DateTime.now();
      WorkoutEvent event = WorkoutEvent(
        null,
        selectedWorkout!,
        int.parse(numController.text),
        curDatetime,
        0,
      );
      context.read<ViewModel>().addOneWorkoutEvent(event);
      _formKey.currentState!.reset();
      // need to do manual reset because of TextFormField bug
      numController.clear();
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

    // fetch data from db to populate emo history
    Future<List<WorkoutEvent>> futureWorkoutEvents = context.select<ViewModel, Future<List<WorkoutEvent>>>(
            (viewModel) => viewModel.getAllWorkoutEvents()
    );

    // apple version
    if (appOptions.widgetStyle == WidgetStyle.cupertino) {
      return SingleChildScrollView(
          child: Column(
              children: [
                Form(
                  key:_formKey,
                  child: Column(
                    children: [
                      // ios picker
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppLocalizations.of(context)!.exercise),
                              CupertinoButton(
                                onPressed: () => _showDialog(
                                  CupertinoPicker(
                                    magnification: 1.22,
                                    squeeze: 1.2,
                                    useMagnifier: true,
                                    itemExtent: 32.0,
                                    // This sets the initial item.
                                    scrollController: FixedExtentScrollController(
                                      initialItem: workoutIdx,
                                    ),
                                    // This is called when selected item is changed.
                                    onSelectedItemChanged: (int selectedItem) {
                                      setState(() {
                                        workoutIdx = selectedItem;
                                        selectedWorkout = workouts[selectedItem];
                                      });
                                    },
                                    children:
                                    List<Widget>.generate(workouts.length, (int index) {
                                      return Center(child: Text(workouts[index]));
                                    }),
                                  ),
                                ),
                                // This displays the selected fruit name.
                                child: Text(
                                  workouts[workoutIdx],
                                  style: const TextStyle(
                                    fontSize: 22.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // quantity textfield
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: CupertinoTextFormFieldRow(
                          prefix: Text(AppLocalizations.of(context)!.unit),
                          controller: numController,
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

                // print a list of workout and dates
                FutureBuilder(
                    future: futureWorkoutEvents,
                    builder: (context, snapshot) {
                      if(snapshot.hasData) {
                        final events = snapshot.data!;
                        return Column(
                          children: events.map((event) => CupertinoFormRow(
                            prefix: Column(
                              children: [
                                Wrap(
                                  children: [
                                    Text(event.workout),
                                    const SizedBox(width: 5),
                                    Text("${event.unit}"),
                                  ],
                                ),
                                Wrap(
                                  children: [
                                    Text(DateFormat().format(event.date)),
                                  ],
                                ),
                              ],
                            ),
                            child: Wrap(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    context.read<ViewModel>().deleteOneWorkoutEventById(event.id!);
                                  },
                                  icon: const Icon(CupertinoIcons.delete),
                                  color: Colors.red,
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
              Form(
                key:_formKey,
                child: Column(
                  children: [
                    // exercise dropdown
                    Text(
                      AppLocalizations.of(context)!.exercise,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: DropdownButtonFormField(
                        key: const Key("workoutDropdown"),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.selectAValue,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        //value: _selectedWorkout,
                        // array list item
                        items: workouts.map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item, style: const TextStyle(fontSize: 15)),
                        )).toList(),
                        // onchange function to capture user selection
                        onChanged: (String? newVal) {
                          setState(() {
                            selectedWorkout = newVal;
                          });
                        },
                        validator: (selectedWorkout) {
                          if (selectedWorkout == null) {
                            return AppLocalizations.of(context)!.errorMsgDropdown;
                          }
                          return null;
                        },
                      ),
                    ),

                    // quantity textfield
                    Text(
                      AppLocalizations.of(context)!.unit,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: TextFormField(
                        key: const Key("workoutUnitTextInput"),
                        controller: numController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: AppLocalizations.of(context)!.dietHintTextUnit,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              // clear the text box
                              numController.clear();
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
                    ),

                    // submit button
                    ElevatedButton(
                      key: const Key("workoutSubmitBt"),
                      onPressed: () {
                        _onSavePressed();
                      },
                      // child - put something in the button, EX: save
                      child: Text(AppLocalizations.of(context)!.save),
                    ),
                  ],
                ),
              ),

              // print a list of emojis and dates
              FutureBuilder(
                  future: futureWorkoutEvents,
                  builder: (context, snapshot) {
                    if(snapshot.hasData) {
                      final workoutEvents = snapshot.data!;
                      return Column(
                        children: workoutEvents.map((event) => Wrap(
                          children: [
                            Column(
                              children: [
                                Wrap(children: [
                                  Text("${event.workout}  "),
                                  Text("${event.unit}  "),
                                ],),
                                Wrap(
                                  children: [
                                    Text("${DateFormat().format(event.date)}  "),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                context.read<ViewModel>().deleteOneWorkoutEventById(event.id!);
                              },
                              icon: const Icon(Icons.delete),
                              color: Colors.red,
                            )
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
        )
    );
  }
}