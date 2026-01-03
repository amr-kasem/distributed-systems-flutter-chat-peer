// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signaling_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SignalingMessage _$SignalingMessageFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'offer':
      return OfferMessage.fromJson(json);
    case 'answer':
      return AnswerMessage.fromJson(json);
    case 'iceCandidate':
      return IceCandidateMessage.fromJson(json);
    case 'contactRequest':
      return ContactRequestMessage.fromJson(json);
    case 'contactResponse':
      return ContactResponseMessage.fromJson(json);
    case 'chatPresence':
      return ChatPresenceMessage.fromJson(json);
    case 'contactDeleted':
      return ContactDeletedMessage.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'runtimeType',
        'SignalingMessage',
        'Invalid union type "${json['runtimeType']}"!',
      );
  }
}

/// @nodoc
mixin _$SignalingMessage {
  String get from => throw _privateConstructorUsedError;
  String get to => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    offer,
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    answer,
    required TResult Function(
      String from,
      String to,
      Map<String, dynamic> candidate,
    )
    iceCandidate,
    required TResult Function(String from, String to, String name)
    contactRequest,
    required TResult Function(
      String from,
      String to,
      bool accepted,
      String? name,
    )
    contactResponse,
    required TResult Function(String from, String to, bool isOpened)
    chatPresence,
    required TResult Function(String from, String to) contactDeleted,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult? Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult? Function(String from, String to, String name)? contactRequest,
    TResult? Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult? Function(String from, String to, bool isOpened)? chatPresence,
    TResult? Function(String from, String to)? contactDeleted,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult Function(String from, String to, String name)? contactRequest,
    TResult Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult Function(String from, String to, bool isOpened)? chatPresence,
    TResult Function(String from, String to)? contactDeleted,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OfferMessage value) offer,
    required TResult Function(AnswerMessage value) answer,
    required TResult Function(IceCandidateMessage value) iceCandidate,
    required TResult Function(ContactRequestMessage value) contactRequest,
    required TResult Function(ContactResponseMessage value) contactResponse,
    required TResult Function(ChatPresenceMessage value) chatPresence,
    required TResult Function(ContactDeletedMessage value) contactDeleted,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OfferMessage value)? offer,
    TResult? Function(AnswerMessage value)? answer,
    TResult? Function(IceCandidateMessage value)? iceCandidate,
    TResult? Function(ContactRequestMessage value)? contactRequest,
    TResult? Function(ContactResponseMessage value)? contactResponse,
    TResult? Function(ChatPresenceMessage value)? chatPresence,
    TResult? Function(ContactDeletedMessage value)? contactDeleted,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OfferMessage value)? offer,
    TResult Function(AnswerMessage value)? answer,
    TResult Function(IceCandidateMessage value)? iceCandidate,
    TResult Function(ContactRequestMessage value)? contactRequest,
    TResult Function(ContactResponseMessage value)? contactResponse,
    TResult Function(ChatPresenceMessage value)? chatPresence,
    TResult Function(ContactDeletedMessage value)? contactDeleted,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this SignalingMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignalingMessageCopyWith<SignalingMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignalingMessageCopyWith<$Res> {
  factory $SignalingMessageCopyWith(
    SignalingMessage value,
    $Res Function(SignalingMessage) then,
  ) = _$SignalingMessageCopyWithImpl<$Res, SignalingMessage>;
  @useResult
  $Res call({String from, String to});
}

