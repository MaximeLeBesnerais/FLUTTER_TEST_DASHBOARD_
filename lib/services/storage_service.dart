import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class StorageService {
  static const String _gameStateKey = 'game_state';

  // Save game state
  static Future<bool> saveGameState(GameState gameState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gameStateJson = jsonEncode(gameState.toJson());
      return await prefs.setString(_gameStateKey, gameStateJson);
    } catch (e) {
      debugPrint('Error saving game state: $e');
      return false;
    }
  }

  // Load game state
  static Future<GameState?> loadGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gameStateString = prefs.getString(_gameStateKey);
      
      if (gameStateString != null) {
        final gameStateJson = jsonDecode(gameStateString);
        return GameState.fromJson(gameStateJson);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error loading game state: $e');
      return null;
    }
  }

  // Check if save exists
  static Future<bool> hasSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_gameStateKey);
    } catch (e) {
      debugPrint('Error checking for saved game: $e');
      return false;
    }
  }

  // Delete saved game
  static Future<bool> deleteSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_gameStateKey);
    } catch (e) {
      debugPrint('Error deleting saved game: $e');
      return false;
    }
  }

  // Auto-save functionality
  static Future<void> autoSave(GameState gameState) async {
    await saveGameState(gameState);
  }
}