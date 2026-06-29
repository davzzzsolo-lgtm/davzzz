import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class ChatPage extends StatefulWidget {
  final String currentUsername;
  final String sessionKey;

  const ChatPage({
    super.key,
    required this.currentUsername,
    required this.sessionKey,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late WebSocketChannel _channel;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _connecting = true;
  bool _online = false;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    const String wsUrl = 'http://draoffice.danzxnhosting.my.id:11860';
    _channel = IOWebSocketChannel.connect(Uri.parse(wsUrl));
    
    _channel.stream.listen(
      (msg) {
        final data = jsonDecode(msg);
        if (data['type'] == 'myInfo' && data['valid'] == true) {
          _channel.sink.add(jsonEncode({'type': 'auth', 'key': widget.sessionKey}));
          setState(() { _online = true; _connecting = false; });
        } 
        else if (data['type'] == 'chat') {
          setState(() => _messages.add(data['message']));
          _scrollDown();
        }
        else if (data['type'] == 'messages') {
          setState(() => _messages = List.from(data['messages']));
          _scrollDown();
        }
      },
      onError: (_) => setState(() => _connecting = false),
    );
    
    _channel.sink.add(jsonEncode({
      'type': 'validate',
      'key': widget.sessionKey,
      'androidId': '12345',
    }));
  }

  void _send() {
    if (_messageController.text.isEmpty || !_online) return;
    _channel.sink.add(jsonEncode({
      'type': 'chat',
      'to': 'public',
      'message': _messageController.text,
    }));
    _messageController.clear();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _time(String t) {
    try { return DateFormat('HH:mm').format(DateTime.parse(t)); } catch (_) { return ''; }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Chat', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _online ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              _online ? 'ONLINE' : 'OFFLINE',
              style: TextStyle(color: _online ? Colors.green : Colors.red, fontSize: 11),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _connecting
                ? const Center(child: CircularProgressIndicator())
                : !_online
                    ? const Center(child: Text('Tidak terhubung', style: TextStyle(color: Colors.white54)))
                    : _messages.isEmpty
                        ? const Center(child: Text('Belum ada pesan', style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(12),
                            itemCount: _messages.length,
                            itemBuilder: (_, i) {
                              final m = _messages[i];
                              final me = m['from'] == widget.currentUsername;
                              return Align(
                                alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: me ? Colors.blue.shade800 : Colors.grey.shade800,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!me) Text(m['from'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                                      const SizedBox(height: 2),
                                      Text(m['message'] ?? '', style: const TextStyle(color: Colors.white)),
                                      Text(_time(m['time']), style: const TextStyle(color: Colors.white54, fontSize: 9)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          if (_online)
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.grey.shade900,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Pesan...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _send,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}