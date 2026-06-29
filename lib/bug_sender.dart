import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahan untuk Clipboard
import 'package:http/http.dart' as http;

const _kBase = 'http://draoffice.danzxnhosting.my.id:11860';

// ─── Colors ──────────────────────────────────────────────────────────────────
class _C {
  static const bg      = Color(0xFF0A0A0A);      // Darker premium background
  static const s1      = Color(0xFF1A1A2E);      // Premium dark blue
  static const s2      = Color(0xFF16213E);      // Deeper premium
  static const border  = Color(0xFFE94560);       // Premium pink/red border
  static const accent  = Color(0xFFE94560);       // Premium pink
  static const accentL = Color(0xFFFF6B8B);       // Lighter premium pink
  static const green   = Color(0xFF00D26A);       // Premium green
  static const gold    = Color(0xFFFFD700);       // Premium gold for VIP/Owner
  static const purple  = Color(0xFF9D4EDD);       // Premium purple
  static const cyan    = Color(0xFF00B4D8);       // Premium cyan
  static const red     = Color(0xFFFF1744);
  static const textP   = Color(0xFFF8F9FA);       // White with premium feel
  static const textS   = Color(0xFFB8C0FF);       // Soft lavender
  static const textM   = Color(0xFF6C63FF);       // Premium purple-gray
  static const white   = Color(0xFFFFFFFF);
}

class BugSenderPage extends StatefulWidget {
  final String sessionKey;
  final String username;
  final String role;

  const BugSenderPage({
    super.key,
    required this.sessionKey,
    required this.username,
    required this.role,
  });

  @override
  State<BugSenderPage> createState() => _BugSenderPageState();
}

