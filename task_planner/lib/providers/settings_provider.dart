import 'package:flutter_riverpod/flutter_riverpod.dart';

class Settings {
  final bool showCompletedTasks;
  final bool showRepeatableTasks;
  final bool enableAnimations;
  final String animationSpeed;
  final bool enableGradientBackground;

  Settings({
    this.showCompletedTasks = true,
    this.showRepeatableTasks = true,
    this.enableAnimations = true,
    this.animationSpeed = 'Normal',
    this.enableGradientBackground = true,
  });

  Settings copyWith({
    bool? showCompletedTasks,
    bool? showRepeatableTasks,
    bool? enableAnimations,
    String? animationSpeed,
    bool? enableGradientBackground,
  }) {
    return Settings(
      showCompletedTasks: showCompletedTasks ?? this.showCompletedTasks,
      showRepeatableTasks: showRepeatableTasks ?? this.showRepeatableTasks,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      enableGradientBackground:
          enableGradientBackground ?? this.enableGradientBackground,
    );
  }
}

class SettingsNotifier extends StateNotifier<Settings> {
  SettingsNotifier() : super(Settings());

  void toggleShowCompletedTasks() {
    state = state.copyWith(showCompletedTasks: !state.showCompletedTasks);
  }

  void toggleShowRepeatableTasks() {
    state = state.copyWith(showRepeatableTasks: !state.showRepeatableTasks);
  }

  void toggleEnableAnimations() {
    state = state.copyWith(enableAnimations: !state.enableAnimations);
  }

  void setAnimationSpeed(String speed) {
    state = state.copyWith(animationSpeed: speed);
  }

  void toggleEnableGradientBackground() {
    state = state.copyWith(
        enableGradientBackground: !state.enableGradientBackground);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});
