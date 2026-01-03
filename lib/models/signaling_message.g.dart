// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signaling_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OfferMessageImpl _$$OfferMessageImplFromJson(Map<String, dynamic> json) =>
    _$OfferMessageImpl(
      from: json['from'] as String,
      to: json['to'] as String,
      sdp: json['sdp'] as Map<String, dynamic>,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$OfferMessageImplToJson(_$OfferMessageImpl instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'sdp': instance.sdp,
      'runtimeType': instance.$type,
    };

_$AnswerMessageImpl _$$AnswerMessageImplFromJson(Map<String, dynamic> json) =>
    _$AnswerMessageImpl(
      from: json['from'] as String,
      to: json['to'] as String,
      sdp: json['sdp'] as Map<String, dynamic>,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$AnswerMessageImplToJson(_$AnswerMessageImpl instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'sdp': instance.sdp,
      'runtimeType': instance.$type,
    };

_$IceCandidateMessageImpl _$$IceCandidateMessageImplFromJson(
  Map<String, dynamic> json,
) => _$IceCandidateMessageImpl(
  from: json['from'] as String,
  to: json['to'] as String,
  candidate: json['candidate'] as Map<String, dynamic>,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$IceCandidateMessageImplToJson(
  _$IceCandidateMessageImpl instance,
) => <String, dynamic>{
  'from': instance.from,
  'to': instance.to,
  'candidate': instance.candidate,
  'runtimeType': instance.$type,
};

_$ContactRequestMessageImpl _$$ContactRequestMessageImplFromJson(
  Map<String, dynamic> json,
) => _$ContactRequestMessageImpl(
  from: json['from'] as String,
  to: json['to'] as String,
  name: json['name'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$ContactRequestMessageImplToJson(
  _$ContactRequestMessageImpl instance,
) => <String, dynamic>{
  'from': instance.from,
  'to': instance.to,
  'name': instance.name,
  'runtimeType': instance.$type,
};

_$ContactResponseMessageImpl _$$ContactResponseMessageImplFromJson(
  Map<String, dynamic> json,
) => _$ContactResponseMessageImpl(
  from: json['from'] as String,
  to: json['to'] as String,
  accepted: json['accepted'] as bool,
  name: json['name'] as String?,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$ContactResponseMessageImplToJson(
  _$ContactResponseMessageImpl instance,
) => <String, dynamic>{
  'from': instance.from,
  'to': instance.to,
  'accepted': instance.accepted,
  'name': instance.name,
  'runtimeType': instance.$type,
};

_$ChatPresenceMessageImpl _$$ChatPresenceMessageImplFromJson(
  Map<String, dynamic> json,
) => _$ChatPresenceMessageImpl(
  from: json['from'] as String,
  to: json['to'] as String,
  isOpened: json['isOpened'] as bool,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$ChatPresenceMessageImplToJson(
  _$ChatPresenceMessageImpl instance,
) => <String, dynamic>{
  'from': instance.from,
  'to': instance.to,
  'isOpened': instance.isOpened,
  'runtimeType': instance.$type,
};

_$ContactDeletedMessageImpl _$$ContactDeletedMessageImplFromJson(
  Map<String, dynamic> json,
) => _$ContactDeletedMessageImpl(
  from: json['from'] as String,
  to: json['to'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$$ContactDeletedMessageImplToJson(
  _$ContactDeletedMessageImpl instance,
) => <String, dynamic>{
  'from': instance.from,
  'to': instance.to,
  'runtimeType': instance.$type,
};
