import 'package:fitness_tracker_sqlite_floor/view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'diet_event.dart';

class DietRecorderEditForm extends StatefulWidget {
  final DietEvent event;
  const DietRecorderEditForm(this.event, {super.key});

  @override
  createState() => _DietRecorderEditForm();
}

class _DietRecorderEditForm extends State<DietRecorderEditForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _inputController = TextEditingController();

  @override
  initState() {
    super.initState();
    _inputController.text = '${widget.event.unit}';
  }

  _onSave() {
    if (_formKey.currentState!.validate()) {
      context.read<ViewModel>().updateOneDietEvent(widget.event.id!, int.parse(_inputController.text));
      _formKey.currentState!.reset();
      _inputController.clear(); // another case where key.reset does not reset!
      Navigator.of(context).pop(); // close the bottom sheet via pop
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _inputController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // clear the text box
                    _inputController.clear();
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
            ElevatedButton(
              onPressed: _onSave,
              child: Text(AppLocalizations.of(context)!.save),
            )
          ],
        )
    );
  }
}