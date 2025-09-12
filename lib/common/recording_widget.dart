import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

class RecordingWidget extends StatefulWidget {
  final String path;
  final FirebaseStorage storage;
  final FirebaseFirestore db;

  const RecordingWidget({required this.path, required this.storage, required this.db, super.key});

  @override
  State<RecordingWidget> createState() => _RecordingWidgetState();
}

class _RecordingWidgetState extends State<RecordingWidget> {
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _recordedFilePath;
  bool _isPlaying = false;
  String _statusMessage = '녹음 준비 중...';
  late final String fileName;

  bool _isCheckingAudio = true; // Storage 확인 중인지 상태
  bool hasAudio = false; // 오디오 파일 존재 여부

  double _amplitude = 0.0;
  StreamSubscription<Amplitude>? _amplitudeSubscription;

  @override
  void initState() {
    super.initState();
    fileName = '${widget.path}.m4a';
    _initialize();
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _requestPermissions();
    final exists = await checkAudioExists();
    if (mounted) {
      // 비동기 작업 후 위젯이 여전히 마운트 상태인지 확인
      setState(() {
        hasAudio = exists;
        _isCheckingAudio = false;
      });
    }
    _listenToPlayerCompletion(); // 플레이어 완료 이벤트 리스너 설정
  }

  void _listenToPlayerCompletion() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      }
    });
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

      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
        _statusMessage = '녹음 완료! 재생하거나 저장하세요.';
      });
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

  /// Storage에 저장된 오디오 재생 ---
  Future<void> _playStoredAudio() async {
    try {
      final url = await widget.storage.ref().child(fileName).getDownloadURL();
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      setState(() => _isPlaying = true);
    } catch (e) {
      debugPrint('Error playing stored audio: $e');
      if (mounted) setState(() => _statusMessage = '저장된 파일 재생 실패: $e');
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
      final storageRef = widget.storage.ref().child(fileName);

      // 바이트 데이터 업로드
      await storageRef.putData(audioBytes, SettableMetadata(contentType: 'audio/m4a'));

      final String downloadUrl = await storageRef.getDownloadURL();

      // Firestore 문서의 'audio' 필드 업데이트
      // widget.path (예: 'audios/{topicId}/{wordId}')에서 ID들을 추출합니다.
      final pathParts = widget.path.split('/');
      if (pathParts.length == 3) {
        final topicId = pathParts[1];
        final wordId = pathParts[2];

        final wordDocRef = widget.db
            .collection('Topics')
            .doc(topicId)
            .collection('Words')
            .doc(wordId);

        // Firestore 문서 업데이트
        await wordDocRef.update({'audio': downloadUrl});
      } else {
        // 경로 형식이 예상과 다를 경우 에러 처리
        throw Exception('잘못된 파일 경로 형식입니다.');
      }

      setState(() {
        hasAudio = true;
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

  Future<bool> checkAudioExists() async {
    try {
      await widget.storage.ref().child(fileName).getDownloadURL();
      return true;
    } on FirebaseException catch (e) {
      print('exception: $e');
      return false;
    } catch (e) {
      print('catch error: $e');
      return false;
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
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: LinearProgressIndicator(
                value: (_amplitude + 60) / 60, // 앰플리튜드 값(-60 ~ 0)을 0.0 ~ 1.0 범위로 변환
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          // Play and Save buttons
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: _isRecording ? _stopRecording : _startRecording,
                      icon: Icon(_isRecording ? Icons.stop : Icons.mic)),
                  const SizedBox(width: 5),
                  IconButton(
                      onPressed: _recordedFilePath != null ? (_isPlaying ? _stopPlayback : _playRecording) : null,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow)),
                  const SizedBox(width: 5),
                  IconButton(
                      onPressed: _recordedFilePath != null ? _saveRecording : null, icon: const Icon(Icons.save)),
                  const SizedBox(width: 5),
                  if (_isCheckingAudio)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    )
                  else if (hasAudio)
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.stop_circle : Icons.play_circle),
                      color: Colors.purple,
                      iconSize: 32,
                      // 재생 중이면 정지, 아니면 저장된 파일 재생
                      onPressed: _isPlaying ? _stopPlayback : _playStoredAudio,
                    ),
                ],
              )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(_statusMessage, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
