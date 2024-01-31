import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kp_trans/authentication/login_screen.dart';
import 'package:kp_trans/global/global_var.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kp_trans/methods/common_methods.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;

  CommonMethods cMethods = CommonMethods();

  Position? CurrentPositionOfUser;

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  void updateMapTheme(GoogleMapController controller) {
    getJsonFileFromThemes("themes/night_style.json")
        .then((value) => setGoogleMapStyle(value, controller));
  }

  Future<String> getJsonFileFromThemes(String mapStlyePath) async {
    ByteData byteData = await rootBundle.load(mapStlyePath);

    var list = byteData.buffer
        .asInt8List(byteData.offsetInBytes, byteData.lengthInBytes);
    return utf8.decode(list);
  }

  setGoogleMapStyle(String googleMapStyle, GoogleMapController controller) {
    controller.setMapStyle(googleMapStyle);
  }

  getCurrentLiveLocationOfUser() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    CurrentPositionOfUser = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(
        CurrentPositionOfUser!.latitude, CurrentPositionOfUser!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: positionOfUserInLatLng, zoom: 17);
    controllerGoogleMap!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    await getUserInfoAndBlockStatus();
  }

  getUserInfoAndBlockStatus() async {
    DatabaseReference usersRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        if ((snap.snapshot.value as Map)["blockstatus"] == "no") {
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
          });

          // Navigator.push(
          //     context, MaterialPageRoute(builder: (c) => HomePage()));
        } else {
          FirebaseAuth.instance.signOut();
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => LoiginScreen()));
          cMethods.displaySnackBar(
              "user is blocked :contact admin@gmail.com ", context);
        }
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => LoiginScreen()));
        // cMethods.displaySnackBar("user does not exist", context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: Container(
        width: 255,
        color: Colors.black87,
        child: Drawer(
          backgroundColor: Colors.white10,
          child: ListView(
            children: [
              // header

              Container(
                color: Colors.black,
                height: 160,
                child: DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/avatarman.png",
                        width: 60,
                        height: 60,
                      ),

                      // const Icon(
                      //   Icons.person,
                      //   size: 60,
                      // ),
                      const SizedBox(
                        width: 16,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "profile",
                            style: TextStyle(color: Colors.white10),
                          ),
                          // Text(
                          //   userName,
                          //   style: const TextStyle(
                          //       fontSize: 16, fontWeight: FontWeight.bold),
                          // ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const Divider(
                height: 1,
                color: Colors.white,
                thickness: 1,
              ),

              const SizedBox(
                height: 10,
              ),

//body
              ListTile(
                leading: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.info,
                    color: Colors.grey,
                  ),
                ),
                title: const Text(
                  "About",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => LoiginScreen()));
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.grey,
                    ),
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      //
      //googlemap
      body: Stack(
        children: [
          GoogleMap(
            padding: const EdgeInsets.only(top: 26),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;

              updateMapTheme(controllerGoogleMap!);

              googleMapCompleterController.complete(controllerGoogleMap);

              getCurrentLiveLocationOfUser();
            },
          ),
          Positioned(
              top: 42,
              left: 19,
              child: GestureDetector(
                onTap: () {
                  sKey.currentState!.openDrawer();
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7))
                      ]),
                  child: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 20,
                    child: Icon(
                      Icons.menu,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