/// @nodoc
class _$SignalingMessageCopyWithImpl<$Res, $Val extends SignalingMessage>
    implements $SignalingMessageCopyWith<$Res> {
  _$SignalingMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? from = null, Object? to = null}) {
    return _then(
      _value.copyWith(
            from: null == from
                ? _value.from
                : from // ignore: cast_nullable_to_non_nullable
                      as String,
            to: null == to
                ? _value.to
                : to // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OfferMessageImplCopyWith<$Res>
    implements $SignalingMessageCopyWith<$Res> {
  factory _$$OfferMessageImplCopyWith(
    _$OfferMessageImpl value,
    $Res Function(_$OfferMessageImpl) then,
  ) = __$$OfferMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String from, String to, Map<String, dynamic> sdp});
}

/// @nodoc
class __$$OfferMessageImplCopyWithImpl<$Res>
    extends _$SignalingMessageCopyWithImpl<$Res, _$OfferMessageImpl>
    implements _$$OfferMessageImplCopyWith<$Res> {
  __$$OfferMessageImplCopyWithImpl(
    _$OfferMessageImpl _value,
    $Res Function(_$OfferMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? from = null, Object? to = null, Object? sdp = null}) {
    return _then(
      _$OfferMessageImpl(
        from: null == from
            ? _value.from
            : from // ignore: cast_nullable_to_non_nullable
                  as String,
        to: null == to
            ? _value.to
            : to // ignore: cast_nullable_to_non_nullable
                  as String,
        sdp: null == sdp
            ? _value._sdp
            : sdp // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OfferMessageImpl implements OfferMessage {
  const _$OfferMessageImpl({
    required this.from,
    required this.to,
    required final Map<String, dynamic> sdp,
    final String? $type,
  }) : _sdp = sdp,
       $type = $type ?? 'offer';

  factory _$OfferMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$OfferMessageImplFromJson(json);

  @override
  final String from;
  @override
  final String to;
  final Map<String, dynamic> _sdp;
  @override
  Map<String, dynamic> get sdp {
    if (_sdp is EqualUnmodifiableMapView) return _sdp;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_sdp);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SignalingMessage.offer(from: $from, to: $to, sdp: $sdp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OfferMessageImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            const DeepCollectionEquality().equals(other._sdp, _sdp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    from,
    to,
    const DeepCollectionEquality().hash(_sdp),
  );

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OfferMessageImplCopyWith<_$OfferMessageImpl> get copyWith =>
      __$$OfferMessageImplCopyWithImpl<_$OfferMessageImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    offer,
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    answer,
    required TResult Function(
      String from,
      String to,
      Map<String, dynamic> candidate,
    )
    iceCandidate,
    required TResult Function(String from, String to, String name)
    contactRequest,
    required TResult Function(
      String from,
      String to,
      bool accepted,
      String? name,
    )
    contactResponse,
    required TResult Function(String from, String to, bool isOpened)
    chatPresence,
    required TResult Function(String from, String to) contactDeleted,
  }) {
    return offer(from, to, sdp);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult? Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult? Function(String from, String to, String name)? contactRequest,
    TResult? Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult? Function(String from, String to, bool isOpened)? chatPresence,
    TResult? Function(String from, String to)? contactDeleted,
  }) {
    return offer?.call(from, to, sdp);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult Function(String from, String to, String name)? contactRequest,
    TResult Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult Function(String from, String to, bool isOpened)? chatPresence,
    TResult Function(String from, String to)? contactDeleted,
    required TResult orElse(),
  }) {
    if (offer != null) {
      return offer(from, to, sdp);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OfferMessage value) offer,
    required TResult Function(AnswerMessage value) answer,
    required TResult Function(IceCandidateMessage value) iceCandidate,
    required TResult Function(ContactRequestMessage value) contactRequest,
    required TResult Function(ContactResponseMessage value) contactResponse,
    required TResult Function(ChatPresenceMessage value) chatPresence,
    required TResult Function(ContactDeletedMessage value) contactDeleted,
  }) {
    return offer(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OfferMessage value)? offer,
    TResult? Function(AnswerMessage value)? answer,
    TResult? Function(IceCandidateMessage value)? iceCandidate,
    TResult? Function(ContactRequestMessage value)? contactRequest,
    TResult? Function(ContactResponseMessage value)? contactResponse,
    TResult? Function(ChatPresenceMessage value)? chatPresence,
    TResult? Function(ContactDeletedMessage value)? contactDeleted,
  }) {
    return offer?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OfferMessage value)? offer,
    TResult Function(AnswerMessage value)? answer,
    TResult Function(IceCandidateMessage value)? iceCandidate,
    TResult Function(ContactRequestMessage value)? contactRequest,
    TResult Function(ContactResponseMessage value)? contactResponse,
    TResult Function(ChatPresenceMessage value)? chatPresence,
    TResult Function(ContactDeletedMessage value)? contactDeleted,
    required TResult orElse(),
  }) {
    if (offer != null) {
      return offer(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$OfferMessageImplToJson(this);
  }
}

abstract class OfferMessage implements SignalingMessage {
  const factory OfferMessage({
    required final String from,
    required final String to,
    required final Map<String, dynamic> sdp,
  }) = _$OfferMessageImpl;

  factory OfferMessage.fromJson(Map<String, dynamic> json) =
      _$OfferMessageImpl.fromJson;

  @override
  String get from;
  @override
  String get to;
  Map<String, dynamic> get sdp;

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OfferMessageImplCopyWith<_$OfferMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AnswerMessageImplCopyWith<$Res>
    implements $SignalingMessageCopyWith<$Res> {
  factory _$$AnswerMessageImplCopyWith(
    _$AnswerMessageImpl value,
    $Res Function(_$AnswerMessageImpl) then,
  ) = __$$AnswerMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String from, String to, Map<String, dynamic> sdp});
}

