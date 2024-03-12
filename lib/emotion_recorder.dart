import 'package:fitness_tracker_sqlite_floor/view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_options.dart';
import 'emotion_event.dart';
import 'package:flutter/cupertino.dart';

class EmotionRecorder extends StatefulWidget {
  // constructor
  const EmotionRecorder({super.key});

  @override
  State<EmotionRecorder> createState() => _EmotionRecorder();
}

class _EmotionRecorder extends State<EmotionRecorder> {
  // data structure to store all 24 hard-coded emoji
  final List<String> emojis = [
    "😀",
    "😍",
    "🥳",
    "🚀",
    "🌟",
    "🎉",
    "🎈",
    "🐱",
    "🐶",
    "🌺",
    "🍕",
    "🍦",
    "🎸",
    "🎮",
    "🚗",
    "🌈",
    "❤️",
    "💡",
    "📚",
    "⚽",
    "🎨",
    "🍔",
    "🚲",
  ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedValue;
  int emojiIdx = 0; // this is for cupertino

  // cupertino picker can not be null as initial state! so you will need
  // to manually set the dropdownitem state to be the initial value in
  // cupertino picker!
  @override
  void initState() {
    super.initState();
    if (context.read<AppOptions>().widgetStyle == WidgetStyle.cupertino) {
      setState(() {
        selectedValue = emojis[0];
      });
    }
  }

  void _onSavePressed() {
    // create an emoji event and add it to the list for rendering
    if (_formKey.currentState!.validate()) {
      EmotionEvent event = EmotionEvent(
        null,
        selectedValue!,
        DateTime.now(),
        0,
      );
      context.read<ViewModel>().addOneEmotionEvent(event);
      _formKey.currentState!.reset();
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
    Future<List<EmotionEvent>> futureEmotionEvents = context.select<ViewModel, Future<List<EmotionEvent>>>(
            (viewModel) => viewModel.getAllEmotionEvents()
    );

    // apple version
    if (appOptions.widgetStyle == WidgetStyle.cupertino) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                  children: [
                    // ios picker
                    //Text(AppLocalizations.of(context)!.selectAnEmoji),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!.selectAnEmoji),
                            CupertinoButton(
                              onPressed: () => _showDialog(
                                CupertinoPicker(
                                  magnification: 1.22,
                                  squeeze: 1.2,
                                  useMagnifier: true,
                                  itemExtent: 32.0,
                                  // This sets the initial item.
                                  scrollController: FixedExtentScrollController(
                                    initialItem: emojiIdx,
                                  ),
                                  // This is called when selected item is changed.
                                  onSelectedItemChanged: (int selectedItem) {
                                    setState(() {
                                      emojiIdx = selectedItem;
                                      selectedValue = emojis[selectedItem];
                                    });
                                  },
                                  children:
                                  List<Widget>.generate(emojis.length, (int index) {
                                    return Center(child: Text(emojis[index]));
                                  }),
                                ),
                              ),
                              // This displays the selected fruit name.
                              child: Text(
                                emojis[emojiIdx],
                                style: const TextStyle(
                                  fontSize: 22.0,
                                ),
                              ),
                            ),
                          ],
                        ),
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

            // print a list of emojis and dates history
            FutureBuilder(
                future: futureEmotionEvents,
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    final emotionEvents = snapshot.data!;
                    return Column(
                      children: emotionEvents.map((event) => CupertinoFormRow(
                        prefix: Wrap(
                          children: [
                            Text(event.emoji),
                            const SizedBox(width: 5),
                            Text(DateFormat().format(event.date)),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            context.read<ViewModel>().deleteOneEmotionEventById(event.id!);
                          },
                          icon: const Icon(CupertinoIcons.delete),
                          color: Colors.red,
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
          ],
        ),
      );
    }

    // android version
    return SingleChildScrollView(
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                // drop down button
                Text(AppLocalizations.of(context)!.selectAnEmoji),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: DropdownButtonFormField(
                    key: const Key("emojiDropdown"),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.selectAValue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    //value: selectedValue,
                    // array list item
                    items: emojis.map((item) => DropdownMenuItem<String>(
                      key: const Key("dietHistoryDropdownItem"),
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 20)),
                    )).toList(),
                    // onchange function to capture user selection
                    onChanged: (String? newValue) {
                      // logging user input
                      setState(() {
                        selectedValue = newValue;
                      });
                    },
                    validator: (newVal) {
                      if (selectedValue == null) {
                        return AppLocalizations.of(context)!.errorMsgDropdown;
                      }
                      return null;
                    },
                  ),
                ),

                // submit button
                ElevatedButton(
                  key: const Key("emojiSubmitBt"),
                  onPressed: _onSavePressed,
                  // child - put something in the button, EX: save
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            ),
          ),

          // print a list of emojis and dates history
          FutureBuilder(
              future: futureEmotionEvents,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  final emotionEvents = snapshot.data!;
                  return Column(
                    children: emotionEvents.map((event) => Row(
                      children: [
                        Text("${event.emoji}  "),
                        Text("${DateFormat().format(event.date)}  "),
                        IconButton(
                          onPressed: () {
                            context.read<ViewModel>().deleteOneEmotionEventById(event.id!);
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
        ],
      ),
    );
  }
}