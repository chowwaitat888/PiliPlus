import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

/// Liquid Glass 风格容器：毛玻璃模糊 + 半透明底色 + 顶部高光 + 细边框。
///
/// 用在悬浮于内容之上的界面元素（顶栏、底栏、卡片、弹窗）上。
/// 注意：[BackdropFilter] 需要下方有已绘制的内容才能看出模糊效果；
/// 放在纯色背景上时，主要靠半透明底色 + 高光呈现玻璃感。
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.blurSigma = 20.0,
    this.tintAlpha,
    this.padding,
    this.margin,
    this.showBorder = true,
  });

  final Widget child;

  /// 玻璃圆角，Liquid Glass 风格通常很大（24~32）。
  final BorderRadiusGeometry borderRadius;

  /// 背景模糊强度。
  final double blurSigma;

  /// 底色不透明度，默认浅色 0.6 / 深色 0.52。
  final double? tintAlpha;

  final EdgeInsetsGeometry? padding;

  final EdgeInsetsGeometry? margin;

  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pad = padding;
    final isDark = colorScheme.brightness == Brightness.dark;
    final alpha = tintAlpha ?? (isDark ? 0.52 : 0.6);
    final tint = colorScheme.surface.withValues(alpha: alpha);
    final highlightAlpha = isDark ? 0.12 : 0.18;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.black.withValues(alpha: 0.08);

    Widget result = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.alphaBlend(
                  Colors.white.withValues(alpha: highlightAlpha),
                  tint,
                ),
                Color.alphaBlend(
                  Colors.white.withValues(alpha: highlightAlpha * 0.25),
                  tint,
                ),
              ],
            ),
            border: showBorder ? Border.all(color: borderColor) : null,
          ),
          child: pad == null
              ? child
              : Padding(padding: pad, child: child),
        ),
      ),
    );
    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }
    return result;
  }
}

/// 玻璃质感的 [AppBar]：默认用毛玻璃背景（[BackdropFilter] 模糊滚动内容），
/// 替代原来不透明的顶栏。调用方显式传入 [AppBar.backgroundColor] 或
/// [AppBar.flexibleSpace] 时以调用方为准。
class GlassAppBar extends AppBar {
  GlassAppBar({
    super.key,
    super.leading,
    super.automaticallyImplyLeading,
    super.title,
    super.actions,
    super.automaticallyImplyActions,
    Widget? flexibleSpace,
    super.bottom,
    double? elevation,
    double? scrolledUnderElevation,
    super.notificationPredicate,
    super.shadowColor,
    super.surfaceTintColor,
    super.shape,
    Color? backgroundColor,
    super.foregroundColor,
    super.iconTheme,
    super.actionsIconTheme,
    super.primary,
    super.centerTitle,
    super.excludeHeaderSemantics,
    super.titleSpacing,
    super.toolbarOpacity,
    super.bottomOpacity,
    super.toolbarHeight,
    super.leadingWidth,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.systemOverlayStyle,
    super.forceMaterialTransparency,
    super.useDefaultSemanticsOrder,
    super.clipBehavior,
    super.actionsPadding,
    super.animateColor,
  }) : super(
         flexibleSpace: flexibleSpace ?? const _GlassAppBarBackground(),
         elevation: elevation ?? 0,
         scrolledUnderElevation: scrolledUnderElevation ?? 0,
         backgroundColor: backgroundColor ?? Colors.transparent,
       );
}

/// 玻璃质感的 [AppBar] 背景：滚动内容在顶栏下方经过时会被模糊。
///
/// 默认不设置底色，玻璃层由 [_GlassAppBarBackground] 绘制；
/// 调用方显式传入 [AppBar.flexibleSpace] 或 [AppBar.backgroundColor] 时
/// 以调用方为准。
class _GlassAppBarBackground extends StatelessWidget {
  const _GlassAppBarBackground();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final tint = colorScheme.surface.withValues(
      alpha: isDark ? 0.62 : 0.68,
    );
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.alphaBlend(
                  Colors.white.withValues(
                    alpha: isDark ? 0.1 : 0.16,
                  ),
                  tint,
                ),
                tint,
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