/// @nodoc
class __$$AnswerMessageImplCopyWithImpl<$Res>
    extends _$SignalingMessageCopyWithImpl<$Res, _$AnswerMessageImpl>
    implements _$$AnswerMessageImplCopyWith<$Res> {
  __$$AnswerMessageImplCopyWithImpl(
    _$AnswerMessageImpl _value,
    $Res Function(_$AnswerMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? from = null, Object? to = null, Object? sdp = null}) {
    return _then(
      _$AnswerMessageImpl(
        from: null == from
            ? _value.from
            : from // ignore: cast_nullable_to_non_nullable
                  as String,
        to: null == to
            ? _value.to
            : to // ignore: cast_nullable_to_non_nullable
                  as String,
        sdp: null == sdp
            ? _value._sdp
            : sdp // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AnswerMessageImpl implements AnswerMessage {
  const _$AnswerMessageImpl({
    required this.from,
    required this.to,
    required final Map<String, dynamic> sdp,
    final String? $type,
  }) : _sdp = sdp,
       $type = $type ?? 'answer';

  factory _$AnswerMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnswerMessageImplFromJson(json);

  @override
  final String from;
  @override
  final String to;
  final Map<String, dynamic> _sdp;
  @override
  Map<String, dynamic> get sdp {
    if (_sdp is EqualUnmodifiableMapView) return _sdp;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_sdp);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SignalingMessage.answer(from: $from, to: $to, sdp: $sdp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnswerMessageImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            const DeepCollectionEquality().equals(other._sdp, _sdp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    from,
    to,
    const DeepCollectionEquality().hash(_sdp),
  );

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnswerMessageImplCopyWith<_$AnswerMessageImpl> get copyWith =>
      __$$AnswerMessageImplCopyWithImpl<_$AnswerMessageImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    offer,
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    answer,
    required TResult Function(
      String from,
      String to,
      Map<String, dynamic> candidate,
    )
    iceCandidate,
    required TResult Function(String from, String to, String name)
    contactRequest,
    required TResult Function(
      String from,
      String to,
      bool accepted,
      String? name,
    )
    contactResponse,
    required TResult Function(String from, String to, bool isOpened)
    chatPresence,
    required TResult Function(String from, String to) contactDeleted,
  }) {
    return answer(from, to, sdp);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult? Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult? Function(String from, String to, String name)? contactRequest,
    TResult? Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult? Function(String from, String to, bool isOpened)? chatPresence,
    TResult? Function(String from, String to)? contactDeleted,
  }) {
    return answer?.call(from, to, sdp);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult Function(String from, String to, String name)? contactRequest,
    TResult Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult Function(String from, String to, bool isOpened)? chatPresence,
    TResult Function(String from, String to)? contactDeleted,
    required TResult orElse(),
  }) {
    if (answer != null) {
      return answer(from, to, sdp);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OfferMessage value) offer,
    required TResult Function(AnswerMessage value) answer,
    required TResult Function(IceCandidateMessage value) iceCandidate,
    required TResult Function(ContactRequestMessage value) contactRequest,
    required TResult Function(ContactResponseMessage value) contactResponse,
    required TResult Function(ChatPresenceMessage value) chatPresence,
    required TResult Function(ContactDeletedMessage value) contactDeleted,
  }) {
    return answer(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OfferMessage value)? offer,
    TResult? Function(AnswerMessage value)? answer,
    TResult? Function(IceCandidateMessage value)? iceCandidate,
    TResult? Function(ContactRequestMessage value)? contactRequest,
    TResult? Function(ContactResponseMessage value)? contactResponse,
    TResult? Function(ChatPresenceMessage value)? chatPresence,
    TResult? Function(ContactDeletedMessage value)? contactDeleted,
  }) {
    return answer?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OfferMessage value)? offer,
    TResult Function(AnswerMessage value)? answer,
    TResult Function(IceCandidateMessage value)? iceCandidate,
    TResult Function(ContactRequestMessage value)? contactRequest,
    TResult Function(ContactResponseMessage value)? contactResponse,
    TResult Function(ChatPresenceMessage value)? chatPresence,
    TResult Function(ContactDeletedMessage value)? contactDeleted,
    required TResult orElse(),
  }) {
    if (answer != null) {
      return answer(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AnswerMessageImplToJson(this);
  }
}

abstract class AnswerMessage implements SignalingMessage {
  const factory AnswerMessage({
    required final String from,
    required final String to,
    required final Map<String, dynamic> sdp,
  }) = _$AnswerMessageImpl;

  factory AnswerMessage.fromJson(Map<String, dynamic> json) =
      _$AnswerMessageImpl.fromJson;

  @override
  String get from;
  @override
  String get to;
  Map<String, dynamic> get sdp;

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnswerMessageImplCopyWith<_$AnswerMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$IceCandidateMessageImplCopyWith<$Res>
    implements $SignalingMessageCopyWith<$Res> {
  factory _$$IceCandidateMessageImplCopyWith(
    _$IceCandidateMessageImpl value,
    $Res Function(_$IceCandidateMessageImpl) then,
  ) = __$$IceCandidateMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String from, String to, Map<String, dynamic> candidate});
}

