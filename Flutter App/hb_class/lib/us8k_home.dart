import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  String? _filePath;
  String? predicted;
  String prediction = '';
  AudioPlayer audioPlayer = AudioPlayer();
  AudioPlayer audioPlayer1 = AudioPlayer();
  bool isPlaying = false;
  bool isPlaying1 = false;
  Duration durationSeconds = Duration.zero;
  Duration currentSeconds = Duration.zero;
  Duration durationSeconds1 = Duration.zero;
  Duration currentSeconds1 = Duration.zero;
  int flag = 0;
  int flag1 = 0;

  @override
  void initState() {
    super.initState();
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audioPlayer1.onPlayerStateChanged.listen((state1) {
      setState(() {
        isPlaying1 = state1 == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        durationSeconds = newDuration;
      });
    });
    audioPlayer1.onDurationChanged.listen((newDuration1) {
      setState(() {
        durationSeconds1 = newDuration1;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        currentSeconds = newPosition;
      });
    });
    audioPlayer1.onPositionChanged.listen((newPosition1) {
      setState(() {
        currentSeconds1 = newPosition1;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> uploadAudio(File audioFile) async {
    const url = 'http://10.0.2.2:5000/predict_ub';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('audio', audioFile.path));
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    setState(() {
      prediction = responseData;
    });
  }

  Future<void> pickWavFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        _filePath = file.path;
        flag1 = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UrbanSound Classifier'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: pickWavFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
              ),
              child: const Text('Select .wav file'),
            ),
            const SizedBox(height: 10),
            _filePath != null ? Text('Selected file: $_filePath') : const Text('No file selected'),
            flag1 == 1
                ? Column(
              children: [
                Slider(
                  value: currentSeconds.inSeconds.toDouble(),
                  min: 0,
                  max: durationSeconds.inSeconds.toDouble(),
                  onChanged: (value) async {
                    final currentSeconds = Duration(seconds: value.toInt());
                    await audioPlayer1.seek(currentSeconds);
                    await audioPlayer1.resume();
                  },
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatTime(currentSeconds)),
                      Text(formatTime(durationSeconds)),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    iconSize: 25,
                    color: Colors.black,
                    onPressed: () async {
                      if (isPlaying) {
                        setState(() {
                          isPlaying = false;
                        });
                        await audioPlayer.pause();
                      } else {
                        setState(() {
                          isPlaying = true;
                        });
                        File audioFile = File(_filePath ?? "");
                        await audioPlayer.play(UrlSource(audioFile.path));
                      }
                    },
                  ),
                ),
              ],
            )
                : const Text(''),
            const SizedBox(height: 70),
            ElevatedButton(
              onPressed: () async {
                await uploadAudio(File(_filePath ?? ""));
                flag = 1;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Predict'),
            ),
            const SizedBox(height: 20),
            prediction != '' ? Text('Prediction: $prediction') : const Text(''),
            flag == 1
                ? Column(
              children: [
                Slider(
                  value: currentSeconds1.inSeconds.toDouble(),
                  min: 0,
                  max: durationSeconds1.inSeconds.toDouble(),
                  onChanged: (value) async {
                    final currentSeconds1 = Duration(seconds: value.toInt());
                    await audioPlayer1.seek(currentSeconds1);
                    await audioPlayer1.resume();
                  },
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatTime(currentSeconds1)),
                      Text(formatTime(durationSeconds1)),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: Icon(
                      isPlaying1 ? Icons.pause : Icons.play_arrow,
                    ),
                    iconSize: 25,
                    color: Colors.black,
                    onPressed: () async {
                      if (isPlaying1) {
                        setState(() {
                          isPlaying1 = false;
                        });
                        await audioPlayer1.pause();
                      } else {
                        setState(() {
                          isPlaying1 = true;
                        });
                        await audioPlayer1.play(AssetSource('$prediction.wav'));
                      }
                    },
                  ),
                ),
              ],
            )
                : const Text(""),
          ],
        ),
      ),
    );
  }
}
