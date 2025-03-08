
# после обновления пакета
flutter pub cache clean
flutter clean
flutter pub get


flutter pub add flutter_riverpod riverpod_annotation hooks_riverpod freezed_annotation json_annotation go_router
flutter pub add --dev riverpod_generator build_runner custom_lint riverpod_lint freezed json_serializable



flutter pub add flutter_riverpod
flutter pub add riverpod_annotation
flutter pub add dev:riverpod_generator
flutter pub add dev:build_runner
flutter pub add dev:custom_lint
flutter pub add dev:riverpod_lint
flutter pub add hooks_riverpod

flutter pub add freezed_annotation
flutter pub add dev:build_runner
flutter pub add dev:freezed

flutter pub add json_annotation
flutter pub add dev:json_serializable

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';


dart run build_runner build
dart run build_runner watch -d


flutter pub run build_runner build --delete-conflicting-outputs

flutter pub run build_runner watch --delete-conflicting-outputs


flutter pub add http