/// @nodoc
class __$$IceCandidateMessageImplCopyWithImpl<$Res>
    extends _$SignalingMessageCopyWithImpl<$Res, _$IceCandidateMessageImpl>
    implements _$$IceCandidateMessageImplCopyWith<$Res> {
  __$$IceCandidateMessageImplCopyWithImpl(
    _$IceCandidateMessageImpl _value,
    $Res Function(_$IceCandidateMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = null,
    Object? to = null,
    Object? candidate = null,
  }) {
    return _then(
      _$IceCandidateMessageImpl(
        from: null == from
            ? _value.from
            : from // ignore: cast_nullable_to_non_nullable
                  as String,
        to: null == to
            ? _value.to
            : to // ignore: cast_nullable_to_non_nullable
                  as String,
        candidate: null == candidate
            ? _value._candidate
            : candidate // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IceCandidateMessageImpl implements IceCandidateMessage {
  const _$IceCandidateMessageImpl({
    required this.from,
    required this.to,
    required final Map<String, dynamic> candidate,
    final String? $type,
  }) : _candidate = candidate,
       $type = $type ?? 'iceCandidate';

  factory _$IceCandidateMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$IceCandidateMessageImplFromJson(json);

  @override
  final String from;
  @override
  final String to;
  final Map<String, dynamic> _candidate;
  @override
  Map<String, dynamic> get candidate {
    if (_candidate is EqualUnmodifiableMapView) return _candidate;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_candidate);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SignalingMessage.iceCandidate(from: $from, to: $to, candidate: $candidate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IceCandidateMessageImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            const DeepCollectionEquality().equals(
              other._candidate,
              _candidate,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    from,
    to,
    const DeepCollectionEquality().hash(_candidate),
  );

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IceCandidateMessageImplCopyWith<_$IceCandidateMessageImpl> get copyWith =>
      __$$IceCandidateMessageImplCopyWithImpl<_$IceCandidateMessageImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    offer,
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    answer,
    required TResult Function(
      String from,
      String to,
      Map<String, dynamic> candidate,
    )
    iceCandidate,
    required TResult Function(String from, String to, String name)
    contactRequest,
    required TResult Function(
      String from,
      String to,
      bool accepted,
      String? name,
    )
    contactResponse,
    required TResult Function(String from, String to, bool isOpened)
    chatPresence,
    required TResult Function(String from, String to) contactDeleted,
  }) {
    return iceCandidate(from, to, candidate);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult? Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult? Function(String from, String to, String name)? contactRequest,
    TResult? Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult? Function(String from, String to, bool isOpened)? chatPresence,
    TResult? Function(String from, String to)? contactDeleted,
  }) {
    return iceCandidate?.call(from, to, candidate);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult Function(String from, String to, String name)? contactRequest,
    TResult Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult Function(String from, String to, bool isOpened)? chatPresence,
    TResult Function(String from, String to)? contactDeleted,
    required TResult orElse(),
  }) {
    if (iceCandidate != null) {
      return iceCandidate(from, to, candidate);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OfferMessage value) offer,
    required TResult Function(AnswerMessage value) answer,
    required TResult Function(IceCandidateMessage value) iceCandidate,
    required TResult Function(ContactRequestMessage value) contactRequest,
    required TResult Function(ContactResponseMessage value) contactResponse,
    required TResult Function(ChatPresenceMessage value) chatPresence,
    required TResult Function(ContactDeletedMessage value) contactDeleted,
  }) {
    return iceCandidate(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OfferMessage value)? offer,
    TResult? Function(AnswerMessage value)? answer,
    TResult? Function(IceCandidateMessage value)? iceCandidate,
    TResult? Function(ContactRequestMessage value)? contactRequest,
    TResult? Function(ContactResponseMessage value)? contactResponse,
    TResult? Function(ChatPresenceMessage value)? chatPresence,
    TResult? Function(ContactDeletedMessage value)? contactDeleted,
  }) {
    return iceCandidate?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OfferMessage value)? offer,
    TResult Function(AnswerMessage value)? answer,
    TResult Function(IceCandidateMessage value)? iceCandidate,
    TResult Function(ContactRequestMessage value)? contactRequest,
    TResult Function(ContactResponseMessage value)? contactResponse,
    TResult Function(ChatPresenceMessage value)? chatPresence,
    TResult Function(ContactDeletedMessage value)? contactDeleted,
    required TResult orElse(),
  }) {
    if (iceCandidate != null) {
      return iceCandidate(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$IceCandidateMessageImplToJson(this);
  }
}

abstract class IceCandidateMessage implements SignalingMessage {
  const factory IceCandidateMessage({
    required final String from,
    required final String to,
    required final Map<String, dynamic> candidate,
  }) = _$IceCandidateMessageImpl;

  factory IceCandidateMessage.fromJson(Map<String, dynamic> json) =
      _$IceCandidateMessageImpl.fromJson;

  @override
  String get from;
  @override
  String get to;
  Map<String, dynamic> get candidate;

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IceCandidateMessageImplCopyWith<_$IceCandidateMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ContactRequestMessageImplCopyWith<$Res>
    implements $SignalingMessageCopyWith<$Res> {
  factory _$$ContactRequestMessageImplCopyWith(
    _$ContactRequestMessageImpl value,
    $Res Function(_$ContactRequestMessageImpl) then,
  ) = __$$ContactRequestMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String from, String to, String name});
}

