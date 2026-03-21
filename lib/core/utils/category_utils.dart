import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Shared utility for category name and color mapping.
///
/// Centralises the category → display-name / color logic that was previously
/// duplicated across exam results, flashcards, heatmap, and recommendation
/// widgets.
class CategoryUtils {
  CategoryUtils._(); // prevent instantiation

  /// Returns the theme colour associated with [category].
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'geography':
        return AppColors.geography;
      case 'politics':
        return AppColors.politics;
      case 'culture':
        return AppColors.culture;
      case 'daily_life':
        return AppColors.dailyLife;
      default:
        return AppColors.primary;
    }
  }

  /// Returns the human-readable display name for [category].
  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'geography':
        return 'Geography';
      case 'politics':
        return 'Politics';
      case 'culture':
        return 'Culture';
      case 'daily_life':
        return 'Daily Life';
      default:
        return category;
    }
  }
}
