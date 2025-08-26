import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class Recording extends StatefulWidget {
  final String lessonId;
  final String audioId;

  const Recording({required this.lessonId, required this.audioId, super.key});

  @override
  State<Recording> createState() => _RecordingState();
}

class _RecordingState extends State<Recording> {
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _recordedFilePath;
  Uint8List? _recordedFileBytes;
  bool _isPlaying = false;
  String _statusMessage = '녹음 준비 중...';
  late final String lessonId;
  late final String audioId;
  double _amplitude = 0.0;
  StreamSubscription<Amplitude>? _amplitudeSubscription;

  @override
  void initState() {
    super.initState();
    lessonId = widget.lessonId;
    audioId = widget.audioId;
    _requestPermissions();
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Requests microphone permission from the user.
  Future<void> _requestPermissions() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (hasPermission) {
      setState(() {
        _statusMessage = '마이크 권한이 허용되었습니다.';
      });
    } else {
      setState(() {
        _statusMessage = '마이크 권한이 필요합니다.';
      });
    }
  }

  /// Starts the audio recording.
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(const RecordConfig(), path: '');

        // [추가] 앰플리튜드 스트림 구독 시작
        _amplitudeSubscription = _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen(
              (amp) {
            setState(() => _amplitude = amp.current);
          },
        );

        setState(() {
          _isRecording = true;
          _recordedFilePath = null;
          _recordedFileBytes = null;
          _statusMessage = '녹음 중...';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '녹음 시작 실패: $e';
      });
      debugPrint('Error starting recording: $e');
    }
  }

  /// Stops the audio recording.
  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      // [추가] 앰플리튜드 스트림 구독 취소
      await _amplitudeSubscription?.cancel();
      setState(() => _amplitude = 0.0); // 초기화

      if (path != null) {
        setState(() {
          _isRecording = false;
          _recordedFilePath = path;
          _statusMessage = '녹음 완료! 재생하거나 저장하세요.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '녹음 중지 실패: $e';
      });
      debugPrint('Error stopping recording: $e');
    }
  }

  // --- Playback Functions ---

  /// Plays the recorded audio file.
  Future<void> _playRecording() async {
    if (_recordedFilePath != null) {
      try {
        await _audioPlayer.setUrl(_recordedFilePath!);
        await _audioPlayer.play();
        setState(() {
          _isPlaying = true;
        });

        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              _isPlaying = false;
            });
          }
        });
      } catch (e) {
        setState(() {
          _statusMessage = '재생 실패: $e';
        });
        debugPrint('Error playing audio: $e');
      }
    }
  }

  /// Stops the audio playback.
  Future<void> _stopPlayback() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  // --- Storage Function ---
  Future<void> _saveRecording() async {
    if (_recordedFilePath == null) {
      setState(() {
        _statusMessage = '저장할 녹음 파일이 없습니다.';
      });
      return;
    }

    setState(() {
      _statusMessage = '저장 중...';
    });

    try {
      // Blob URL에서 오디오 데이터를 바이트로 가져오기
      final response = await http.get(Uri.parse(_recordedFilePath!));
      final audioBytes = response.bodyBytes;

      // 파일 이름 설정 및 Storage 참조 생성
      final fileName = 'KoreanBitesAudios/$lessonId/$audioId.m4a';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);

      // 바이트 데이터 업로드
      await storageRef.putData(audioBytes);

      print('오디오바이트: ${audioBytes.length}');

      setState(() {
        _statusMessage = '저장 완료! ✨';
        _recordedFilePath = null; // 성공적으로 저장 후 초기화
      });
      debugPrint('File uploaded to Firebase Storage: $fileName');
    } on FirebaseException catch (e) {
      setState(() {
        _statusMessage = '저장 실패: ${e.code}';
      });
      debugPrint('Firebase Storage Error: ${e.code}');
    } catch (e) {
      setState(() {
        _statusMessage = '알 수 없는 오류: $e';
      });
      debugPrint('Unknown Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: Column(
        children: [
          if (_isRecording)
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: LinearProgressIndicator(
                value: (_amplitude + 60) / 60, // 앰플리튜드 값(-60 ~ 0)을 0.0 ~ 1.0 범위로 변환
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          // Play and Save buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? '녹음 중지' : '녹음 시작'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _recordedFilePath != null
                        ? (_isPlaying ? _stopPlayback : _playRecording)
                        : null, // Disable button if no file exists
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(_isPlaying ? '재생 중지' : '재생'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _recordedFilePath != null ? _saveRecording : null,
                    icon: const Icon(Icons.save),
                    label: const Text('저장'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(_statusMessage, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
