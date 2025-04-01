import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class VideoPlayerScreen extends StatefulWidget {
  final String url;

  const VideoPlayerScreen({super.key, required this.url});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _isLandscape = false;
  bool _isMuted = false; // Track mute state
  bool _controlsVisible = true; // Track visibility of controls
  Timer? _hideTimer; // Timer to auto-hide controls
  double _playbackSpeed = 1.0;
  bool _isCasting = false; // For screen casting state
  String _selectedAspectRatio = 'Auto'; // Track the selected aspect ratio

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    print("Video Url : ${widget.url}");
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _controller.setLooping(true);
            _controller.play();
            _startHideTimer(); // Start timer when video begins
          });
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load video: $error';
          });
        }
      });
  }

  @override
  void dispose() {
    _hideTimer?.cancel(); // Cancel timer on dispose
    _exitFullScreen();
    _controller.pause();
    _controller.dispose();
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
      _showControlsTemporarily(); // Show controls when orientation changes
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller
          .setVolume(_isMuted ? 0.0 : 1.0); // 0.0 for mute, 1.0 for full volume
      _showControlsTemporarily(); // Show controls when mute is toggled
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
    _hideTimer?.cancel(); // Cancel any existing timer
    _hideTimer = Timer(Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _showControlsTemporarily() {
    setState(() {
      _controlsVisible = true;
    });
    _startHideTimer(); // Restart timer to hide after showing
  }

  void _toggleControlsVisibility() {
    setState(() {
      _controlsVisible = !_controlsVisible;
      if (_controlsVisible) {
        _startHideTimer(); // Start timer only when showing controls
      } else {
        _hideTimer?.cancel(); // Cancel timer if hiding manually
      }
    });
  }

  // For screen casting (assumed placeholder using cast package)
  void _toggleCasting() {
    setState(() {
      _isCasting = !_isCasting;
    });

    // Handle screen casting logic here (this is a placeholder for actual functionality)
    if (_isCasting) {
      // Cast the video to a supported device
      print("Starting screen cast...");
    } else {
      print("Stopping screen cast...");
    }
  }

  // For changing playback speed
  void _setPlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
      _controller.setPlaybackSpeed(_playbackSpeed);
    });
  }

  double _getAspectRatio() {
    // Handle aspect ratio based on orientation or manual selection
    if (_selectedAspectRatio == '16:9') {
      return 16 / 9;
    } else if (_selectedAspectRatio == '9:16') {
      return 9 / 16;
    } else if (_selectedAspectRatio == 'Auto') {
      // Use the video's native aspect ratio for 'Auto'
      return _controller.value.aspectRatio;
    }
    return _controller.value.aspectRatio; // Default to video's native aspect ratio
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double videoWidth;
    double videoHeight;

    if (_isInitialized) {
      double aspectRatio = _getAspectRatio();
      if (_selectedAspectRatio == 'Auto') {
        // Full-screen with native aspect ratio
        videoWidth = screenSize.width;
        videoHeight = screenSize.height;
      } else {
        // Use selected aspect ratio if not Auto
        if (_isLandscape) {
          videoWidth = screenSize.width;
          videoHeight = videoWidth / aspectRatio;
          if (videoHeight > screenSize.height) {
            videoHeight = screenSize.height;
            videoWidth = videoHeight * aspectRatio;
          }
        } else {
          videoHeight = screenSize.height;
          videoWidth = videoHeight * aspectRatio;
          if (videoWidth > screenSize.width) {
            videoWidth = screenSize.width;
            videoHeight = videoWidth / aspectRatio;
          }
        }
      }
    } else {
      videoWidth = screenSize.width;
      videoHeight = screenSize.height;
    }

    return WillPopScope(
      onWillPop: () async {
        if (_isLandscape) {
          _toggleOrientation();
          return false;
        }
        _controller.pause();
        await _controller.dispose();
        _exitFullScreen();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: GestureDetector(
            onTap: _toggleControlsVisibility, // Show controls on tap
            child: Stack(
              children: [
                Center(
                  child: _errorMessage != null
                      ? Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        )
                      : _isInitialized
                          ? SizedBox(
                              width: videoWidth,
                              height: videoHeight,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _controller.value.size.width,
                                  height: _controller.value.size.height,
                                  child: VideoPlayer(_controller),
                                ),
                              ),
                            )
                          : CircularProgressIndicator(),
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

  Widget _buildVideoControls(BuildContext context) {
    return Container(
      color: Colors.black26,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
                _showControlsTemporarily(); // Show controls when play/pause is pressed
              });
            },
          ),
          Expanded(
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Colors.blue,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.white30,
              ),
            ),
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
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
            onPressed: _toggleMute,
          ),
          IconButton(
            icon: Icon(
              _isCasting ? Icons.cast_connected : Icons.cast,
              color: Colors.white,
            ),
            onPressed: _toggleCasting,
          ),
          DropdownButton<String>(
            value: _selectedAspectRatio,
            items: [
              DropdownMenuItem(
                  value: 'Auto',
                  child: Text('Auto', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(
                  value: '16:9',
                  child: Text('16:9', style: TextStyle(color: Colors.white))),
              DropdownMenuItem(
                  value: '9:16',
                  child: Text('9:16', style: TextStyle(color: Colors.white))),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedAspectRatio = value;
                });
              }
            },
            dropdownColor: Colors.black54,
          ),
        ],
      ),
    );
  }
}
