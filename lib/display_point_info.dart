import 'package:fitness_tracker_sqlite_floor/point_record.dart';
import 'package:fitness_tracker_sqlite_floor/view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class DisplayPointInfo extends StatelessWidget {
  const DisplayPointInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // fetch data from db to populate diet history
    Future<PointRecord?> futurePointRecord = context.select<ViewModel, Future<PointRecord?>>(
            (viewModel) => viewModel.getLastPointRecord());
    return Center(
        child: FutureBuilder(
          future: futurePointRecord,
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              final pointRecord = snapshot.data!;
              return Wrap(
                children: [
                  Text("${AppLocalizations.of(context)!.point}: ${pointRecord.point} "),
                  Text("${AppLocalizations.of(context)!.level}: ${pointRecord.lvl} "),
                  Text("${AppLocalizations.of(context)!.type}: ${pointRecord.lastType} "),
                  Text("${AppLocalizations.of(context)!.date}: ${DateFormat().format(pointRecord.lastTimeUpdate)}"),
                ],
              );
            } else if (snapshot.hasError) {
              return Text(AppLocalizations.of(context)!.errorMsgFetching);
            } else {
              // display "-" for everything if no data returned
              return Wrap(
                children: [
                  Text("${AppLocalizations.of(context)!.point}: - "),
                  Text("${AppLocalizations.of(context)!.level}: - "),
                  Text("${AppLocalizations.of(context)!.type}: - "),
                  Text("${AppLocalizations.of(context)!.date}: - "),
                ],
              );
            }
          }
        )
    );
  }
}