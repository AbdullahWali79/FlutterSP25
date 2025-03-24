import 'package:flutter/material.dart';

class TaskAppearanceProvider with ChangeNotifier {
  double _titleFontSize = 16.0;
  double _descriptionFontSize = 13.0;
  FontWeight _titleFontWeight = FontWeight.w500;
  FontWeight _descriptionFontWeight = FontWeight.normal;
  Color _taskGradientStartColor = Colors.blue.withOpacity(0.15);
  Color _taskGradientEndColor = Colors.purple.withOpacity(0.15);
  double _taskCornerRadius = 16.0;
  double _taskShadowOpacity = 0.3;
  double _taskShadowBlur = 6.0;

  // Dialog customization settings
  double _dialogCornerRadius = 16.0;
  double _dialogAnimationDuration = 0.3;
  double _dialogBackgroundOpacity = 0.95;
  double _dialogElevation = 8.0;
  bool _dialogUseGradient = true;

  // Getters
  double get titleFontSize => _titleFontSize;
  double get descriptionFontSize => _descriptionFontSize;
  FontWeight get titleFontWeight => _titleFontWeight;
  FontWeight get descriptionFontWeight => _descriptionFontWeight;
  Color get taskGradientStartColor => _taskGradientStartColor;
  Color get taskGradientEndColor => _taskGradientEndColor;
  double get taskCornerRadius => _taskCornerRadius;
  double get taskShadowOpacity => _taskShadowOpacity;
  double get taskShadowBlur => _taskShadowBlur;

  // Dialog getters
  double get dialogCornerRadius => _dialogCornerRadius;
  double get dialogAnimationDuration => _dialogAnimationDuration;
  double get dialogBackgroundOpacity => _dialogBackgroundOpacity;
  double get dialogElevation => _dialogElevation;
  bool get dialogUseGradient => _dialogUseGradient;

  // Setters
  void updateTitleFontSize(double size) {
    _titleFontSize = size;
    notifyListeners();
  }

  void updateDescriptionFontSize(double size) {
    _descriptionFontSize = size;
    notifyListeners();
  }

  void updateTitleFontWeight(FontWeight weight) {
    _titleFontWeight = weight;
    notifyListeners();
  }

  void updateDescriptionFontWeight(FontWeight weight) {
    _descriptionFontWeight = weight;
    notifyListeners();
  }

  void updateTaskGradientColors(Color startColor, Color endColor) {
    _taskGradientStartColor = startColor;
    _taskGradientEndColor = endColor;
    notifyListeners();
  }

  void updateTaskCornerRadius(double radius) {
    _taskCornerRadius = radius;
    notifyListeners();
  }

  void updateTaskShadowOpacity(double opacity) {
    _taskShadowOpacity = opacity;
    notifyListeners();
  }

  void updateTaskShadowBlur(double blur) {
    _taskShadowBlur = blur;
    notifyListeners();
  }

  // Dialog setters
  void updateDialogCornerRadius(double radius) {
    _dialogCornerRadius = radius;
    notifyListeners();
  }

  void updateDialogAnimationDuration(double duration) {
    _dialogAnimationDuration = duration;
    notifyListeners();
  }

  void updateDialogBackgroundOpacity(double opacity) {
    _dialogBackgroundOpacity = opacity;
    notifyListeners();
  }

  void updateDialogElevation(double elevation) {
    _dialogElevation = elevation;
    notifyListeners();
  }

  void updateDialogUseGradient(bool useGradient) {
    _dialogUseGradient = useGradient;
    notifyListeners();
  }

  // Reset to default values
  void resetToDefaults() {
    _titleFontSize = 16.0;
    _descriptionFontSize = 13.0;
    _titleFontWeight = FontWeight.w500;
    _descriptionFontWeight = FontWeight.normal;
    _taskGradientStartColor = Colors.blue.withOpacity(0.15);
    _taskGradientEndColor = Colors.purple.withOpacity(0.15);
    _taskCornerRadius = 16.0;
    _taskShadowOpacity = 0.3;
    _taskShadowBlur = 6.0;

    // Reset dialog settings
    _dialogCornerRadius = 16.0;
    _dialogAnimationDuration = 0.3;
    _dialogBackgroundOpacity = 0.95;
    _dialogElevation = 8.0;
    _dialogUseGradient = true;

    notifyListeners();
  }
}
