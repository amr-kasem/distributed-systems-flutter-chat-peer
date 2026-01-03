import 'package:freezed_annotation/freezed_annotation.dart';

part 'peer.freezed.dart';
part 'peer.g.dart';

@freezed
class Peer with _$Peer {
  const factory Peer({
    required String id,
    required String username,
    DateTime? lastSeen,
    @Default(PeerStatus.offline) PeerStatus status,
  }) = _Peer;

  factory Peer.fromJson(Map<String, dynamic> json) => _$PeerFromJson(json);
}

enum PeerStatus { online, offline, connecting }
