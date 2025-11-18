// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recordingNotifierHash() => r'6372134e9bc1389313c31c24353d03047b24065f';

/// Provider pour l'état de l'enregistrement
///
/// Copied from [recordingNotifier].
@ProviderFor(recordingNotifier)
final recordingNotifierProvider =
    AutoDisposeProvider<RecordingNotifier>.internal(
  recordingNotifier,
  name: r'recordingNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recordingNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecordingNotifierRef = AutoDisposeProviderRef<RecordingNotifier>;
String _$recordingNotifierHash() => r'94c792f60591b82dc4b36611fa034fa8e63319a1';

/// Provider pour gérer l'enregistrement de réunion
///
/// Copied from [RecordingNotifier].
@ProviderFor(RecordingNotifier)
final recordingNotifierProvider =
    AutoDisposeNotifierProvider<RecordingNotifier, RecordingState>.internal(
  RecordingNotifier.new,
  name: r'recordingNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recordingNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RecordingNotifier = AutoDisposeNotifier<RecordingState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
