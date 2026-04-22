import 'package:flutter/material.dart';
import '../services/mission_service.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'DAILY MISSIONS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textTheme.bodyLarge?.color),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder<List<Mission>>(
          valueListenable: MissionService.missions,
          builder: (context, missions, child) {
            if (missions.isEmpty) {
              return Center(
                child: Text(
                  'No missions available right now.',
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                ),
              );
            }
            
            return ListView.separated(
              itemCount: missions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final mission = missions[index];
                return _buildMissionCard(context, mission, theme);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context, Mission mission, ThemeData theme) {
    final progressRatio = mission.progress / mission.target;
    final isDone = mission.isCompleted;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone ? const Color(0xFF00E676).withOpacity(0.5) : theme.dividerColor.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
             color: isDone ? const Color(0xFF00E676).withOpacity(0.2) : Colors.black.withOpacity(0.05),
             blurRadius: 10,
             offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  mission.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (isDone)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 28)
              else
                Text(
                  '${mission.progress} / ${mission.target}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressRatio.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: theme.scaffoldBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDone ? const Color(0xFF00E676) : const Color(0xFFFFD500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
