// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PeerImpl _$$PeerImplFromJson(Map<String, dynamic> json) => _$PeerImpl(
  id: json['id'] as String,
  username: json['username'] as String,
  lastSeen: json['lastSeen'] == null
      ? null
      : DateTime.parse(json['lastSeen'] as String),
  status:
      $enumDecodeNullable(_$PeerStatusEnumMap, json['status']) ??
      PeerStatus.offline,
);

Map<String, dynamic> _$$PeerImplToJson(_$PeerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'status': _$PeerStatusEnumMap[instance.status]!,
    };

const _$PeerStatusEnumMap = {
  PeerStatus.online: 'online',
  PeerStatus.offline: 'offline',
  PeerStatus.connecting: 'connecting',
};
