import 'package:freezed_annotation/freezed_annotation.dart';

part 'signaling_message.freezed.dart';
part 'signaling_message.g.dart';

@freezed
class SignalingMessage with _$SignalingMessage {
  const factory SignalingMessage.offer({
    required String from,
    required String to,
    required Map<String, dynamic> sdp,
  }) = OfferMessage;

  const factory SignalingMessage.answer({
    required String from,
    required String to,
    required Map<String, dynamic> sdp,
  }) = AnswerMessage;

  const factory SignalingMessage.iceCandidate({
    required String from,
    required String to,
    required Map<String, dynamic> candidate,
  }) = IceCandidateMessage;

  const factory SignalingMessage.contactRequest({
    required String from,
    required String to,
    required String name, // Sender's name to show to the receiver
  }) = ContactRequestMessage;

  const factory SignalingMessage.contactResponse({
    required String from,
    required String to,
    required bool accepted,
    String? name, // Receiver's name if accepted
  }) = ContactResponseMessage;

  const factory SignalingMessage.chatPresence({
    required String from,
    required String to,
    required bool isOpened, // Whether the user has the chat screen open
  }) = ChatPresenceMessage;

  const factory SignalingMessage.contactDeleted({
    required String from,
    required String to,
  }) = ContactDeletedMessage;

  factory SignalingMessage.fromJson(Map<String, dynamic> json) =>
      _$SignalingMessageFromJson(json);
}
