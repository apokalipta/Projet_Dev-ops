// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$meetingServiceHash() => r'403a3f4abbfd68d70e15f3435a57c1e1aecdf9e2';

/// Provider qui retourne le service Meeting (API réelle uniquement)
///
/// Copied from [meetingService].
@ProviderFor(meetingService)
final meetingServiceProvider =
    AutoDisposeProvider<MeetingServiceInterface>.internal(
  meetingService,
  name: r'meetingServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$meetingServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MeetingServiceRef = AutoDisposeProviderRef<MeetingServiceInterface>;
String _$transcriptionServiceHash() =>
    r'2bde708c7a39c602f0a89b9704b64224ee403dbc';

/// Provider qui retourne le service Transcription (API réelle uniquement)
///
/// Copied from [transcriptionService].
@ProviderFor(transcriptionService)
final transcriptionServiceProvider =
    AutoDisposeProvider<TranscriptionServiceInterface>.internal(
  transcriptionService,
  name: r'transcriptionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transcriptionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TranscriptionServiceRef
    = AutoDisposeProviderRef<TranscriptionServiceInterface>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
