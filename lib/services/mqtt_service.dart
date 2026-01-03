import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:logger/logger.dart';
import '../models/signaling_message.dart';
import '../utils/id_generator.dart';
import '../database/database.dart';

class MqttService {
  late MqttServerClient _client;
  final String _broker = 'broker.hivemq.com';
  final int _port = 1883;
  late String _userId;
  final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  final _signalingController = StreamController<SignalingMessage>.broadcast();
  Stream<SignalingMessage> get signalingMessages => _signalingController.stream;

  final _connectionController =
      StreamController<MqttConnectionState>.broadcast();
  Stream<MqttConnectionState> get connectionState =>
      _connectionController.stream;

  bool get isConnected =>
      _client.connectionStatus?.state == MqttConnectionState.connected;

  MqttService({String? userId}) {
    _userId = userId ?? ''; // Will be set during initializeWithDatabase
    _client = MqttServerClient(_broker, 'flutter_client_temp');
    _client.port = _port;
    _client.keepAlivePeriod = 60;
    _client.logging(on: false);
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
  }

  Future<void> initializeWithDatabase(AppDatabase database) async {
    if (_userId.isEmpty) {
      _userId = await IdGenerator.getUserId(database);
      _client = MqttServerClient(_broker, 'flutter_client_$_userId');
      _client.port = _port;
      _client.keepAlivePeriod = 60;
      _client.logging(on: false);
      _client.onConnected = _onConnected;
      _client.onDisconnected = _onDisconnected;
      _client.onSubscribed = _onSubscribed;
    }
  }

  Future<bool> connect() async {
    try {
      _logger.i('Connecting to $_broker:$_port');
      await _client.connect();

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        _logger.i('Connected successfully');

        // Subscribe to user's signaling topic
        final topic = 'p2p-chat/signaling/$_userId';
        _client.subscribe(topic, MqttQos.atLeastOnce);

        // Listen to messages
        _client.updates?.listen(_onMessage);

        return true;
      }
    } catch (e) {
      _logger.e('Connection failed', error: e);
      _connectionController.add(MqttConnectionState.disconnected);
    }
    return false;
  }

  void disconnect() {
    _logger.i('Disconnecting');
    _client.disconnect();
  }

  void sendSignalingMessage(SignalingMessage message, String targetUserId) {
    if (!isConnected) {
      _logger.w('Cannot send message - not connected');
      return;
    }

    final topic = 'p2p-chat/signaling/$targetUserId';
    final payload = jsonEncode(message.toJson());

    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);

    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    _logger.d('Sent signaling message to $targetUserId');
  }

  void _onConnected() {
    _logger.i('Connected callback');
    _connectionController.add(MqttConnectionState.connected);
  }

  void _onDisconnected() {
    _logger.w('Disconnected callback');
    _connectionController.add(MqttConnectionState.disconnected);
  }

  void _onSubscribed(String topic) {
    _logger.i('Subscribed to $topic');
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final message in messages) {
      final payload = message.payload as MqttPublishMessage;
      final messageString = MqttPublishPayload.bytesToStringAsString(
        payload.payload.message,
      );

      try {
        final json = jsonDecode(messageString) as Map<String, dynamic>;
        final signalingMessage = SignalingMessage.fromJson(json);
        _signalingController.add(signalingMessage);
        _logger.d(
          'Received signaling message: ${signalingMessage.runtimeType}',
        );
      } catch (e) {
        _logger.e('Failed to parse message', error: e);
      }
    }
  }

  String get userId => _userId;

  void dispose() {
    _signalingController.close();
    _connectionController.close();
    disconnect();
  }
}