/// @nodoc
class __$$ContactRequestMessageImplCopyWithImpl<$Res>
    extends _$SignalingMessageCopyWithImpl<$Res, _$ContactRequestMessageImpl>
    implements _$$ContactRequestMessageImplCopyWith<$Res> {
  __$$ContactRequestMessageImplCopyWithImpl(
    _$ContactRequestMessageImpl _value,
    $Res Function(_$ContactRequestMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? from = null, Object? to = null, Object? name = null}) {
    return _then(
      _$ContactRequestMessageImpl(
        from: null == from
            ? _value.from
            : from // ignore: cast_nullable_to_non_nullable
                  as String,
        to: null == to
            ? _value.to
            : to // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ContactRequestMessageImpl implements ContactRequestMessage {
  const _$ContactRequestMessageImpl({
    required this.from,
    required this.to,
    required this.name,
    final String? $type,
  }) : $type = $type ?? 'contactRequest';

  factory _$ContactRequestMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContactRequestMessageImplFromJson(json);

  @override
  final String from;
  @override
  final String to;
  @override
  final String name;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SignalingMessage.contactRequest(from: $from, to: $to, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContactRequestMessageImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, from, to, name);

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContactRequestMessageImplCopyWith<_$ContactRequestMessageImpl>
  get copyWith =>
      __$$ContactRequestMessageImplCopyWithImpl<_$ContactRequestMessageImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    offer,
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    answer,
    required TResult Function(
      String from,
      String to,
      Map<String, dynamic> candidate,
    )
    iceCandidate,
    required TResult Function(String from, String to, String name)
    contactRequest,
    required TResult Function(
      String from,
      String to,
      bool accepted,
      String? name,
    )
    contactResponse,
    required TResult Function(String from, String to, bool isOpened)
    chatPresence,
    required TResult Function(String from, String to) contactDeleted,
  }) {
    return contactRequest(from, to, name);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult? Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult? Function(String from, String to, String name)? contactRequest,
    TResult? Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult? Function(String from, String to, bool isOpened)? chatPresence,
    TResult? Function(String from, String to)? contactDeleted,
  }) {
    return contactRequest?.call(from, to, name);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult Function(String from, String to, String name)? contactRequest,
    TResult Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult Function(String from, String to, bool isOpened)? chatPresence,
    TResult Function(String from, String to)? contactDeleted,
    required TResult orElse(),
  }) {
    if (contactRequest != null) {
      return contactRequest(from, to, name);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OfferMessage value) offer,
    required TResult Function(AnswerMessage value) answer,
    required TResult Function(IceCandidateMessage value) iceCandidate,
    required TResult Function(ContactRequestMessage value) contactRequest,
    required TResult Function(ContactResponseMessage value) contactResponse,
    required TResult Function(ChatPresenceMessage value) chatPresence,
    required TResult Function(ContactDeletedMessage value) contactDeleted,
  }) {
    return contactRequest(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OfferMessage value)? offer,
    TResult? Function(AnswerMessage value)? answer,
    TResult? Function(IceCandidateMessage value)? iceCandidate,
    TResult? Function(ContactRequestMessage value)? contactRequest,
    TResult? Function(ContactResponseMessage value)? contactResponse,
    TResult? Function(ChatPresenceMessage value)? chatPresence,
    TResult? Function(ContactDeletedMessage value)? contactDeleted,
  }) {
    return contactRequest?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OfferMessage value)? offer,
    TResult Function(AnswerMessage value)? answer,
    TResult Function(IceCandidateMessage value)? iceCandidate,
    TResult Function(ContactRequestMessage value)? contactRequest,
    TResult Function(ContactResponseMessage value)? contactResponse,
    TResult Function(ChatPresenceMessage value)? chatPresence,
    TResult Function(ContactDeletedMessage value)? contactDeleted,
    required TResult orElse(),
  }) {
    if (contactRequest != null) {
      return contactRequest(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ContactRequestMessageImplToJson(this);
  }
}

abstract class ContactRequestMessage implements SignalingMessage {
  const factory ContactRequestMessage({
    required final String from,
    required final String to,
    required final String name,
  }) = _$ContactRequestMessageImpl;

  factory ContactRequestMessage.fromJson(Map<String, dynamic> json) =
      _$ContactRequestMessageImpl.fromJson;

  @override
  String get from;
  @override
  String get to;
  String get name;

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContactRequestMessageImplCopyWith<_$ContactRequestMessageImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ContactResponseMessageImplCopyWith<$Res>
    implements $SignalingMessageCopyWith<$Res> {
  factory _$$ContactResponseMessageImplCopyWith(
    _$ContactResponseMessageImpl value,
    $Res Function(_$ContactResponseMessageImpl) then,
  ) = __$$ContactResponseMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String from, String to, bool accepted, String? name});
}

