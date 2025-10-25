// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MeetingModel _$MeetingModelFromJson(Map<String, dynamic> json) {
  return _MeetingModel.fromJson(json);
}

/// @nodoc
mixin _$MeetingModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // String pour faciliter JSON
  int? get duration => throw _privateConstructorUsedError;
  List<ParticipantModel> get participants => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this MeetingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeetingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeetingModelCopyWith<MeetingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeetingModelCopyWith<$Res> {
  factory $MeetingModelCopyWith(
          MeetingModel value, $Res Function(MeetingModel) then) =
      _$MeetingModelCopyWithImpl<$Res, MeetingModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      DateTime date,
      String language,
      String status,
      int? duration,
      List<ParticipantModel> participants,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$MeetingModelCopyWithImpl<$Res, $Val extends MeetingModel>
    implements $MeetingModelCopyWith<$Res> {
  _$MeetingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeetingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? date = null,
    Object? language = null,
    Object? status = null,
    Object? duration = freezed,
    Object? participants = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<ParticipantModel>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MeetingModelImplCopyWith<$Res>
    implements $MeetingModelCopyWith<$Res> {
  factory _$$MeetingModelImplCopyWith(
          _$MeetingModelImpl value, $Res Function(_$MeetingModelImpl) then) =
      __$$MeetingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      DateTime date,
      String language,
      String status,
      int? duration,
      List<ParticipantModel> participants,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$MeetingModelImplCopyWithImpl<$Res>
    extends _$MeetingModelCopyWithImpl<$Res, _$MeetingModelImpl>
    implements _$$MeetingModelImplCopyWith<$Res> {
  __$$MeetingModelImplCopyWithImpl(
      _$MeetingModelImpl _value, $Res Function(_$MeetingModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeetingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? date = null,
    Object? language = null,
    Object? status = null,
    Object? duration = freezed,
    Object? participants = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$MeetingModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<ParticipantModel>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeetingModelImpl extends _MeetingModel {
  const _$MeetingModelImpl(
      {required this.id,
      required this.title,
      required this.date,
      this.language = 'fr',
      required this.status,
      this.duration,
      required final List<ParticipantModel> participants,
      this.createdAt,
      this.updatedAt})
      : _participants = participants,
        super._();

  factory _$MeetingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeetingModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final DateTime date;
  @override
  @JsonKey()
  final String language;
  @override
  final String status;
// String pour faciliter JSON
  @override
  final int? duration;
  final List<ParticipantModel> _participants;
  @override
  List<ParticipantModel> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'MeetingModel(id: $id, title: $title, date: $date, language: $language, status: $status, duration: $duration, participants: $participants, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetingModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      date,
      language,
      status,
      duration,
      const DeepCollectionEquality().hash(_participants),
      createdAt,
      updatedAt);

  /// Create a copy of MeetingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeetingModelImplCopyWith<_$MeetingModelImpl> get copyWith =>
      __$$MeetingModelImplCopyWithImpl<_$MeetingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeetingModelImplToJson(
      this,
    );
  }
}

abstract class _MeetingModel extends MeetingModel {
  const factory _MeetingModel(
      {required final String id,
      required final String title,
      required final DateTime date,
      final String language,
      required final String status,
      final int? duration,
      required final List<ParticipantModel> participants,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$MeetingModelImpl;
  const _MeetingModel._() : super._();

  factory _MeetingModel.fromJson(Map<String, dynamic> json) =
      _$MeetingModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  DateTime get date;
  @override
  String get language;
  @override
  String get status; // String pour faciliter JSON
  @override
  int? get duration;
  @override
  List<ParticipantModel> get participants;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of MeetingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetingModelImplCopyWith<_$MeetingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ParticipantModel _$ParticipantModelFromJson(Map<String, dynamic> json) {
  return _ParticipantModel.fromJson(json);
}

/// @nodoc
mixin _$ParticipantModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  int? get speakingOrder => throw _privateConstructorUsedError;

  /// Serializes this ParticipantModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParticipantModelCopyWith<ParticipantModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticipantModelCopyWith<$Res> {
  factory $ParticipantModelCopyWith(
          ParticipantModel value, $Res Function(ParticipantModel) then) =
      _$ParticipantModelCopyWithImpl<$Res, ParticipantModel>;
  @useResult
  $Res call({String id, String name, String? email, int? speakingOrder});
}

/// @nodoc
class _$ParticipantModelCopyWithImpl<$Res, $Val extends ParticipantModel>
    implements $ParticipantModelCopyWith<$Res> {
  _$ParticipantModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = freezed,
    Object? speakingOrder = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      speakingOrder: freezed == speakingOrder
          ? _value.speakingOrder
          : speakingOrder // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ParticipantModelImplCopyWith<$Res>
    implements $ParticipantModelCopyWith<$Res> {
  factory _$$ParticipantModelImplCopyWith(_$ParticipantModelImpl value,
          $Res Function(_$ParticipantModelImpl) then) =
      __$$ParticipantModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String? email, int? speakingOrder});
}

/// @nodoc
class __$$ParticipantModelImplCopyWithImpl<$Res>
    extends _$ParticipantModelCopyWithImpl<$Res, _$ParticipantModelImpl>
    implements _$$ParticipantModelImplCopyWith<$Res> {
  __$$ParticipantModelImplCopyWithImpl(_$ParticipantModelImpl _value,
      $Res Function(_$ParticipantModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = freezed,
    Object? speakingOrder = freezed,
  }) {
    return _then(_$ParticipantModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      speakingOrder: freezed == speakingOrder
          ? _value.speakingOrder
          : speakingOrder // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ParticipantModelImpl extends _ParticipantModel {
  const _$ParticipantModelImpl(
      {required this.id, required this.name, this.email, this.speakingOrder})
      : super._();

  factory _$ParticipantModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParticipantModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? email;
  @override
  final int? speakingOrder;

  @override
  String toString() {
    return 'ParticipantModel(id: $id, name: $name, email: $email, speakingOrder: $speakingOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParticipantModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.speakingOrder, speakingOrder) ||
                other.speakingOrder == speakingOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, email, speakingOrder);

  /// Create a copy of ParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParticipantModelImplCopyWith<_$ParticipantModelImpl> get copyWith =>
      __$$ParticipantModelImplCopyWithImpl<_$ParticipantModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParticipantModelImplToJson(
      this,
    );
  }
}

abstract class _ParticipantModel extends ParticipantModel {
  const factory _ParticipantModel(
      {required final String id,
      required final String name,
      final String? email,
      final int? speakingOrder}) = _$ParticipantModelImpl;
  const _ParticipantModel._() : super._();

  factory _ParticipantModel.fromJson(Map<String, dynamic> json) =
      _$ParticipantModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get email;
  @override
  int? get speakingOrder;

  /// Create a copy of ParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParticipantModelImplCopyWith<_$ParticipantModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
