// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$meetingServiceHash() => r'3e01df050204d9879447d30662aa9c1ae47ba933';

/// Provider qui retourne le service Meeting approprié selon la configuration
///
/// - Si `AppConfig.useMockData` est `true`, retourne MockApiService
/// - Sinon, retourne MeetingApiService (API réelle)
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
    r'f1cee3b0c5f393b5acb385b912d7817f7501cfec';

/// Provider qui retourne le service Transcription approprié selon la configuration
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
