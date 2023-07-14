import 'package:flutter/material.dart';
import 'auth.dart';
import "dart:io";
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class predictPage extends StatefulWidget {
  const predictPage({Key? key}) : super(key: key);

  @override
  State<predictPage> createState() => _predictPageState();
}

class _predictPageState extends State<predictPage> {
  String? _filePath;
  String? _filePath1;
  String? predicted;
  String prediction = '';
  String groundTruth = '';
  int flag = 0;
  int flag1 = 0;
  int flag1_1 = 0;
  int flag2 = 0;

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  final audioPlayer1 = AudioPlayer();
  bool isPlaying1 = false;
  Duration duration1 = Duration.zero;
  Duration position1 = Duration.zero;

  @override
  void initState() {
    super.initState();
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    audioPlayer1.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying1 = state == PlayerState.playing;
      });
    });
    audioPlayer1.onDurationChanged.listen((newDuration) {
      setState(() {
        duration1 = newDuration;
      });
    });
    audioPlayer1.onPositionChanged.listen((newPosition) {
      setState(() {
        position1 = newPosition;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    audioPlayer1.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> uploadAudio(File audioFile) async {
    var request = http.MultipartRequest(
      'POST',
      // Uri.parse('http://15.206.75.43:80/predict'),
      Uri.parse('http://10.0.2.2:5000/predict'),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
      ),
    );
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    setState(() {
      final data = responseData.split(",");
      prediction = data[0];
      groundTruth = data[1];
    });
    debugPrint(prediction);
    debugPrint(groundTruth);
  }

  Future<void> pickFile() async {
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

  Future<void> fetchAudioUrl() async {
    // var response = await http.get(Uri.parse('http://15.206.75.43:80/audio'));
    var response = await http.get(Uri.parse('http://10.0.2.2:5000/audio'));
    if (response.statusCode == 200) {
      var audioFile = File('/storage/emulated/0/Download/test.wav');
      await audioFile.writeAsBytes(response.bodyBytes);
      setState(() {
        _filePath1 = '/storage/emulated/0/Download/test.wav';
        flag1_1 = 1;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HS_Classifier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Auth.instance.logOut();
              // print('Logout pressed');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: pickFile,
              child: const Text('Pick File'),
            ),
            const SizedBox(height: 10),
            _filePath != null
                ? Text('Selected file: $_filePath')
                : const Text('No file selected'),
            const SizedBox(height: 10),
            flag1 == 1
                ? Column(
              children: [
                Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await audioPlayer.seek(position);
                    await audioPlayer.resume();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatTime(position)),
                      Text(formatTime(duration)),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 35,
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    iconSize: 50,
                    onPressed: () async {
                      if (isPlaying) {
                        await audioPlayer.pause();
                      } else {
                        File audioFile = File(_filePath ?? "");
                        await audioPlayer.play(UrlSource(audioFile.path));
                      }
                    },
                  ),
                ),
              ],
            )
                : const Text(""),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await uploadAudio(File(_filePath ?? ""));
                await fetchAudioUrl();
                setState(() {
                  flag = 1;
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Predict'),
            ),
            prediction != ''
                ? groundTruth!=''?Column(children: [Text('Prediction: $prediction'),Text('Ground Truth: $groundTruth')],):Text('Prediction: $prediction')
                : const Text(''),
            const SizedBox(height: 10),
            const Text(""),
            const SizedBox(height: 10),
            prediction != ''?
            Column(
              children: [
                Slider(
                  min: 0,
                  max: duration1.inSeconds.toDouble(),
                  value: position1.inSeconds.toDouble(),
                  onChanged: (value) async {
                    final position = Duration(seconds: value.toInt());
                    await audioPlayer1.seek(position);
                    await audioPlayer1.resume();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatTime(position1)),
                      Text(formatTime(duration1)),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 35,
                  child: IconButton(
                    icon: Icon(
                      isPlaying1 ? Icons.pause : Icons.play_arrow,
                    ),
                    iconSize: 50,
                    onPressed: () async {
                      if (isPlaying1) {
                        await audioPlayer1.pause();
                      } else {
                        File audioFile = File(_filePath1 ?? "");
                        await audioPlayer1.play(UrlSource(audioFile.path));
                      }
                    },
                  ),
                ),
              ],
            ):const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}