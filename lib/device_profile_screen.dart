import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:location_task/utils.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'AppData.dart';
import 'ViewModel.dart';
import 'model/locationModel.dart';

class DeviceProfileScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final Function callback;

  const DeviceProfileScreen(
      {Key? key, required this.latitude, required this.longitude,required this.callback})
      : super(key: key);

  @override
  State<DeviceProfileScreen> createState() => _DeviceProfileScreenState();
}

class _DeviceProfileScreenState extends State<DeviceProfileScreen> {
  String id = "";
  String setting_id = "";

  Future<bool> checkingDB() async {
    final db = await AppData().getDatabaseInstance();
    var result1 = await db.query("DeviceProfile");
    print(result1);
    List<Map<String, Object?>> result = await db.rawQuery(
        "SELECT COUNT(*) as count FROM DeviceProfile WHERE themeColor = ? AND textSize = ?",
        [toStr(myColor.toString()), _value]);
    print("Result is $result");

    print(result.first["count"] == 0);
    return result.first["count"] == 0;
  }

  Future<bool> insertLatAndLong() async {
    try {
      var db = await AppData().getDatabaseInstance();
      if (id.isEmpty) {
        id = Uuid().v4();
        var lm = LocationModel(
                id: id, latitude: widget.latitude, longitude: widget.longitude)
            .toMap();
        await db.insert("locations", lm,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      if (setting_id.isEmpty) {
        setting_id = const Uuid().v4();
      }
      await db.insert(
        'DeviceProfile',
        {
          "setting_id": setting_id,
          "id": id,
          "themeColor": toStr(myColor.toString()),
          "textSize": _value
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );


    } catch (err) {
      return Future.value(false);
    }
    return Future.value(true);
  }

  double _value = 10;
  Color myColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Device Profile"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ColorPicker(
                pickerColor: myColor,
                onColorChanged: (color) {
                  myColor = color;
                },
                paletteType: PaletteType.hsv,
              ),
              const SizedBox(
                height: 100,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: CupertinoSlider(
                      min: 0.0,
                      max: 100.0,
                      value: _value,
                      onChanged: (value) {
                        setState(() {
                          _value = value;
                        });
                      },
                    ),
                  ),
                  Expanded(child: Center(child: Text("${_value.ceil()} px")))
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 16),
                child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                        onPressed: () async {
                          bool exist = await checkingDB();
                          if (exist) {
                            await insertLatAndLong().then((value) {
                              if (value) {
                                widget.callback();
                                Navigator.of(context).pop();
                              }
                            });
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                                "Device Profile exists!"));
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Text(
                            "Save Settings",
                            style: TextStyle(fontSize: 16),
                          ),
                        ))),
              )
            ],
          ),
        ));
  }
}

String toStr(String str) {
  int len = str.length;
  print(str.substring(8, len - 1));
  return str.substring(8, len - 1);
}

