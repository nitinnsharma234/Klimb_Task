import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location_task/model/locationModel.dart';
import 'package:location_task/model/profileModel.dart';

import 'AppData.dart';

class LocationViewModel  with ChangeNotifier{

double  textSize=16;
double  latitude=0.00;
double  longitude=0.00;
bool loading=false;
List<ProfileModel>  list=[];

get myList{

  return list;
}
MaterialColor color=Colors.primaries.last;

void update(MaterialColor colour,double size,double lat, double long){
  textSize=size;
   latitude=lat;
   longitude=long;
  color=colour;
  notifyListeners();
}

  Future<void> fetchDeviceProfiles() async {
    loading=true;
    notifyListeners();
    // To get some seconds of loading delay
  await  Future.delayed(const Duration(seconds: 2));

  list.clear();

     var db = await AppData().getDatabaseInstance();
     var result = await db.query("DeviceProfile");

     for (var element in result) {
       ProfileModel profile=ProfileModel.fromMap(element);
       list.add(profile);
     }

     loading=false;
     notifyListeners();
  }

}