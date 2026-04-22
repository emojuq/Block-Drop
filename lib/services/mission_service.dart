import 'dart:convert';
import 'package:flutter/material.dart';
import 'storage_service.dart';

class Mission {
  final String id;
  final String title;
  final int target;
  int progress;
  bool isCompleted;

  Mission({
    required this.id,
    required this.title,
    required this.target,
    this.progress = 0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'target': target,
    'progress': progress,
    'isCompleted': isCompleted,
  };

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
    id: json['id'],
    title: json['title'],
    target: json['target'],
    progress: json['progress'] ?? 0,
    isCompleted: json['isCompleted'] ?? false,
  );
}

class MissionService {
  static ValueNotifier<List<Mission>> missions = ValueNotifier([]);

  static Future<void> loadMissions() async {
    final now = DateTime.now();
    final todayKey = "${now.year}-${now.month}-${now.day}";
    final storedKey = await StorageService.getMissionDateKey();

    if (storedKey != todayKey) {
      // Generate new daily missions
      final newMissions = [
        Mission(id: 'lines', title: '50 Satır Patlat', target: 50),
        Mission(id: 'blocks', title: '200 Blok Koy', target: 200),
        Mission(id: 'combo', title: '10 Kombo Yap', target: 10),
      ];
      missions.value = newMissions;
      await StorageService.saveMissions(newMissions, todayKey);
      return;
    }

    final data = await StorageService.getMissionsData();
    if (data.isNotEmpty) {
      List<dynamic> jsonList = jsonDecode(data);
      missions.value = jsonList.map((e) => Mission.fromJson(e)).toList();
    }
  }

  static Future<void> updateProgress(String id, int amount) async {
    bool changed = false;
    for (var m in missions.value) {
      if (m.id == id && !m.isCompleted) {
        m.progress += amount;
        if (m.progress >= m.target) {
          m.progress = m.target;
          m.isCompleted = true;
          // Could trigger a global overlay or sound here!
        }
        changed = true;
      }
    }
    
    if (changed) {
      // Force notify listeners by re-assigning (hacky but works for ValueNotifier usually, better to copy)
      missions.value = List.from(missions.value);
      
      final now = DateTime.now();
      final todayKey = "${now.year}-${now.month}-${now.day}";
      await StorageService.saveMissions(missions.value, todayKey);
    }
  }
}
