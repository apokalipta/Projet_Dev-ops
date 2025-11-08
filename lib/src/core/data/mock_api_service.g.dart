// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mockApiServiceHash() => r'4d871119758a2b321d83d309c474835f81d10a39';

/// Service API mocké pour le développement
///
/// Ce service simule les appels API avec des données mockées et des délais réseau.
/// Utilisez ce service pendant le développement pour tester l'UI sans backend.
///
/// Copied from [mockApiService].
@ProviderFor(mockApiService)
final mockApiServiceProvider = AutoDisposeProvider<MockApiService>.internal(
  mockApiService,
  name: r'mockApiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mockApiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MockApiServiceRef = AutoDisposeProviderRef<MockApiService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
