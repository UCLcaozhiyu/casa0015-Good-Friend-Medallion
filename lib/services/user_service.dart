import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserService {
  static const String _userIdKey = 'user_id';
  static const String _matchesKey = 'matches';

  static Future<String> getOrCreateUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);
    
    if (userId == null) {
      userId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString(_userIdKey, userId);
    }
    
    return userId;
  }

  static Future<List<Map<String, dynamic>>> getMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final matchesJson = prefs.getString(_matchesKey);
    if (matchesJson == null) return [];
    
    final List<dynamic> matchesList = json.decode(matchesJson);
    return matchesList.map((match) => Map<String, dynamic>.from(match)).toList();
  }

  static Future<void> addMatch(Map<String, dynamic> match) async {
    final matches = await getMatches();
    if (!matches.any((m) => m['id'] == match['id'])) {
      matches.add(match);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_matchesKey, json.encode(matches));
    }
  }

  static Future<void> removeMatch(String matchId) async {
    final matches = await getMatches();
    matches.removeWhere((match) => match['id'] == matchId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_matchesKey, json.encode(matches));
  }
} 