class _BugSenderPageState extends State<BugSenderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  bool get _isOwner => widget.role.toLowerCase() == 'owner';
  bool get _isVip   => widget.role.toLowerCase() == 'vip';
  bool get _isPremium => _isOwner || _isVip;
  bool get _canUsePublic => _isPremium;

  // ─ Sender data ─────────────────────────────────────────────
  List<dynamic> _privateSenders = [];
  List<dynamic> _publicSenders  = [];
  bool _loadingPrivate = true;
  bool _loadingPublic  = true;
  String? _errPrivate;
  String? _errPublic;

  // ─ Add sender ──────────────────────────────────────────────
  final _numCtrl = TextEditingController();
  bool _addingPrivate = false;
  String? _pairingCode;

  // ─ Delete ──────────────────────────────────────────────────
  String? _deleting;

  Timer? _publicRefreshTimer;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _fetchPrivate();
    _fetchPublic();
    _publicRefreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchPublic());
  }

  @override
  void dispose() {
    _tab.dispose();
    _numCtrl.dispose();
    _publicRefreshTimer?.cancel();
    super.dispose();
  }

  // ─── Fetch ─────────────────────────────────────────────────
  Future<void> _fetchPrivate() async {
    setState(() { _loadingPrivate = true; _errPrivate = null; });
    try {
      final res = await http.get(
        Uri.parse('$_kBase/mySender?key=${widget.sessionKey}'),
      ).timeout(const Duration(seconds: 10));
      final d = jsonDecode(res.body);
      if (d['valid'] == true) {
        final conn = d['connections'];
        setState(() {
          if (conn is Map) {
            _privateSenders = List<dynamic>.from(conn['private'] ?? []);
          } else if (conn is List) {
            _privateSenders = List<dynamic>.from(conn);
          } else {
            _privateSenders = [];
          }
          _loadingPrivate = false;
        });
      } else {
        setState(() { _errPrivate = d['error'] ?? 'Gagal'; _loadingPrivate = false; });
      }
    } catch (e) {
      setState(() { _errPrivate = e.toString(); _loadingPrivate = false; });
    }
  }

  Future<void> _fetchPublic() async {
    setState(() { _loadingPublic = true; _errPublic = null; });
    try {
      final res = await http.get(
        Uri.parse('$_kBase/getPublicSenders?key=${widget.sessionKey}'),
      ).timeout(const Duration(seconds: 10));
      final d = jsonDecode(res.body);
      if (d['valid'] == true) {
        setState(() {
          _publicSenders = List<dynamic>.from(d['senders'] ?? []);
          _loadingPublic = false;
        });
      } else {
        setState(() { _errPublic = d['message'] ?? 'Gagal'; _loadingPublic = false; });
      }
    } catch (e) {
      setState(() { _errPublic = e.toString(); _loadingPublic = false; });
    }
  }

  // ─── Add Private Sender ────────────────────────────────────
  Future<void> _addPrivate() async {
    final num = _numCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    if (num.isEmpty) { _snack('Masukkan nomor WA dulu!', true); return; }
    setState(() { _addingPrivate = true; _pairingCode = null; });
    try {
      final res = await http.get(
        Uri.parse('$_kBase/getPairing?key=${widget.sessionKey}&number=$num'),
      ).timeout(const Duration(seconds: 20));
      final d = jsonDecode(res.body);
      if (d['valid'] == true) {
        final code = d['pairingCode']?.toString() ?? '-';
        setState(() => _pairingCode = code);
        
        // TAMPILKAN DIALOG DENGAN COPY FUNCTION
        _showPairingCodeDialog(code, num);
        
        _numCtrl.clear();
        await Future.delayed(const Duration(seconds: 30));
        _fetchPrivate();
      } else {
        _snack(d['message'] ?? 'Gagal generate pairing code', true);
      }
    } catch (e) {
      _snack('Error: $e', true);
    }
    setState(() => _addingPrivate = false);
  }

  // ─── Dialog Pairing Code dengan Copy ───────────────────────
  void _showPairingCodeDialog(String code, String number) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _C.s1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _C.accentL, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.qr_code_scanner_rounded, color: _C.gold, size: 28),
            const SizedBox(width: 10),
            const Text('Pairing Code', style: TextStyle(color: _C.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_C.accent.withOpacity(0.2), _C.purple.withOpacity(0.2)],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _C.accentL.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      color: _C.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Tombol Copy
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      _snack('Kode berhasil disalin!', false);
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Salin Kode'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Masukkan kode ini di WhatsApp → Perangkat Tertaut → Tautkan dengan nomor telepon',
              style: TextStyle(color: _C.textS, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Nomor: $number',
              style: const TextStyle(color: _C.cyan, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: _C.accentL)),
          ),
        ],
      ),
    );
  }

  // ─── Delete ────────────────────────────────────────────────
  Future<void> _deletePrivate(String sessionName) async {
    setState(() => _deleting = sessionName);
    try {
      final res = await http.get(
        Uri.parse('$_kBase/deleteSender?key=${widget.sessionKey}&session=$sessionName'),
      ).timeout(const Duration(seconds: 10));
      final d = jsonDecode(res.body);
      if (d['valid'] == true) {
        _snack('Sender dihapus', false);
        _fetchPrivate();
      } else {
        _snack(d['message'] ?? 'Gagal hapus', true);
      }
    } catch (e) {
      _snack('Error: $e', true);
    }
    setState(() => _deleting = null);
  }

  Future<void> _deletePublic(String sessionName) async {
    setState(() => _deleting = sessionName);
    try {
      final res = await http.get(
        Uri.parse('$_kBase/deletePublicSender?key=${widget.sessionKey}&session=$sessionName'),
      ).timeout(const Duration(seconds: 10));
      final d = jsonDecode(res.body);
      if (d['valid'] == true) {
        _snack('Public sender dihapus', false);
        _fetchPublic();
      } else {
        _snack(d['message'] ?? 'Gagal hapus', true);
      }
    } catch (e) {
      _snack('Error: $e', true);
    }
    setState(() => _deleting = null);
  }

  // ─── Toggle Public ─────────────────────────────────────────
  Future<void> _togglePublic(String sessionName, bool makePublic) async {
    try {
      final res = await http.get(
        Uri.parse('$_kBase/setSenderPublic?key=${widget.sessionKey}&session=$sessionName&public=$makePublic'),
      ).timeout(const Duration(seconds: 10));
      final d = jsonDecode(res.body);
      _snack(d['message'] ?? (makePublic ? 'Dijadikan public' : 'Dijadikan private'), !d['valid']);
      _fetchPrivate();
      _fetchPublic();
    } catch (e) {
      _snack('Error: $e', true);
    }
  }

  void _snack(String msg, bool isErr) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: _C.white)),
      backgroundColor: isErr ? _C.red : _C.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ));
  }

  // ─── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.s1,
        elevation: 0,
        title: Row(children: [
          Icon(_isPremium ? Icons.star_rounded : Icons.router_rounded, 
               color: _isPremium ? _C.gold : _C.accentL, size: 18),
          const SizedBox(width: 8),
          Text(
            _isPremium ? 'Premium Sender Manager' : 'Manage Sender',
            style: const TextStyle(color: _C.textP, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ]),
        iconTheme: const IconThemeData(color: _C.accentL),
        actions: [
          if (_isOwner)
            Padding(padding: const EdgeInsets.only(right: 14), child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: [
                  _badge('${_privateSenders.length}', _C.accent),
                  const SizedBox(width: 6),
                  _badge('${_publicSenders.length}', _C.green),
                ]),
              ],
            )),
          if (_isVip && !_isOwner)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: _badge('VIP Access', _C.gold),
            ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: _C.accentL,
          labelColor: _C.accentL,
          unselectedLabelColor: _C.textS,
          tabs: const [
            Tab(icon: Icon(Icons.lock_rounded, size: 16), text: 'Private'),
            Tab(icon: Icon(Icons.public_rounded, size: 16), text: 'Public'),
          ],
        ),
      ),
      body: TabBarView(controller: _tab, children: [
        _buildPrivateTab(),
        _buildPublicTab(),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _isPremium ? _C.gold : _C.accent,
        icon: _addingPrivate
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: _C.white, strokeWidth: 2))
            : Icon(_isPremium ? Icons.add_moderator_rounded : Icons.add_rounded, color: _C.white),
        label: Text(
          _isPremium ? 'Tambah Sender Premium' : 'Tambah Sender',
          style: const TextStyle(color: _C.white, fontWeight: FontWeight.bold),
        ),
        onPressed: _addingPrivate ? null : _showAddDialog,
      ),
    );
  }

  // ─── Private Tab ───────────────────────────────────────────
  Widget _buildPrivateTab() {
    return Column(children: [
      // Info banner untuk premium
      if (_isPremium)
        Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_C.gold.withOpacity(0.1), _C.purple.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.gold.withOpacity(0.3)),
          ),
          child: Row(children: [
            Icon(Icons.workspace_premium_rounded, color: _C.gold, size: 16),
            const SizedBox(width: 8),
            const Expanded(child: Text(
              'Premium Account • Semua fitur sender tersedia',
              style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w500),
            )),
          ]),
        ),

      // Summary
      Padding(padding: const EdgeInsets.fromLTRB(14, 10, 14, 4), child: Row(children: [
        _badge('${_privateSenders.length} Private Sender', _C.accent),
        const Spacer(),
        GestureDetector(
          onTap: () { setState(() => _loadingPrivate = true); _fetchPrivate(); },
          child: const Icon(Icons.refresh_rounded, color: _C.accentL, size: 18)),
      ])),

      Expanded(child: _loadingPrivate
          ? const Center(child: CircularProgressIndicator(color: _C.accentL))
          : _errPrivate != null
              ? _errorWidget(_errPrivate!, _fetchPrivate)
              : _privateSenders.isEmpty
                  ? _emptyWidget('Belum ada private sender', Icons.lock_outlined)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 100),
                      itemCount: _privateSenders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final s = _privateSenders[i];
                        return _senderCard(s, isPublic: false);
                      })),
    ]);
  }

  // ─── Public Tab ─────────────────────────────────────────
  Widget _buildPublicTab() {
    if (!_canUsePublic) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _C.gold.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _C.gold.withOpacity(0.3)),
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: _C.gold, size: 42),
            ),
            const SizedBox(height: 20),
            const Text('Upgrade ke Premium', style: TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              'Fitur Public Sender hanya tersedia\nuntuk akun Premium (Owner & VIP).',
              style: TextStyle(color: Color(0xFFB8C0FF), fontSize: 13, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_C.gold.withOpacity(0.1), _C.purple.withOpacity(0.1)]),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _C.gold.withOpacity(0.3)),
              ),
              child: const Text('Hubungi reseller untuk upgrade akun ke premium',
                style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
      );
    }

    return Column(children: [
      Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_C.green.withOpacity(0.1), _C.cyan.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _C.green.withOpacity(0.3)),
        ),
        child: const Row(children: [
          Icon(Icons.public_rounded, color: Color(0xFF00D26A), size: 16),
          SizedBox(width: 8),
          Expanded(child: Text(
            'Sender public bisa dipakai semua user premium untuk kirim pesan',
            style: TextStyle(color: Color(0xFF00D26A), fontSize: 11, fontWeight: FontWeight.w500),
          )),
        ]),
      ),

      Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 4), child: Row(children: [
        _badge('${_publicSenders.length} Public Sender', _C.green),
        const Spacer(),
        GestureDetector(
          onTap: () { setState(() => _loadingPublic = true); _fetchPublic(); },
          child: const Icon(Icons.refresh_rounded, color: _C.accentL, size: 18)),
      ])),

      Expanded(child: _loadingPublic
          ? const Center(child: CircularProgressIndicator(color: _C.accentL))
          : _errPublic != null
              ? _errorWidget(_errPublic!, _fetchPublic)
              : _publicSenders.isEmpty
                  ? _emptyWidget('Belum ada public sender\nToggle dari tab Private', Icons.public_off_rounded)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 100),
                      itemCount: _publicSenders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final s = _publicSenders[i];
                        return _senderCard(s, isPublic: true);
                      })),
    ]);
  }

  // ─── Sender Card dengan Tampilan Premium ───────────────────
  Widget _senderCard(Map<String, dynamic> s, {required bool isPublic}) {
    final name    = s['sessionName'] ?? s['number'] ?? 'Unknown';
    final status  = s['status'] ?? 'connected';
    final isConn  = status == 'connected';
    final owner   = s['owner']?.toString();
    final deleting = _deleting == name;
    final isOwnerSender = owner == widget.username;
    final isGlobal = !isPublic && !isOwnerSender && _isPremium; // Sender global/nomor orang lain

    // Warna berbeda untuk sender global
    Color cardColor = _C.s1;
    Color borderColor = isConn ? _C.accentL.withOpacity(0.3) : _C.border;
    Color iconColor = isConn ? _C.green : _C.textM;
    
    if (isGlobal && _isPremium) {
      cardColor = _C.purple.withOpacity(0.1);
      borderColor = _C.cyan.withOpacity(0.5);
      iconColor = _C.cyan;
    } else if (isPublic && _isPremium) {
      borderColor = _C.gold.withOpacity(0.5);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: _isPremium ? [
          BoxShadow(
            color: (isPublic ? _C.gold : _C.accent).withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ] : null,
      ),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(
            color: (isConn ? _C.green : _C.textM).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isGlobal ? Icons.public_rounded : Icons.phone_android_rounded,
            color: iconColor, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(
                child: Text(name, 
                  style: TextStyle(
                    color: _C.textP, 
                    fontWeight: isGlobal ? FontWeight.w600 : FontWeight.bold, 
                    fontSize: 13,
                  ),
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis),
              ),
              if (isGlobal && _isPremium)
                Icon(Icons.public_rounded, color: _C.cyan, size: 12),
              if (isPublic && _isPremium)
                Icon(Icons.star_rounded, color: _C.gold, size: 12),
            ],
          ),
          const SizedBox(height: 3),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (isConn ? _C.green : _C.textM).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(5)),
                child: Text(isConn ? '● CONNECTED' : '○ OFFLINE',
                  style: TextStyle(color: isConn ? _C.green : _C.textM, fontSize: 9, fontWeight: FontWeight.bold))),
              if (isGlobal && _isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _C.cyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(5)),
                  child: const Text('GLOBAL', style: TextStyle(color: Color(0xFF00B4D8), fontSize: 9, fontWeight: FontWeight.bold))),
              if (isPublic && owner != null && owner != widget.username && _isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _C.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(5)),
                  child: Text('by $owner', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 9, fontWeight: FontWeight.w500))),
              if (isPublic && owner == widget.username && _isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _C.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(5)),
                  child: const Text('YOURS', style: TextStyle(color: Color(0xFF00D26A), fontSize: 9, fontWeight: FontWeight.bold))),
            ],
          ),
        ])),
        if (!deleting)
          Row(children: [
            if (!isPublic)
              GestureDetector(
                onTap: () => _togglePublic(name, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _C.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _C.green.withOpacity(0.3))),
                  child: Row(children: [
                    Icon(Icons.public_rounded, color: _C.green, size: 12),
                    const SizedBox(width: 4),
                    Text('Publik', style: TextStyle(color: _C.green, fontSize: 10)),
                  ]))),
            if (_isOwner && !isPublic) const SizedBox(width: 6),
            if (_isOwner && isPublic)
              GestureDetector(
                onTap: () => _togglePublic(name, false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _C.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _C.accent.withOpacity(0.3))),
                  child: Row(children: [
                    Icon(Icons.lock_rounded, color: _C.accentL, size: 12),
                    const SizedBox(width: 4),
                    Text('Private', style: TextStyle(color: _C.accentL, fontSize: 10)),
                  ]))),
            if (_isOwner && isPublic) const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _confirmDelete(name, isPublic),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _C.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _C.red.withOpacity(0.3))),
                child: const Icon(Icons.delete_outline_rounded, color: _C.red, size: 16))),
          ])
        else
          const SizedBox(width: 24, height: 24,
            child: CircularProgressIndicator(color: _C.accentL, strokeWidth: 2)),
      ]),
    );
  }

  void _confirmDelete(String name, bool isPublic) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: _C.s1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: _C.border)),
      title: const Text('Hapus Sender?', style: TextStyle(color: _C.textP)),
      content: Text('$name akan dihapus.', style: const TextStyle(color: _C.textS)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: _C.textS))),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (isPublic) _deletePublic(name);
            else _deletePrivate(name);
          },
          child: const Text('Hapus', style: TextStyle(color: _C.red, fontWeight: FontWeight.bold))),
      ],
    ));
  }

  void _showAddDialog() {
    _pairingCode = null;
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: _C.s1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: _C.border)),
      title: Row(
        children: [
          Icon(_isPremium ? Icons.workspace_premium_rounded : Icons.add_rounded, 
               color: _isPremium ? _C.gold : _C.accentL, size: 22),
          const SizedBox(width: 8),
          Text(_isPremium ? 'Tambah Sender Premium' : 'Tambah Sender', 
               style: const TextStyle(color: _C.textP, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Masukkan nomor WA (dengan kode negara, tanpa +)', style: TextStyle(color: _C.textS, fontSize: 12)),
        const SizedBox(height: 12),
        TextField(
          controller: _numCtrl,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: _C.textP),
          decoration: InputDecoration(
            hintText: 'Contoh: 628123456789',
            hintStyle: const TextStyle(color: _C.textM),
            filled: true,
            fillColor: _C.s2,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _C.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _C.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _C.accentL)),
          ),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: _C.textS))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isPremium ? _C.gold : _C.accent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          onPressed: () {
            Navigator.pop(context);
            _addPrivate();
          },
          child: Text(_isPremium ? 'Generate Pairing Premium' : 'Generate Pairing', 
                     style: TextStyle(color: _isPremium ? Colors.black : _C.white, fontWeight: FontWeight.bold))),
      ],
    ));
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.4))),
    child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
  );

  Widget _emptyWidget(String msg, IconData icon) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, color: _C.textM, size: 52),
    const SizedBox(height: 14),
    Text(msg, style: const TextStyle(color: _C.textS, fontSize: 13), textAlign: TextAlign.center),
  ]));

  Widget _errorWidget(String err, VoidCallback retry) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.error_outline_rounded, color: _C.red, size: 40),
    const SizedBox(height: 10),
    Text(err, style: const TextStyle(color: _C.textS, fontSize: 12), textAlign: TextAlign.center),
    const SizedBox(height: 14),
    GestureDetector(onTap: retry, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: _C.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: _C.accentL.withOpacity(0.4))),
      child: const Text('Coba Lagi', style: TextStyle(color: _C.accentL, fontWeight: FontWeight.bold)))),
  ]));
}