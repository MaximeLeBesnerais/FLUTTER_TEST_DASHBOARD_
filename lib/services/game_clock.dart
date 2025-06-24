import 'dart:async';
import 'package:flutter/foundation.dart';

class GameClock extends ChangeNotifier {
  static final GameClock _instance = GameClock._internal();
  factory GameClock() => _instance;
  GameClock._internal();

  DateTime _gameTime = DateTime.now();
  Timer? _timer;
  bool _isRunning = false;
  
  // Game time runs 20x faster than real time
  static const int _speedMultiplier = 20;
  
  DateTime get gameTime => _gameTime;
  bool get isRunning => _isRunning;
  
  void start() {
    if (_isRunning) return;
    
    _isRunning = true;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      // Advance game time by 1 second (20x speed) every 50ms of real time
      _gameTime = _gameTime.add(const Duration(seconds: 1));
      notifyListeners();
    });
  }
  
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }
  
  void pause() {
    stop();
  }
  
  void resume() {
    start();
  }
  
  // Add time manually (for testing or special events)
  void addTime(Duration duration) {
    _gameTime = _gameTime.add(duration);
    notifyListeners();
  }
  
  // Check if a duration has passed since a given time
  bool hasTimePassed(DateTime since, Duration duration) {
    return _gameTime.isAfter(since.add(duration));
  }
  
  // Get time remaining until a target time
  Duration timeRemaining(DateTime target) {
    final remaining = target.difference(_gameTime);
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
