import 'package:PiliPlus/common/style.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:PiliPlus/utils/font_utils.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoThemeData;
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:material_ui/material_ui.dart';

abstract final class ThemeUtils {
  static late ThemeData lightTheme;

  static late ThemeData darkTheme;

  static late ThemeMode themeMode;

  static ThemeData get theme {
    if (themeMode == .dark ||
        (themeMode == .system &&
            PlatformDispatcher.instance.platformBrightness == .dark)) {
      return darkTheme;
    }
    return lightTheme;
  }

  static bool get isDarkMode => theme.isDark;

  static String themeUrl(bool isDark) =>
      'native.theme=${isDark ? 2 : 1}&night=${isDark ? 1 : 0}';

  static ThemeData getThemeData({
    required ColorScheme colorScheme,
    required bool isDynamic,
    bool isDark = false,
  }) {
    final fontWeight = Pref.appFontWeight;
    final fontFamily = FontUtils.fontFamily;

    TextTheme? textTheme;
    if (fontWeight != .normal) {
      final textStyle = TextStyle(fontWeight: fontWeight);
      textTheme = TextTheme(
        displayLarge: textStyle,
        displayMedium: textStyle,
        displaySmall: textStyle,
        headlineLarge: textStyle,
        headlineMedium: textStyle,
        headlineSmall: textStyle,
        titleLarge: textStyle,
        titleMedium: textStyle,
        titleSmall: textStyle,
        bodyLarge: textStyle,
        bodyMedium: textStyle,
        bodySmall: textStyle,
        labelLarge: textStyle,
        labelMedium: textStyle,
        labelSmall: textStyle,
      );
    }

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        // 玻璃顶栏：半透明底色，具体模糊由 GlassAppBar 的 flexibleSpace 提供。
        backgroundColor: colorScheme.surface.withValues(alpha: 0.72),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          color: colorScheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        surfaceTintColor: isDark ? colorScheme.surfaceContainerHighest : null,
        backgroundColor: colorScheme.surfaceContainer.withValues(
          alpha: isDark ? 0.55 : 0.6,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        elevation: 20,
        actionTextColor: colorScheme.primary,
        closeIconColor: colorScheme.secondary,
        backgroundColor: colorScheme.secondaryContainer,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: fontWeight,
          color: colorScheme.onSecondaryContainer,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        surfaceTintColor: isDark ? colorScheme.surfaceContainerHighest : null,
        color: colorScheme.surfaceContainer.withValues(alpha: 0.85),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        surfaceTintColor: isDark ? colorScheme.onSurfaceVariant : null,
        // 玻璃卡片：半透明底色 + 大圆角 + 细边框（模糊不由主题提供，
        // 卡片多位于纯色背景上，半透明 + 高光即可呈现玻璃感）。
        color: colorScheme.surfaceContainer.withValues(
          alpha: isDark ? 0.55 : 0.6,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      progressIndicatorTheme: isDark
          ? ProgressIndicatorThemeData(
              // ignore: deprecated_member_use
              year2023: false,
              refreshBackgroundColor: colorScheme.onInverseSurface,
            )
          // ignore: deprecated_member_use
          : const ProgressIndicatorThemeData(year2023: false),
      dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          color: colorScheme.onSurface,
        ),
        backgroundColor: colorScheme.surface.withValues(
          alpha: isDark ? 0.68 : 0.75,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(28)),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface.withValues(
          alpha: isDark ? 0.78 : 0.82,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: Style.bottomSheetRadius,
        ),
      ),
      // ignore: deprecated_member_use
      sliderTheme: const SliderThemeData(year2023: false),
      tooltipTheme: TooltipThemeData(
        textStyle: TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontFamily: fontFamily,
          fontWeight: fontWeight,
        ),
        decoration: const BoxDecoration(
          color: Color(0xE6616161), // Colors.grey[700]!.withValues(alpha: 0.9)
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        selectionHandleColor: colorScheme.primary,
      ),
      switchTheme: const SwitchThemeData(
        padding: .zero,
        materialTapTargetSize: .shrinkWrap,
        thumbIcon: WidgetStateProperty<Icon?>.fromMap(
          <WidgetStatesConstraint, Icon?>{
            WidgetState.selected: Icon(Icons.done),
            WidgetState.any: null,
          },
        ),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
      ),
      listTileTheme: const ListTileThemeData(controlAffinity: .leading),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(
          shadowColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
    );
    if (isDark && Pref.isPureBlackTheme) {
      return darkenTheme(theme);
    }
    return theme;
  }

  static ThemeData darkenTheme(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final color = colorScheme.surfaceContainerHighest.darken(0.7);
    return theme.copyWith(
      canvasColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      cardTheme: theme.cardTheme.copyWith(
        color: colorScheme.surfaceContainer.darken(0.75).withValues(
          alpha: 0.6,
        ),
      ),
      dialogTheme: theme.dialogTheme.copyWith(
        backgroundColor: color.withValues(alpha: 0.72),
      ),
      bottomSheetTheme: theme.bottomSheetTheme.copyWith(
        backgroundColor: color.withValues(alpha: 0.8),
      ),
      bottomNavigationBarTheme: theme.bottomNavigationBarTheme.copyWith(
        backgroundColor: color.withValues(alpha: 0.65),
      ),
      navigationBarTheme: theme.navigationBarTheme.copyWith(
        backgroundColor: color.withValues(alpha: 0.65),
      ),
      navigationRailTheme: theme.navigationRailTheme.copyWith(
        backgroundColor: Colors.black,
      ),
      popupMenuTheme: theme.popupMenuTheme.copyWith(
        color: color.withValues(alpha: 0.85),
      ),
      colorScheme: colorScheme.copyWith(
        primary: colorScheme.primary.darken(0.1),
        onPrimary: colorScheme.onPrimary.darken(0.1),
        primaryContainer: colorScheme.primaryContainer.darken(0.1),
        onPrimaryContainer: colorScheme.onPrimaryContainer.darken(0.1),
        inversePrimary: colorScheme.inversePrimary.darken(0.1),
        secondary: colorScheme.secondary.darken(0.05),
        onSecondary: colorScheme.onSecondary.darken(0.05),
        secondaryContainer: colorScheme.secondaryContainer.darken(0.05),
        onSecondaryContainer: colorScheme.onSecondaryContainer.darken(0.05),
        error: colorScheme.error.darken(0.05),
        surface: Colors.black,
        onSurface: colorScheme.onSurface.darken(0.15),
        surfaceTint: colorScheme.surfaceTint.darken(),
        inverseSurface: colorScheme.inverseSurface.darken(),
        onInverseSurface: colorScheme.onInverseSurface.darken(),
        surfaceContainer: colorScheme.surfaceContainer.darken(),
        surfaceContainerHigh: colorScheme.surfaceContainerHigh.darken(),
        surfaceContainerHighest: colorScheme.surfaceContainerHighest.darken(
          0.4,
        ),
      ),
    );
  }
}
