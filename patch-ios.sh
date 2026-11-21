#!/usr/bin/env bash
# PiliPlus iOS 打补丁脚本：上游 patch.ps1 的 bash 等价版（仅 iOS）。
#
# 背景：PiliPlus 源码依赖 Flutter 框架里一些官方没有的 API（比如
# PageView 的 horizontalDragGestureRecognizer、ScrollableState 的
# shouldIgnorePointer），这些 API 是靠 lib/scripts/*.patch 给 Flutter SDK、
# material_ui、cupertino_ui 打补丁加上去的。不打补丁直接编译会报
# 100 多个错误；打完补丁后 flutter analyze 是 0 error。
# 上游 CI 跑的就是 patch.ps1 iOS；这个脚本做同样的事，只是用 bash，
# 不用在 Mac 上装 PowerShell。
#
# 用法（在项目根目录）：
#   bash patch-ios.sh
# 要求：已装好 Flutter 3.47.9（fvm install 3.47.9 && fvm use 3.47.9），
# git 可用。FLUTTER_ROOT 未设置时依次找：项目内 .fvm/flutter_sdk、
# PATH 里的 flutter、~/flutter-sdk、~/flutter。
# 已打过的补丁会自动跳过，可重复运行。
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"

if [ -z "$FLUTTER_ROOT" ]; then
  if [ -d "$ROOT/.fvm/flutter_sdk" ]; then
    FLUTTER_ROOT="$ROOT/.fvm/flutter_sdk"
  elif command -v flutter >/dev/null 2>&1; then
    FLUTTER_BIN="$(command -v flutter)"
    FLUTTER_ROOT="$(cd "$(dirname "$FLUTTER_BIN")/.." && pwd)"
  elif [ -d "$HOME/flutter-sdk" ]; then
    FLUTTER_ROOT="$HOME/flutter-sdk"
  elif [ -d "$HOME/flutter" ]; then
    FLUTTER_ROOT="$HOME/flutter"
  else
    echo "找不到 Flutter SDK：请先 fvm use 3.47.9，或设置 FLUTTER_ROOT" >&2
    exit 1
  fi
fi
FLUTTER="$FLUTTER_ROOT/bin/flutter"
PUB_CACHE="${PUB_CACHE:-$HOME/.pub-cache}"
SCRIPTS="$ROOT/lib/scripts"

# 打一个补丁：已打过就跳过；打不上就报错退出。
apply_patch() {
  local dir="$1" patch="$2"
  if (cd "$dir" && git apply --check --reverse "$patch" >/dev/null 2>&1); then
    echo "already applied, skip: $(basename "$patch")"
  elif (cd "$dir" && git apply --check "$patch" >/dev/null 2>&1); then
    (cd "$dir" && git apply "$patch") && echo "applied: $(basename "$patch")"
  else
    echo "ERROR: cannot apply $patch in $dir" >&2
    exit 1
  fi
}

echo "== 1/4 项目内补丁 =="
apply_patch "$ROOT" "$SCRIPTS/bottom_sheet_ios_piliplus.patch"
apply_patch "$ROOT" "$SCRIPTS/geetest_ios.patch"

echo "== 2/4 Flutter SDK 补丁 ($FLUTTER_ROOT) =="
for p in modal_barrier text_selection mouse_cursor image_anim layout_builder \
  navigation_drawer popup_menu fab null_safety_for_selectable_region \
  selectable_region editable_text text_field scroll_position scrollable \
  scrollable_gesture draggable_scrollable_sheet scaffold text text_painter \
  sliver refresh_indicator double_tap_gesture scroll_view \
  bottom_sheet_ios_flutter navigator; do
  apply_patch "$FLUTTER_ROOT" "$SCRIPTS/$p.patch"
done

echo "== 3/4 重新拉取 material_ui 并打补丁 =="
rm -rf "$PUB_CACHE"/hosted/pub.dev/material_ui-*
(cd "$ROOT" && "$FLUTTER" pub get)
MATERIAL_DIR="$(ls -d "$PUB_CACHE"/hosted/pub.dev/material_ui-* 2>/dev/null | tail -1)"
[ -n "$MATERIAL_DIR" ] || { echo "material_ui package not found in pub cache" >&2; exit 1; }
echo "material_ui dir: $MATERIAL_DIR"
for p in modal_barrier_material navigation_drawer popup_menu fab text_field \
  scaffold refresh_indicator tabs bottom_sheet_ios_flutter_material; do
  apply_patch "$MATERIAL_DIR" "$SCRIPTS/material/$p.patch"
done

echo "== 4/4 cupertino_ui 补丁 =="
CUPERTINO_DIR="$(ls -d "$PUB_CACHE"/hosted/pub.dev/cupertino_ui-* 2>/dev/null | tail -1)"
[ -n "$CUPERTINO_DIR" ] || { echo "cupertino_ui package not found in pub cache" >&2; exit 1; }
apply_patch "$CUPERTINO_DIR" "$SCRIPTS/cupertino/bottom_sheet_ios_flutter.patch"

echo "全部补丁完成。接下来可以编译："
echo "  flutter build ios --release --no-codesign --dart-define-from-file=pili_release.json"
