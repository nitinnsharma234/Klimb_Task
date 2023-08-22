import 'package:flutter/material.dart';
import 'package:location_task/AppData.dart';
import 'package:location_task/ViewModel.dart';
import 'package:location_task/device_profile_screen.dart';
import 'package:location_task/model/locationModel.dart';
import 'package:location_task/utils.dart';
import 'package:path/path.dart' as file;
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocationViewModel(),
      child: Builder(builder: (context) {
        final viewModel = Provider.of<LocationViewModel>(context, listen: true);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primarySwatch: viewModel.color,
              textTheme: TextTheme(
                  displayMedium: TextStyle(fontSize: viewModel.textSize))),
          home: const MyHomePage(
            title: "Foyer Task",
          ),
        );
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ///var model = LocationViewModel();

  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<LocationViewModel>(context, listen: false)
        .fetchDeviceProfiles();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    latitudeController.clear();
    longitudeController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        margin: const EdgeInsets.all(12),
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Container(
                    color: Colors.grey[200],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Image.asset("assets/images/map.png"),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "Location",
                                  style: TextStyle(color: Colors.blueAccent),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Consumer<LocationViewModel>(
                              builder: (context, model, _) {
                            return Expanded(
                              flex: 4,
                              child: RichText(
                                text: TextSpan(
                                  text: 'Latitude - ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.black),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text:
                                            "${model.latitude.abs().toStringAsFixed(2)}\u00B0${model.latitude.isNegative ? "S" : "N"}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ),
                            );
                          }),
                          Consumer<LocationViewModel>(
                            builder: (context, model, _) {
                              return Expanded(
                                flex: 4,
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Longitude - ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text:
                                              '${model.longitude.abs().toStringAsFixed(2)}\u00B0${model.longitude.isNegative ? "W" : "E"}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Input Latitude & Longitude",
                    style: Theme.of(context).textTheme.displayMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: customTextField(
                            label: "Latitude",
                            textEditingController: latitudeController),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: customTextField(
                            label: "Longitude",
                            textEditingController: longitudeController),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                            onPressed: () async {
                              if (latitudeController.text.isEmpty ||
                                  longitudeController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    getSnackBar("Fields cannot be empty"));
                                return;
                              }
                              double lat =
                                  double.parse(latitudeController.text);
                              double long =
                                  double.parse(longitudeController.text);

                              if (lat.abs() > 90) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    getSnackBar(
                                        "Enter a valid Latitude \n -90 to 90"));
                                return;
                              }
                              if (long.abs() > 180) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    getSnackBar(
                                        "Enter a valid Longitude \n -180 to 180"));
                                return;
                              }

                              var ans = await checkingDB(lat, long);

                              if (ans) {
                                _showAlertDialog(context, lat, long);
                              } else {
                                var db = await AppData().getDatabaseInstance();
                                List<Map<String, Object?>> ans = await db.query(
                                  'locations',
                                  columns: ["id"],
                                  where: 'latitude = ? AND longitude = ?',
                                  whereArgs: [lat, long],
                                );
                                var a = ans.first["id"];
                                List<Map<String, Object?>> ans2 =
                                    await db.query(
                                  'DeviceProfile',
                                  columns: ["themeColor", 'textSize'],
                                  where: 'id = ? ',
                                  whereArgs: [a],
                                );
                                print(ans2);
                                var p = ans2.first["themeColor"];
                                var d = ans2.first["textSize"] as double;
                                String s = p.toString();
                                print(
                                    "Lat & long is not Updating $lat and $long");
                                if (context.mounted) {
                                  Provider.of<LocationViewModel>(context,
                                          listen: false)
                                      .update(
                                          s.toMaterialColor(), d, lat, long);
                                }
                              }
                              latitudeController.clear();
                              longitudeController.clear();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 24.0),
                              child: Text(
                                "Enter",
                                style: TextStyle(fontSize: 16),
                              ),
                            ))),
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  Text(
                    maxLines: 2,
                    "Your Device Profiles",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Consumer<LocationViewModel>(
                    builder: (context, model, val) {
                      print(model.myList.length);
                      print("Halelnef");
                      if (model.list.isNotEmpty && model.loading == false) {
                        return Expanded(
                          // fit: FlexFit.loose,
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, idx) {
                              return Container(
                                color: Colors.blueGrey[200],
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                child: Column(children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: 'ThemeColor - ',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.black),
                                          children: <WidgetSpan>[
                                            WidgetSpan(
                                                child: Container(
                                              height: 10,
                                              width: 10,
                                              color: model.list[idx].themeColor
                                                  .toMaterialColor(),
                                            ))
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: 'Font Size - ',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.black),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    "${model.list[idx].textSize.toStringAsFixed(0)}px",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () async {
                                          final db = await AppData()
                                              .getDatabaseInstance();
                                          List<Map<String, dynamic?>> result =
                                              await db.query("locations",
                                                  where: 'id = ?',
                                                  whereArgs: [
                                                model.list[idx].id
                                              ]);
                                          LocationModel lm =
                                              LocationModel.fromMap(
                                                  result.first);
                                          Provider.of<LocationViewModel>(
                                                  context,
                                                  listen: false)
                                              .update(
                                                  model.list[idx].themeColor
                                                      .toMaterialColor(),
                                                  model.list[idx].textSize,
                                                  lm.latitude,
                                                  lm.longitude);
                                        },
                                        child: const Text("Apply Theme",
                                            style: TextStyle(fontSize: 12)),
                                      )),
                                ]),
                              );
                            },
                            itemCount: model.list.length,
                            shrinkWrap: true,
                          ),
                        );
                      }
                      if (model.list.isEmpty && model.loading == false) {
                        print("Band");
                        return Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "No Device Profile Found",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.redAccent,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Center(
                                    child: Image.asset(
                                  "assets/images/no-results.png",
                                  height: 200,
                                  width: 300,
                                ))
                              ]),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ] // Return an appropriate widget when the condition is not met]
                ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<bool> checkingDB(double latitude, double longitude) async {
    final db = await AppData().getDatabaseInstance();
    List<Map<String, Object?>> result = await db.rawQuery(
        "SELECT COUNT(*) as count FROM Locations WHERE latitude = ? AND longitude = ?",
        [latitude, longitude]);
    print("Result is $result");
    return result.first["count"] == 0;
  }

  Future<void> _showAlertDialog(
      BuildContext context, double lat, double long) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Image.asset(
                    "assets/images/alert.png",
                    fit: BoxFit.contain,
                  ),
                ),
                RichText(
                  text: const TextSpan(
                    text: '404  ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red),
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              'Location Not Found. Enter a new device profile settings.',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DeviceProfileScreen(
                          latitude: lat,
                          longitude: long,
                          callback: () {
                            Provider.of<LocationViewModel>(context,
                                    listen: false)
                                .fetchDeviceProfiles();
                          },
                        )));
              },
            ),
          ],
        );
      },
    );
  }
}

//1212
//12212
