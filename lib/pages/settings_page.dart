import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:workmanager/workmanager.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var delayList = ["1 hour", "2 hours", "4 hours", "8 hours", "1 day", "Don't update"];
  var minutesList = [60, 120, 240, 480, 1440, 0];
  final box = Hive.box("asurascans");
  
  @override
  Widget build(BuildContext context) {
    int idx = minutesList.indexOf(box.get("delay"));
    if(idx == -1) idx = 0;
    String? dropDown = delayList[idx];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        toolbarHeight: 60,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 8,),
              const Text("Update delay: ", style: TextStyle(fontSize: 16),),
              DropdownButton(
                items: delayList.map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(value),
                )).toList(),
                value: dropDown,
                onChanged: (value) {
                  setState(() {
                    dropDown = value;
                    box.put("delay", minutesList[(delayList.indexOf(value!))]);
                  });
                  if(box.get("delay") == 0) {
                    Workmanager().cancelByUniqueName("loadManga");
                  }
                  else {
                    Workmanager().registerPeriodicTask("loadManga", "loadManga",
                      frequency: Duration(minutes: box.get("delay")),
                      constraints: Constraints(networkType: NetworkType.connected, ),
                      existingWorkPolicy: ExistingWorkPolicy.replace,
                    );
                  }
                },
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 8,),
              const Text("Downloaded Image Quality: ", style: TextStyle(fontSize: 16),),
              SizedBox(
                width: 120,
                height: 60,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: "50",
                  decoration: InputDecoration(

                  ),
                  onChanged: (value) {
                    // change value
                  },
                  onSaved: (saved) {
                    // save value
                    print(saved);
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 8,),
              CupertinoButton(
                child: const Text("Update Library"),
                onPressed: () async {
                  Workmanager().registerOneOffTask("updateManga", "updateManga",
                  constraints: Constraints(networkType: NetworkType.connected),
                  existingWorkPolicy: ExistingWorkPolicy.replace);
                },
                color: Colors.blue,
              ),
            ],
          )
        ],
      ),
    );
  }
}
