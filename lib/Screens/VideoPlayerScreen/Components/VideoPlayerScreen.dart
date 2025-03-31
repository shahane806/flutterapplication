import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:async';

class VideoPlayerScreen extends StatefulWidget {
  final String url;

  const VideoPlayerScreen({super.key, required this.url});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isLandscape = false;
  bool _controlsVisible = true;
  Timer? _hideTimer;
  bool _isCasting = false; // Placeholder for casting state
  bool _hdrMode = false; // Toggle for HDR (video/device dependent)
  double _playbackSpeed = 1.0;
  String _selectedAspectRatio = '16:9';
  bool _isInitialized = false;
  String? _errorMessage;
  int _selectedAudioTrack = 0; // Simulated audio track index

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _controller.setLooping(true);
            _controller.play();
          });
          print("Video initialized, starting hide timer");
          _startHideTimer();
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load video: $error';
            _isInitialized = false;
          });
          print("Error initializing video: $error");
        }
      });

    // Keep screen on during playback
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    print("Disposing: Canceling timer and cleaning up");
    _hideTimer?.cancel();
    _exitFullScreen();
    _controller.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
      if (_isLandscape) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
      print(
          "Orientation toggled to ${_isLandscape ? 'landscape' : 'portrait'}");
      _showControlsTemporarily();
    });
  }

  void _toggleMute() {
    setState(() {
      double currentVolume = _controller.value.volume;
      _controller.setVolume(currentVolume == 0 ? 1.0 : 0.0);
      print("Mute toggled: ${currentVolume == 0 ? 'unmuted' : 'muted'}");
      _showControlsTemporarily();
    });
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    print("Starting hide timer");
    _hideTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
          print("Timer triggered: Controls hidden");
        });
      }
    });
  }

  void _showControlsTemporarily() {
    if (mounted) {
      setState(() {
        _controlsVisible = true;
        print("Controls shown temporarily");
      });
      _startHideTimer();
    }
  }

  void _toggleControlsVisibility() {
    if (mounted) {
      setState(() {
        _controlsVisible = !_controlsVisible;
        print("Double-tap: Controls visibility toggled to $_controlsVisible");
        if (_controlsVisible) {
          _startHideTimer();
        } else {
          _hideTimer?.cancel();
          print("Timer canceled due to manual hide");
        }
      });
    }
  }

  void _toggleCast() {
    setState(() {
      _isCasting = !_isCasting;
      print("Casting toggled: $_isCasting");
      _showControlsTemporarily();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isCasting
              ? 'Casting started (placeholder)'
              : 'Casting stopped (placeholder)'),
        ),
      );
      // For real casting, use flutter_cast_video or similar
    });
  }

  void _switchAudioTrack(int index) {
    setState(() {
      _selectedAudioTrack = index;
      print("Audio track switched to: Track $index (simulated)");
      _showControlsTemporarily();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to audio track $index (simulated)'),
        ),
      );
      // Real audio track switching requires platform channels or a different player
    });
  }

  void _toggleHDRMode() {
    setState(() {
      _hdrMode = !_hdrMode;
      print("HDR mode toggled: $_hdrMode");
      _showControlsTemporarily();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_hdrMode
              ? 'HDR mode enabled (if supported)'
              : 'HDR mode disabled'),
        ),
      );
    });
  }

  void _setPlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
      _controller.setPlaybackSpeed(_playbackSpeed);
      print("Playback speed set to: $_playbackSpeed");
      _showControlsTemporarily();
    });
  }

  void _setAspectRatio(String ratio) {
    setState(() {
      _selectedAspectRatio = ratio;
      print("Aspect ratio set to: $_selectedAspectRatio");
      _showControlsTemporarily();
    });
  }

  Widget _buildVideoControls(BuildContext context) {
    return Container(
      color: Colors.black26,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                      print("Play/Pause pressed: Paused");
                    } else {
                      _controller.play();
                      print("Play/Pause pressed: Playing");
                    }
                    _showControlsTemporarily();
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  _isLandscape ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: _toggleOrientation,
              ),
              IconButton(
                icon: Icon(
                  _controller.value.volume == 0
                      ? Icons.volume_off
                      : Icons.volume_up,
                  color: Colors.white,
                ),
                onPressed: _toggleMute,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  _isCasting ? Icons.cast_connected : Icons.cast,
                  color: Colors.white,
                ),
                onPressed: _toggleCast,
              ),
              PopupMenuButton<int>(
                icon: Icon(Icons.audiotrack, color: Colors.white),
                onSelected: (index) => _switchAudioTrack(index),
                itemBuilder: (context) {
                  // Simulate 3 audio tracks since video_player doesn’t support this
                  return List.generate(3, (index) {
                    return PopupMenuItem(
                      value: index,
                      child: Text(
                        'Track $index',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  });
                },
                color: Colors.black54,
              ),
              IconButton(
                icon: Icon(
                  _hdrMode ? Icons.hdr_on : Icons.hdr_off,
                  color: Colors.white,
                ),
                onPressed: _toggleHDRMode,
              ),
              DropdownButton<double>(
                value: _playbackSpeed,
                items: [
                  DropdownMenuItem(
                      value: 0.5,
                      child:
                          Text('0.5x', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: 1.0,
                      child:
                          Text('1.0x', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: 1.5,
                      child:
                          Text('1.5x', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: 2.0,
                      child:
                          Text('2.0x', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _setPlaybackSpeed(value);
                  }
                },
                dropdownColor: Colors.black54,
              ),
              DropdownButton<String>(
                value: _selectedAspectRatio,
                items: [
                  DropdownMenuItem(
                      value: '16:9',
                      child:
                          Text('16:9', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: '4:3',
                      child:
                          Text('4:3', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(
                      value: '1:1',
                      child:
                          Text('1:1', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _setAspectRatio(value);
                  }
                },
                dropdownColor: Colors.black54,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double videoWidth = screenSize.width;
    double videoHeight = screenSize.height;

    // Determine aspect ratio based on selection
    double aspectRatio;
    switch (_selectedAspectRatio) {
      case '16:9':
        aspectRatio = 16 / 9;
        break;
      case '4:3':
        aspectRatio = 4 / 3;
        break;
      case '1:1':
        aspectRatio = 1;
        break;
      default:
        aspectRatio = _controller.value.aspectRatio;
    }

    return WillPopScope(
      onWillPop: () async {
        if (_isLandscape) {
          _toggleOrientation();
          return false;
        }
        _controller.pause();
        _exitFullScreen();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: GestureDetector(
            onDoubleTap: () {
              print("Double-tap detected");
              _toggleControlsVisibility();
            },
            child: Stack(
              children: [
                Center(
                  child: _errorMessage != null
                      ? Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        )
                      : SizedBox(
                          width: videoWidth,
                          height: videoHeight,
                          child: _isInitialized
                              ? AspectRatio(
                                  aspectRatio: aspectRatio,
                                  child: VideoPlayer(_controller),
                                )
                              : CircularProgressIndicator(color: Colors.white),
                        ),
                ),
                if (_isInitialized && _controlsVisible)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildVideoControls(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