/// @nodoc
class __$$ContactResponseMessageImplCopyWithImpl<$Res>
    extends _$SignalingMessageCopyWithImpl<$Res, _$ContactResponseMessageImpl>
    implements _$$ContactResponseMessageImplCopyWith<$Res> {
  __$$ContactResponseMessageImplCopyWithImpl(
    _$ContactResponseMessageImpl _value,
    $Res Function(_$ContactResponseMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? from = null,
    Object? to = null,
    Object? accepted = null,
    Object? name = freezed,
  }) {
    return _then(
      _$ContactResponseMessageImpl(
        from: null == from
            ? _value.from
            : from // ignore: cast_nullable_to_non_nullable
                  as String,
        to: null == to
            ? _value.to
            : to // ignore: cast_nullable_to_non_nullable
                  as String,
        accepted: null == accepted
            ? _value.accepted
            : accepted // ignore: cast_nullable_to_non_nullable
                  as bool,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ContactResponseMessageImpl implements ContactResponseMessage {
  const _$ContactResponseMessageImpl({
    required this.from,
    required this.to,
    required this.accepted,
    this.name,
    final String? $type,
  }) : $type = $type ?? 'contactResponse';

  factory _$ContactResponseMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContactResponseMessageImplFromJson(json);

  @override
  final String from;
  @override
  final String to;
  @override
  final bool accepted;
  @override
  final String? name;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SignalingMessage.contactResponse(from: $from, to: $to, accepted: $accepted, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContactResponseMessageImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            (identical(other.accepted, accepted) ||
                other.accepted == accepted) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, from, to, accepted, name);

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContactResponseMessageImplCopyWith<_$ContactResponseMessageImpl>
  get copyWith =>
      __$$ContactResponseMessageImplCopyWithImpl<_$ContactResponseMessageImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    offer,
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    answer,
    required TResult Function(
      String from,
      String to,
      Map<String, dynamic> candidate,
    )
    iceCandidate,
    required TResult Function(String from, String to, String name)
    contactRequest,
    required TResult Function(
      String from,
      String to,
      bool accepted,
      String? name,
    )
    contactResponse,
    required TResult Function(String from, String to, bool isOpened)
    chatPresence,
    required TResult Function(String from, String to) contactDeleted,
  }) {
    return contactResponse(from, to, accepted, name);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult? Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult? Function(String from, String to, String name)? contactRequest,
    TResult? Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult? Function(String from, String to, bool isOpened)? chatPresence,
    TResult? Function(String from, String to)? contactDeleted,
  }) {
    return contactResponse?.call(from, to, accepted, name);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult Function(String from, String to, String name)? contactRequest,
    TResult Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult Function(String from, String to, bool isOpened)? chatPresence,
    TResult Function(String from, String to)? contactDeleted,
    required TResult orElse(),
  }) {
    if (contactResponse != null) {
      return contactResponse(from, to, accepted, name);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OfferMessage value) offer,
    required TResult Function(AnswerMessage value) answer,
    required TResult Function(IceCandidateMessage value) iceCandidate,
    required TResult Function(ContactRequestMessage value) contactRequest,
    required TResult Function(ContactResponseMessage value) contactResponse,
    required TResult Function(ChatPresenceMessage value) chatPresence,
    required TResult Function(ContactDeletedMessage value) contactDeleted,
  }) {
    return contactResponse(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OfferMessage value)? offer,
    TResult? Function(AnswerMessage value)? answer,
    TResult? Function(IceCandidateMessage value)? iceCandidate,
    TResult? Function(ContactRequestMessage value)? contactRequest,
    TResult? Function(ContactResponseMessage value)? contactResponse,
    TResult? Function(ChatPresenceMessage value)? chatPresence,
    TResult? Function(ContactDeletedMessage value)? contactDeleted,
  }) {
    return contactResponse?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OfferMessage value)? offer,
    TResult Function(AnswerMessage value)? answer,
    TResult Function(IceCandidateMessage value)? iceCandidate,
    TResult Function(ContactRequestMessage value)? contactRequest,
    TResult Function(ContactResponseMessage value)? contactResponse,
    TResult Function(ChatPresenceMessage value)? chatPresence,
    TResult Function(ContactDeletedMessage value)? contactDeleted,
    required TResult orElse(),
  }) {
    if (contactResponse != null) {
      return contactResponse(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ContactResponseMessageImplToJson(this);
  }
}

abstract class ContactResponseMessage implements SignalingMessage {
  const factory ContactResponseMessage({
    required final String from,
    required final String to,
    required final bool accepted,
    final String? name,
  }) = _$ContactResponseMessageImpl;

  factory ContactResponseMessage.fromJson(Map<String, dynamic> json) =
      _$ContactResponseMessageImpl.fromJson;

  @override
  String get from;
  @override
  String get to;
  bool get accepted;
  String? get name;

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContactResponseMessageImplCopyWith<_$ContactResponseMessageImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChatPresenceMessageImplCopyWith<$Res>
    implements $SignalingMessageCopyWith<$Res> {
  factory _$$ChatPresenceMessageImplCopyWith(
    _$ChatPresenceMessageImpl value,
    $Res Function(_$ChatPresenceMessageImpl) then,
  ) = __$$ChatPresenceMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String from, String to, bool isOpened});
}

