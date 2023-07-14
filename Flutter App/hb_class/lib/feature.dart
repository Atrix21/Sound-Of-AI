import 'package:flutter/material.dart';
import 'auth.dart';
import "dart:io";
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class feature extends StatefulWidget {
  const feature({super.key});

  @override
  State<feature> createState() => _featureState();
}

class _featureState extends State<feature> {
  String? _filePath;
  String? predicted;
  String prediction = '';
  int flag = 0;
  int flag1 = 0;
  int flag2 = 0;
  File graph = File('');
  String imageUrl = '';

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  late Widget plotImage;

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

    plotImage = const CircularProgressIndicator();
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
    var request = http.MultipartRequest(
      'POST',
      // Uri.parse('http://15.206.75.43:80/graphs'),
      Uri.parse('http://10.0.2.2:5000/graphs'),
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
      prediction = responseData;
    });
    debugPrint(responseData);
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

  Future<http.Response> fetchImage() {
    // return http.get(Uri.parse('http://15.206.75.43:80/plot'));
    return http.get(Uri.parse('http://10.0.2.2:5000/plot'));
  }

  void generateSpectrogramPopup(File audioFile) async {
    // String imageEndpoint = 'http://15.206.75.43:80/spectrogram';
    String imageEndpoint = 'http://10.0.2.2:5000/spectrogram';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width * 0.8,
            child: FutureBuilder<http.Response>(
              future: http.get(Uri.parse(imageEndpoint)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data!.statusCode == 200) {
                  return Image.memory(snapshot.data!.bodyBytes);
                } else if (snapshot.hasError) {
                  return const Text('Failed to load image');
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualisations'),
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
                setState(() {
                  flag = 1;
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Generate Waveform'),
            ),
            const SizedBox(height: 10),
            const Text(""),
            flag == 1
                ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Scaffold(
                body: Center(
                  child: FutureBuilder<http.Response>(
                    future: fetchImage(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.done &&
                          snapshot.hasData &&
                          snapshot.data!.statusCode == 200) {
                        return Image.memory(snapshot.data!.bodyBytes);
                      } else if (snapshot.hasError) {
                        return const Text('Failed to load image');
                      }
                      return plotImage;
                    },
                  ),
                ),
              ),
            )
                : const Text(""),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                generateSpectrogramPopup(File(_filePath ?? ""));
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Generate Spectrogram'),
            ),
          ],
        ),
      ),
    );
  }
}