import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient client;

  Function(Map<String, dynamic>)? onMessage;

  MqttService() {
    client = MqttServerClient(
      'broker.hivemq.com',
      'flutter_skysense_${DateTime.now().millisecondsSinceEpoch}',
    );

    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.logging(on: false);
  }

  Future<void> connect() async {
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(client.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      client.disconnect();
      return;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      subscribe();
    }
  }

  void subscribe() {
    const topic = 'ecowitt/weather';

    client.subscribe(topic, MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> events) {
      final recMess = events.first.payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      try {
        final Map<String, dynamic> data = jsonDecode(payload);
        if (onMessage != null) {
          onMessage!(data);
        }
      } catch (e) {
        // Payload bukan JSON → abaikan
      }
    });
  }

  void disconnect() {
    client.disconnect();
  }
}
