import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../cubit/statistics_cubit.dart';
import '../cubit/statistics_state.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());

          final streak = state.streak;
          final weeklyHours = state.last7DaysHours;
          final breakdown = state.subjectBreakdown;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${streak.currentStreak} Day Streak',
                              style: Theme.of(context).textTheme.titleLarge),
                          Text('Longest: ${streak.longestStreak} days'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _StatCard(label: 'Today', value: _formatDuration(state.todayStudyTime), icon: Icons.today),
                  _StatCard(label: 'This Week', value: _formatDuration(state.weeklyStudyTime), icon: Icons.calendar_view_week),
                  _StatCard(label: 'This Month', value: _formatDuration(state.monthlyStudyTime), icon: Icons.calendar_month),
                  _StatCard(label: 'All Time', value: _formatDuration(state.totalStudyTime), icon: Icons.hourglass_bottom),
                  _StatCard(label: 'Tasks Done', value: '${state.completedTasksCount}', icon: Icons.check_circle_outline),
                  _StatCard(label: 'Pomodoros', value: '${state.pomodoroSessionsCount}', icon: Icons.timer_outlined),
                ],
              ),
              const SizedBox(height: 24),
              Text('Last 7 Days', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(height: 180, child: _WeeklyBarChart(hours: weeklyHours)),
              const SizedBox(height: 24),
              Text('By Subject', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (breakdown.isEmpty)
                const Text('No subject-linked sessions yet.')
              else
                ...breakdown.map((summary) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(summary.subjectId ?? 'Unlinked sessions'),
                    trailing: Text(
                      '${_formatDuration(summary.totalDuration)} • ${summary.sessionCount} sessions',
                    ),
                  ),
                )),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<double> hours;
  const _WeeklyBarChart({required this.hours});

  @override
  Widget build(BuildContext context) {
    const days = ['6d', '5d', '4d', '3d', '2d', 'Ytd', 'Today'];
    final maxY = (hours.isEmpty ? 1.0 : hours.reduce((a, b) => a > b ? a : b)) + 1;

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: List.generate(hours.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: hours[i],
                color: Theme.of(context).colorScheme.primary,
                width: 18,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(days[value.toInt().clamp(0, 6)], style: const TextStyle(fontSize: 10)),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}