import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jitsi_meet/feature_flag/feature_flag_enum.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:jitsi_meet/jitsi_meeting_listener.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Conference App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  TextEditingController _codeController = TextEditingController();
  TextEditingController _namaController = TextEditingController();
  FocusNode _codeNode = FocusNode();
  FocusNode _nameNode = FocusNode();

  bool _isSoundOn = true;
  bool _isCameraOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(
              20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nickname"),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  controller: _namaController,
                  focusNode: _nameNode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan Nickname Kamu',
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text("Meeting ID"),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  controller: _codeController,
                  focusNode: _codeNode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Insert Meeting ID',
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                CheckboxListTile(
                    title: Text("Sound"),
                    value: _isSoundOn,
                    onChanged: (checkedStatus) {
                      setState(() {
                        _isSoundOn = checkedStatus;
                      });
                    }),
                SizedBox(
                  height: 8,
                ),
                CheckboxListTile(
                  title: Text("Camera"),
                  value: _isCameraOn,
                  onChanged: (checkedStatus) {
                    setState(() {
                      _isCameraOn = checkedStatus;
                    });
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text("Join"),
                    onPressed: _joinRoom,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _joinRoom() async {
    try {
      // Enable or disable any feature flag here
      // If feature flag are not provided, default values will be used
      // Full list of feature flags (and defaults) available in the README
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        FeatureFlagEnum.INVITE_ENABLED: false
      };

      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions()
        ..room = _codeController.text
        ..userDisplayName = _namaController.text
        ..audioMuted = !_isSoundOn
        ..videoMuted = !_isCameraOn;

      debugPrint("JitsiMeetingOptions: $options");
      await JitsiMeet.joinMeeting(
        options,
        listener: JitsiMeetingListener(onConferenceWillJoin: ({message}) {
          debugPrint("${options.room} will join with message: $message");
        }, onConferenceJoined: ({message}) {
          debugPrint("${options.room} joined with message: $message");
        }, onConferenceTerminated: ({message}) {
          debugPrint("${options.room} terminated with message: $message");
        }),
      );
    } catch (error) {
      debugPrint("error: $error");
    }
  }
}