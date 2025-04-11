import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('MQTT Feeds')),
        body: MyListView(),
      ),
    );
  }
}

class MyListView extends StatefulWidget {
  @override
  ListViewState createState() => ListViewState();
}

class ListViewState extends State<MyListView> {
  late List<String> feeds;
  late MqttServerClient client;

  @override
  void initState() {
    super.initState();
    feeds = [];
    Future.delayed(Duration(seconds: 1), () {
      showAlert(context); // ✅ 避免 `context` 错误
    });
    startMQTT();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: feeds.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(feeds[index]),
        );
      },
    );
  }

  void updateList(String s) {
    setState(() {
      feeds.add(s);
    });
  }

  Future<void> startMQTT() async {
    client = MqttServerClient('test.mosquitto.org', '');
    client.port = 1883;
    client.setProtocolV311();
    client.keepAlivePeriod = 30;
    client.secure = false;

    try {
      await client.connect();
    } catch (e) {
      print('client exception - $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT connected');
    } else {
      print('ERROR: MQTT connection failed');
      client.disconnect();
    }

    const topic = 'SCD41-CO2-1';
    client.subscribe(topic, MqttQos.atMostOnce);

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      if (c != null && c.isNotEmpty) {
        final receivedMessage = c[0].payload as MqttPublishMessage;
        final messageString = MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
        print('MQTT Message:: topic: <${c[0].topic}>, payload: <-- $messageString -->');
        updateList(messageString);
      }
    });
  }

  void showAlert(BuildContext context) {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("MQTT Feeds"),
      content: Text("MQTT Feeds are being displayed"),
      actions: [
        CupertinoDialogAction(
          child: Text("OK"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }
}
