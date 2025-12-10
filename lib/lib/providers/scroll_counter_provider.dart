import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ScrollCounterProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  
  int _scrollCount = 0;
  int _dailyBudget = 100;
  int _streak = 0;
  bool _serviceRunning = false;
  List<DailyLog> _logs = [];

  ScrollCounterProvider(this._prefs) {
    _loadPreferences();
    _resetDailyCountIfNeeded();
  }

  // Getters
  int get scrollCount => _scrollCount;
  int get dailyBudget => _dailyBudget;
  int get streak => _streak;
  bool get serviceRunning => _serviceRunning;
  List<DailyLog> get logs => _logs;
  double get progress => _dailyBudget > 0 ? _scrollCount / _dailyBudget : 0;
  bool get budgetExceeded => _scrollCount >= _dailyBudget;
  
  String get lastResetDate {
    final stored = _prefs.getString('last_reset_date');
    return stored ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _loadPreferences() {
    _scrollCount = _prefs.getInt('scroll_count') ?? 0;
    _dailyBudget = _prefs.getInt('daily_budget') ?? 100;
    _streak = _prefs.getInt('streak') ?? 0;
    _serviceRunning = _prefs.getBool('service_running') ?? false;
    
    final logsJson = _prefs.getStringList('daily_logs') ?? [];
    _logs = logsJson.map((e) => DailyLog.fromJson(e)).toList();
  }

  void _resetDailyCountIfNeeded() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastReset = lastResetDate;
    
    if (today != lastReset) {
      // Check if yesterday's budget was met
      if (_scrollCount < _dailyBudget) {
        _streak += 1;
      } else {
        _streak = 0;
      }
      
      // Log yesterday's activity
      _logs.add(
        DailyLog(
          date: lastReset,
          scrollCount: _scrollCount,
          budget: _dailyBudget,
          achieved: _scrollCount < _dailyBudget,
        ),
      );
      
      _scrollCount = 0;
      _prefs.setInt('scroll_count', 0);
      _prefs.setString('last_reset_date', today);
      _prefs.setInt('streak', _streak);
      _saveLogs();
    }
  }

  void incrementScrollCount() {
    _resetDailyCountIfNeeded();
    _scrollCount++;
    _prefs.setInt('scroll_count', _scrollCount);
    notifyListeners();
  }

  void setDailyBudget(int budget) {
    _dailyBudget = budget;
    _prefs.setInt('daily_budget', budget);
    notifyListeners();
  }

  void toggleService(bool running) {
    _serviceRunning = running;
    _prefs.setBool('service_running', running);
    notifyListeners();
  }

  void resetToday() {
    _scrollCount = 0;
    _prefs.setInt('scroll_count', 0);
    notifyListeners();
  }

  void _saveLogs() {
    final logsJson = _logs.map((e) => e.toJson()).toList();
    _prefs.setStringList('daily_logs', logsJson);
  }
}

class DailyLog {
  final String date;
  final int scrollCount;
  final int budget;
  final bool achieved;

  DailyLog({
    required this.date,
    required this.scrollCount,
    required this.budget,
    required this.achieved,
  });

  String toJson() => '$date|$scrollCount|$budget|$achieved';

  factory DailyLog.fromJson(String json) {
    final parts = json.split('|');
    return DailyLog(
      date: parts[0],
      scrollCount: int.parse(parts[1]),
      budget: int.parse(parts[2]),
      achieved: parts[3] == 'true',
    );
  }
}