/// @nodoc
class __$$ChatPresenceMessageImplCopyWithImpl<$Res>
    extends _$SignalingMessageCopyWithImpl<$Res, _$ChatPresenceMessageImpl>
    implements _$$ChatPresenceMessageImplCopyWith<$Res> {
  __$$ChatPresenceMessageImplCopyWithImpl(
    _$ChatPresenceMessageImpl _value,
    $Res Function(_$ChatPresenceMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? from = null, Object? to = null, Object? isOpened = null}) {
    return _then(
      _$ChatPresenceMessageImpl(
        from: null == from
            ? _value.from
            : from // ignore: cast_nullable_to_non_nullable
                  as String,
        to: null == to
            ? _value.to
            : to // ignore: cast_nullable_to_non_nullable
                  as String,
        isOpened: null == isOpened
            ? _value.isOpened
            : isOpened // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatPresenceMessageImpl implements ChatPresenceMessage {
  const _$ChatPresenceMessageImpl({
    required this.from,
    required this.to,
    required this.isOpened,
    final String? $type,
  }) : $type = $type ?? 'chatPresence';

  factory _$ChatPresenceMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatPresenceMessageImplFromJson(json);

  @override
  final String from;
  @override
  final String to;
  @override
  final bool isOpened;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SignalingMessage.chatPresence(from: $from, to: $to, isOpened: $isOpened)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatPresenceMessageImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            (identical(other.isOpened, isOpened) ||
                other.isOpened == isOpened));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, from, to, isOpened);

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatPresenceMessageImplCopyWith<_$ChatPresenceMessageImpl> get copyWith =>
      __$$ChatPresenceMessageImplCopyWithImpl<_$ChatPresenceMessageImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    offer,
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    answer,
    required TResult Function(
      String from,
      String to,
      Map<String, dynamic> candidate,
    )
    iceCandidate,
    required TResult Function(String from, String to, String name)
    contactRequest,
    required TResult Function(
      String from,
      String to,
      bool accepted,
      String? name,
    )
    contactResponse,
    required TResult Function(String from, String to, bool isOpened)
    chatPresence,
    required TResult Function(String from, String to) contactDeleted,
  }) {
    return chatPresence(from, to, isOpened);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult? Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult? Function(String from, String to, String name)? contactRequest,
    TResult? Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult? Function(String from, String to, bool isOpened)? chatPresence,
    TResult? Function(String from, String to)? contactDeleted,
  }) {
    return chatPresence?.call(from, to, isOpened);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult Function(String from, String to, String name)? contactRequest,
    TResult Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult Function(String from, String to, bool isOpened)? chatPresence,
    TResult Function(String from, String to)? contactDeleted,
    required TResult orElse(),
  }) {
    if (chatPresence != null) {
      return chatPresence(from, to, isOpened);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OfferMessage value) offer,
    required TResult Function(AnswerMessage value) answer,
    required TResult Function(IceCandidateMessage value) iceCandidate,
    required TResult Function(ContactRequestMessage value) contactRequest,
    required TResult Function(ContactResponseMessage value) contactResponse,
    required TResult Function(ChatPresenceMessage value) chatPresence,
    required TResult Function(ContactDeletedMessage value) contactDeleted,
  }) {
    return chatPresence(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OfferMessage value)? offer,
    TResult? Function(AnswerMessage value)? answer,
    TResult? Function(IceCandidateMessage value)? iceCandidate,
    TResult? Function(ContactRequestMessage value)? contactRequest,
    TResult? Function(ContactResponseMessage value)? contactResponse,
    TResult? Function(ChatPresenceMessage value)? chatPresence,
    TResult? Function(ContactDeletedMessage value)? contactDeleted,
  }) {
    return chatPresence?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OfferMessage value)? offer,
    TResult Function(AnswerMessage value)? answer,
    TResult Function(IceCandidateMessage value)? iceCandidate,
    TResult Function(ContactRequestMessage value)? contactRequest,
    TResult Function(ContactResponseMessage value)? contactResponse,
    TResult Function(ChatPresenceMessage value)? chatPresence,
    TResult Function(ContactDeletedMessage value)? contactDeleted,
    required TResult orElse(),
  }) {
    if (chatPresence != null) {
      return chatPresence(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatPresenceMessageImplToJson(this);
  }
}

abstract class ChatPresenceMessage implements SignalingMessage {
  const factory ChatPresenceMessage({
    required final String from,
    required final String to,
    required final bool isOpened,
  }) = _$ChatPresenceMessageImpl;

  factory ChatPresenceMessage.fromJson(Map<String, dynamic> json) =
      _$ChatPresenceMessageImpl.fromJson;

  @override
  String get from;
  @override
  String get to;
  bool get isOpened;

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatPresenceMessageImplCopyWith<_$ChatPresenceMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ContactDeletedMessageImplCopyWith<$Res>
    implements $SignalingMessageCopyWith<$Res> {
  factory _$$ContactDeletedMessageImplCopyWith(
    _$ContactDeletedMessageImpl value,
    $Res Function(_$ContactDeletedMessageImpl) then,
  ) = __$$ContactDeletedMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String from, String to});
}

/// @nodoc
class __$$ContactDeletedMessageImplCopyWithImpl<$Res>
    extends _$SignalingMessageCopyWithImpl<$Res, _$ContactDeletedMessageImpl>
    implements _$$ContactDeletedMessageImplCopyWith<$Res> {
  __$$ContactDeletedMessageImplCopyWithImpl(
    _$ContactDeletedMessageImpl _value,
    $Res Function(_$ContactDeletedMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? from = null, Object? to = null}) {
    return _then(
      _$ContactDeletedMessageImpl(
        from: null == from
            ? _value.from
            : from // ignore: cast_nullable_to_non_nullable
                  as String,
        to: null == to
            ? _value.to
            : to // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ContactDeletedMessageImpl implements ContactDeletedMessage {
  const _$ContactDeletedMessageImpl({
    required this.from,
    required this.to,
    final String? $type,
  }) : $type = $type ?? 'contactDeleted';

  factory _$ContactDeletedMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContactDeletedMessageImplFromJson(json);

  @override
  final String from;
  @override
  final String to;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SignalingMessage.contactDeleted(from: $from, to: $to)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContactDeletedMessageImpl &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, from, to);

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContactDeletedMessageImplCopyWith<_$ContactDeletedMessageImpl>
  get copyWith =>
      __$$ContactDeletedMessageImplCopyWithImpl<_$ContactDeletedMessageImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    offer,
    required TResult Function(String from, String to, Map<String, dynamic> sdp)
    answer,
    required TResult Function(
      String from,
      String to,
      Map<String, dynamic> candidate,
    )
    iceCandidate,
    required TResult Function(String from, String to, String name)
    contactRequest,
    required TResult Function(
      String from,
      String to,
      bool accepted,
      String? name,
    )
    contactResponse,
    required TResult Function(String from, String to, bool isOpened)
    chatPresence,
    required TResult Function(String from, String to) contactDeleted,
  }) {
    return contactDeleted(from, to);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult? Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult? Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult? Function(String from, String to, String name)? contactRequest,
    TResult? Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult? Function(String from, String to, bool isOpened)? chatPresence,
    TResult? Function(String from, String to)? contactDeleted,
  }) {
    return contactDeleted?.call(from, to);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String from, String to, Map<String, dynamic> sdp)? offer,
    TResult Function(String from, String to, Map<String, dynamic> sdp)? answer,
    TResult Function(String from, String to, Map<String, dynamic> candidate)?
    iceCandidate,
    TResult Function(String from, String to, String name)? contactRequest,
    TResult Function(String from, String to, bool accepted, String? name)?
    contactResponse,
    TResult Function(String from, String to, bool isOpened)? chatPresence,
    TResult Function(String from, String to)? contactDeleted,
    required TResult orElse(),
  }) {
    if (contactDeleted != null) {
      return contactDeleted(from, to);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OfferMessage value) offer,
    required TResult Function(AnswerMessage value) answer,
    required TResult Function(IceCandidateMessage value) iceCandidate,
    required TResult Function(ContactRequestMessage value) contactRequest,
    required TResult Function(ContactResponseMessage value) contactResponse,
    required TResult Function(ChatPresenceMessage value) chatPresence,
    required TResult Function(ContactDeletedMessage value) contactDeleted,
  }) {
    return contactDeleted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OfferMessage value)? offer,
    TResult? Function(AnswerMessage value)? answer,
    TResult? Function(IceCandidateMessage value)? iceCandidate,
    TResult? Function(ContactRequestMessage value)? contactRequest,
    TResult? Function(ContactResponseMessage value)? contactResponse,
    TResult? Function(ChatPresenceMessage value)? chatPresence,
    TResult? Function(ContactDeletedMessage value)? contactDeleted,
  }) {
    return contactDeleted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OfferMessage value)? offer,
    TResult Function(AnswerMessage value)? answer,
    TResult Function(IceCandidateMessage value)? iceCandidate,
    TResult Function(ContactRequestMessage value)? contactRequest,
    TResult Function(ContactResponseMessage value)? contactResponse,
    TResult Function(ChatPresenceMessage value)? chatPresence,
    TResult Function(ContactDeletedMessage value)? contactDeleted,
    required TResult orElse(),
  }) {
    if (contactDeleted != null) {
      return contactDeleted(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ContactDeletedMessageImplToJson(this);
  }
}

abstract class ContactDeletedMessage implements SignalingMessage {
  const factory ContactDeletedMessage({
    required final String from,
    required final String to,
  }) = _$ContactDeletedMessageImpl;

  factory ContactDeletedMessage.fromJson(Map<String, dynamic> json) =
      _$ContactDeletedMessageImpl.fromJson;

  @override
  String get from;
  @override
  String get to;

  /// Create a copy of SignalingMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContactDeletedMessageImplCopyWith<_$ContactDeletedMessageImpl>
  get copyWith => throw _privateConstructorUsedError;
}
