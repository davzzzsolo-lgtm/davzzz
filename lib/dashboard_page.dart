// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:math' as dart_math;
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:video_player/video_player.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

// Import halaman-halaman
import 'anime_home.dart';
import 'dracin_page.dart';
import 'change_password.dart';
import 'bug_sender.dart';
import 'nik_check.dart';
import 'admin_page.dart';
import 'home_page.dart';
import 'seller_page.dart';
import 'tools_gateway.dart';
import 'login_page.dart';
import 'control_panel.dart';
import 'musik_page.dart';
import 'chat_page.dart';
import 'device_dashboard.dart';

// ─── API ENDPOINTS ───────────────────────────────────────────
class ApiEndpoints {
  static const String statsApi = 'http://draoffice.danzxnhosting.my.id:11860/api/stats';
  static const String onlineUsersApi = 'http://draoffice.danzxnhosting.my.id:11860/api/online';
  static const String webSocketUrl = 'http://draoffice.danzxnhosting.my.id:11860';
  static const String backupStatsApi = 'https://api.countapi.xyz/get/hoxtencloud/online_users';
}

// ─── PALET WARNA ───────────────────────────────────────────
class AppColors {
  static const bg          = Color(0xFF0A0A0F);
  static const surface     = Color(0xFF1A0F1A);
  static const surface2    = Color(0xFF2D1A2E);
  static const border      = Color(0xFF4A1A3A);
  static const borderLight = Color(0xFF5E2A4A);
  static const accent      = Color(0xFFFF0033);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSec     = Color(0xFFE0B0C4);
  static const textMuted   = Color(0xFF8A6A7A);
  static const white       = Color(0xFFFFFFFF);
  static const dimWhite    = Color(0xFFFFE8F0);
  static const highlight   = Color(0xFFFF3366);
  static const fabBg       = Color(0xFF1E0A1A);
  static const neon        = Color(0xFFFF0033);
  static const green       = Color(0xFF4CAF50);
  static const red         = Color(0xFFE53935);
  static const orange      = Color(0xFFFF6D00);
  static const purple      = Color(0xFF9C27B0);
  static const cyan        = Color(0xFF00BCD4);
  static const pink        = Color(0xFFFF4081);
  static const blue        = Color(0xFF2196F3);
  static const yellow      = Color(0xFFFFEB3B);
  static const teal        = Color(0xFF009688);
  static const indigo      = Color(0xFF3F51B5);
  static const gold        = Color(0xFFF59E0B); // Ditambahkan
  
  static const neonRed     = Color(0xFFFF0033);
  static const neonDarkRed = Color(0xFFCC0033);
  static const neonPink    = Color(0xFFFF0066);
  static const bloodRed    = Color(0xFF8B0000);
  static const crimson     = Color(0xFFDC143C);
  static const ruby        = Color(0xFFE0115F);
  
  static const iosBlue     = Color(0xFF007AFF);
  static const iosGreen    = Color(0xFF34C759);
  static const iosRed      = Color(0xFFFF3B30);
  static const iosOrange   = Color(0xFFFF9500);
  static const iosPurple   = Color(0xFFAF52DE);
  static const iosGray     = Color(0xFF8E8E93);
  static const iosBackground = Color(0xFF0A0A0F);
}

// ─── HEXAGON TECH BACKGROUND ───────────────────────────────────
class HexagonTechBackground extends StatelessWidget {
  final Widget child;
  const HexagonTechBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF050505),
                Color(0xFF0A0A0A),
                Color(0xFF0F0F0F),
                Color(0xFF050505),
              ],
            ),
          ),
        ),
        CustomPaint(
          painter: _BlackHexagonPainter(),
          size: Size.infinite,
        ),
        CustomPaint(
          painter: _SmallBlackHexagonPainter(),
          size: Size.infinite,
        ),
        child,
      ],
    );
  }
}

// ─── HEXAGON PAINTER BESAR ───────────────────────────────────
class _BlackHexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    
    final double hexWidth = 70;
    final double hexHeight = 60.62;
    final double hexRadius = hexWidth / 2;
    
    int cols = (size.width / (hexWidth * 0.75)).ceil() + 2;
    int rows = (size.height / hexHeight).ceil() + 2;
    
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        double x = col * hexWidth * 0.75;
        double y = row * hexHeight;
        
        if (row % 2 == 1) {
          x += hexWidth * 0.375;
        }
        
        _drawHexagon(canvas, Offset(x, y), hexRadius, paint);
      }
    }
  }
  
  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (i * 60 - 30) * dart_math.pi / 180;
      double x = center.dx + radius * dart_math.cos(angle);
      double y = center.dy + radius * dart_math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── HEXAGON PAINTER KECIL ───────────────────────────────────
class _SmallBlackHexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    
    final double hexWidth = 35;
    final double hexHeight = 30.31;
    final double hexRadius = hexWidth / 2;
    
    int cols = (size.width / (hexWidth * 0.75)).ceil() + 2;
    int rows = (size.height / hexHeight).ceil() + 2;
    
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        double x = col * hexWidth * 0.75;
        double y = row * hexHeight;
        
        if (row % 2 == 1) {
          x += hexWidth * 0.375;
        }
        
        _drawHexagonSmall(canvas, Offset(x, y), hexRadius, paint);
      }
    }
  }
  
  void _drawHexagonSmall(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (i * 60) * dart_math.pi / 180;
      double x = center.dx + radius * dart_math.cos(angle);
      double y = center.dy + radius * dart_math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// QUICK ACTION CAROUSEL
// ============================================================
class QuickActionCarousel extends StatefulWidget {
  final List<Widget> items;
  const QuickActionCarousel({super.key, required this.items});

  @override
  State<QuickActionCarousel> createState() => _QuickActionCarouselState();
}

class _QuickActionCarouselState extends State<QuickActionCarousel> {
  late PageController _pageController;
  late Timer _autoScrollTimer;
  int _currentPage = 0;
  double _currentPageValue = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page ?? 0;
      });
    });
    if (widget.items.isNotEmpty) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients && mounted && widget.items.isNotEmpty) {
          _currentPage = (_currentPage + 1) % widget.items.length;
          _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      });
    }
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          double scale = 1.0;
          if (_pageController.hasClients) {
            double pagePos = _currentPageValue - index;
            scale = 1.0 - (pagePos.abs() * 0.1);
            scale = scale.clamp(0.85, 1.0);
          }
          return Transform.scale(
            scale: scale,
            child: widget.items[index],
          );
        },
      ),
    );
  }
}

// ─── MAIN DASHBOARD PAGE ───────────────────────────────────────────────────
class DashboardPage extends StatefulWidget {
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final List<Map<String, dynamic>> listDoos;
  final List<dynamic> news;

  const DashboardPage({super.key, required this.username, required this.password, required this.role, required this.expiredDate, required this.listBug, required this.listDoos, required this.sessionKey, required this.news});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _fabCtrl;
  late Animation<double> _fabAnim;
  WebSocketChannel? channel;
  Timer? _statsTimer;
  Timer? _randomTimer;

  VideoPlayerController? _bannerVideoController;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _musicPlaying = false;
  int _currentTrack = 0;
  Duration _musicPos = Duration.zero;
  Duration _musicDur = Duration.zero;

  final List<Map<String, String>> _playlist = [
    {'title': 'Lo-Fi Chill', 'artist': 'HoxtenCloud BGM', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'},
    {'title': 'Dark Ambience', 'artist': 'HoxtenCloud BGM', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'},
    {'title': 'Night Drive', 'artist': 'HoxtenCloud BGM', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'},
  ];

  late String sessionKey, username, password, role, expiredDate;
  late List<Map<String, dynamic>> listBug, listDoos;
  late List<dynamic> newsList;
  String androidId = "unknown";
  int _bottomNavIndex = 0;
  bool _fabOpen = false;
  Widget _selectedPage = const SizedBox();
  
  int _onlineUsers = 0;
  int _activeConnections = 0;
  bool _isLoadingStats = true;
  String _apiSource = "Loading...";
  
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _catboxUrlController = TextEditingController();
  List<Map<String, dynamic>> _customNewsItems = [];

  String _selectedPremiumMenu = '';
  
  // Random generator untuk efek acak (hanya untuk online users & connections)
  final dart_math.Random _random = dart_math.Random();
  int _maxOnlineUsers = 800;
  int _maxConnections = 150;
  
  // Variabel untuk Expiration (data real dari user)
  late String _realExpiredDate;
  late int _remainingDays;
  late double _expiryPercentage;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    sessionKey = widget.sessionKey;
    username = widget.username;
    password = widget.password;
    role = widget.role;
    expiredDate = widget.expiredDate;
    listBug = widget.listBug;
    listDoos = widget.listDoos;
    newsList = widget.news;
    
    // Inisialisasi data expiration real
    _realExpiredDate = expiredDate;
    _calculateExpirationData();
    
    _loadProfileImage();
    _loadCustomNews();

    _fadeCtrl = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _fabCtrl = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fabAnim = CurvedAnimation(parent: _fabCtrl, curve: Curves.easeInOut);

    _initBannerVideo();
    _selectedPage = _buildDashboardHome();
    _initAndroidIdAndConnect();
    _initMusicListeners();
    _fetchAllStats();
    _statsTimer = Timer.periodic(const Duration(seconds: 10), (timer) { _fetchAllStats(); });
    
    // Timer untuk update random data online users & connections setiap 3 detik
    _randomTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateRandomStats();
    });
  }
  
  void _calculateExpirationData() {
    try {
      final expiryDateTime = DateTime.parse(_realExpiredDate);
      final now = DateTime.now();
      _remainingDays = expiryDateTime.difference(now).inDays;
      if (_remainingDays < 0) _remainingDays = 0;
      
      // Asumsi max days = 36500 (100 tahun) untuk persentase
      const totalDays = 36500;
      _expiryPercentage = (_remainingDays / totalDays) * 100;
      if (_expiryPercentage < 0) _expiryPercentage = 0;
      if (_expiryPercentage > 100) _expiryPercentage = 100;
    } catch (e) {
      _remainingDays = 365;
      _expiryPercentage = 100;
    }
  }
  
  void _updateRandomStats() {
    if (!mounted) return;
    setState(() {
      // Random Online Users antara 0 - 800
      _onlineUsers = _random.nextInt(_maxOnlineUsers + 1);
      
      // Random Active Connections antara 0 - 150
      _activeConnections = _random.nextInt(_maxConnections + 1);
      
      // Expiration tetap menggunakan data real, tidak berubah
    });
  }
  
  String _formatExpiredDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
    } catch (e) {
      return date;
    }
  }
  
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _profileImagePath = prefs.getString('profile_image_$username'); });
  }
  
  Future<void> _saveProfileImage(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString('profile_image_$username', path);
    } else {
      await prefs.remove('profile_image_$username');
    }
    setState(() { _profileImagePath = path; });
  }
  
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _saveProfileImage(image.path);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil berhasil diubah!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat gambar: $e'), backgroundColor: Colors.red));
    }
  }
  
  Future<void> _loadCustomNews() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedNews = prefs.getString('custom_news_$username');
    if (savedNews != null) {
      setState(() { _customNewsItems = List<Map<String, dynamic>>.from(jsonDecode(savedNews)); });
    }
  }
  
  Future<void> _saveCustomNews() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_news_$username', jsonEncode(_customNewsItems));
  }
  
  void _addCatboxNews() {
    if (_catboxUrlController.text.isNotEmpty) {
      setState(() {
        _customNewsItems.add({
          'title': 'Catbox Media',
          'date': DateTime.now().toString().substring(0, 10),
          'isNew': true,
          'url': _catboxUrlController.text,
          'type': 'catbox',
          'description': 'Media from Catbox'
        });
        _saveCustomNews();
      });
      _catboxUrlController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Media Catbox berhasil ditambahkan!'), backgroundColor: Colors.green));
    }
  }
  
  void _showAddCatboxDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tambah Media Catbox', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _catboxUrlController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Masukkan URL Catbox...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.neonRed)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.white70))),
          ElevatedButton(onPressed: () { _addCatboxNews(); Navigator.pop(context); }, child: const Text('Tambah')),
        ],
      ),
    );
  }

  Future<void> _initBannerVideo() async {
    try {
      _bannerVideoController = VideoPlayerController.asset('assets/videos/banner.mp4');
      await _bannerVideoController!.initialize();
      _bannerVideoController!.setLooping(true);
      _bannerVideoController!.setVolume(0.0);
      await _bannerVideoController!.play();
      if (mounted) setState(() {});
    } catch (e) { debugPrint("Gagal memuat banner video: $e"); }
  }

  void _toggleBannerVideo() {
    setState(() {
      if (_bannerVideoController != null) {
        if (_bannerVideoController!.value.isPlaying) { 
          _bannerVideoController!.pause(); 
        } else { 
          _bannerVideoController!.play(); 
        }
      }
    });
  }

  Future<void> _fetchAllStats() async { await Future.wait([_fetchFromMainApi(), _fetchFromOnlineApi(), _fetchFromBackupApi()]); }

  Future<void> _fetchFromMainApi() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.statsApi), headers: {'Authorization': 'Bearer $sessionKey'}).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        final online = data['online_users'] ?? data['online'] ?? data['total_online'] ?? 0;
        final connections = data['active_connections'] ?? data['connections'] ?? 0;
        setState(() { _onlineUsers = online; _activeConnections = connections; _isLoadingStats = false; _apiSource = "Main API"; });
      }
    } catch (e) { debugPrint('Error: $e'); }
  }

  Future<void> _fetchFromOnlineApi() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.onlineUsersApi), headers: {'Authorization': 'Bearer $sessionKey'}).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        final online = data['online'] ?? data['total'] ?? data['count'] ?? 0;
        if (online > _onlineUsers) setState(() { _onlineUsers = online; _apiSource = "Online API"; });
      }
    } catch (e) { debugPrint('Error: $e'); }
  }

  Future<void> _fetchFromBackupApi() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.backupStatsApi)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        final online = data['value'] ?? 0;
        if (_onlineUsers == 0 && online > 0) setState(() { _onlineUsers = online; _apiSource = "Backup API"; });
      }
    } catch (e) { debugPrint('Error: $e'); }
  }

  void _initMusicListeners() {
    _audioPlayer.onPlayerStateChanged.listen((s) { if (mounted) setState(() => _musicPlaying = s == PlayerState.playing); });
    _audioPlayer.onPositionChanged.listen((d) { if (mounted) setState(() => _musicPos = d); });
    _audioPlayer.onDurationChanged.listen((d) { if (mounted) setState(() => _musicDur = d); });
    _audioPlayer.onPlayerComplete.listen((_) => _nextTrack());
  }

  Future<void> _playTrack(int index) async { _currentTrack = index; await _audioPlayer.stop(); await _audioPlayer.setVolume(0.7); await _audioPlayer.play(UrlSource(_playlist[index]['url']!)); if (mounted) setState(() {}); }
  void _toggleMusic() { if (_musicPlaying) { _audioPlayer.pause(); } else { if (_musicPos == Duration.zero) { _playTrack(_currentTrack); } else { _audioPlayer.resume(); } } }
  void _nextTrack() { _playTrack((_currentTrack + 1) % _playlist.length); }
  void _prevTrack() { _playTrack((_currentTrack - 1 + _playlist.length) % _playlist.length); }

  Future<void> _initAndroidIdAndConnect() async { 
    final deviceInfo = await DeviceInfoPlugin().androidInfo; 
    androidId = deviceInfo.id; 
    _connectToWebSocket(); 
  }

  void _connectToWebSocket() {
    try {
      channel = WebSocketChannel.connect(Uri.parse(ApiEndpoints.webSocketUrl));
      channel!.sink.add(jsonEncode({"type": "validate", "key": sessionKey, "androidId": androidId}));
      channel!.sink.add(jsonEncode({"type": "stats"}));
      channel!.stream.listen((event) {
        final data = jsonDecode(event);
        if (data['type'] == 'myInfo' && data['valid'] == false) _handleInvalidSession("Session invalid, please re-login.");
        if (data['type'] == 'stats' && mounted) {
          final online = data['online'] ?? data['online_users'] ?? 0;
          final connections = data['connections'] ?? data['active_connections'] ?? 0;
          setState(() { _onlineUsers = online; _activeConnections = connections; _apiSource = "WebSocket (Real-time)"; });
        }
      }, onError: (error) { debugPrint('WebSocket error: $error'); });
    } catch (e) { debugPrint('WebSocket connection error: $e'); }
  }

  void _handleInvalidSession(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    showDialog(context: context, barrierDismissible: false, builder: (_) => BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
      title: const Row(children: [Icon(Icons.warning_rounded, color: Colors.white, size: 26), SizedBox(width: 12), Text("Session Expired", style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Orbitron'))]),
      content: Text(message, style: const TextStyle(color: AppColors.textSec, fontSize: 14, fontFamily: 'ShareTechMono')),
      actions: [TextButton(onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false), child: const Text("OK", style: TextStyle(color: AppColors.white, fontFamily: 'Orbitron', fontSize: 14)))],
    )));
  }

  void _toggleFab() { setState(() => _fabOpen = !_fabOpen); if (_fabOpen) _fabCtrl.forward(); else _fabCtrl.reverse(); }

  void _onNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
      switch (index) {
        case 0: 
          _selectedPage = _buildDashboardHome(); 
          break;
        case 1: 
          _selectedPage = HomePage(
            username: username,
            password: password,
            sessionKey: sessionKey,
            listBug: listBug,
            role: role,
            expiredDate: expiredDate,
          ); 
          break;
        case 2: 
          _selectedPage = HomePage(
            username: username,
            password: password,
            sessionKey: sessionKey,
            listBug: listBug,
            role: role,
            expiredDate: expiredDate,
          ); 
          break;
        case 3: 
          _selectedPage = ToolsPage(
            sessionKey: sessionKey,
            userRole: role,
            listDoos: listDoos,
          ); 
          break;
        case 4: 
          _selectedPage = DeviceDashboard(
            username: username,
            role: role,
            sessionKey: sessionKey,
          );
          break;
      }
    });
  }

  void _navigateToAdminPage() => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPage(sessionKey: sessionKey)));
  void _navigateToSellerPage() => Navigator.push(context, MaterialPageRoute(builder: (_) => SellerPage(keyToken: sessionKey)));
  void _navigateToChatPage() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatPage(
        currentUsername: username,
        sessionKey: sessionKey,
      )
    )
  );

  Widget _buildPremiumControlCard() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        // REMOTE ACCESS TROJAN - Sekarang di KIRI (warna ungu)
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() { _selectedPremiumMenu = 'rat'; });
              Navigator.push(context, MaterialPageRoute(builder: (_) => DeviceDashboard(username: username, role: role, sessionKey: sessionKey)));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF6a1b9a), Color(0xFF4a148c), Color(0xFF311b92)]),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _selectedPremiumMenu == 'rat' ? const Color(0xFF9C27B0).withOpacity(0.8) : Colors.transparent, width: 2),
                boxShadow: [BoxShadow(color: const Color(0xFF9C27B0).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Stack(
                children: [
                  Positioned(bottom: -30, right: -30, child: Text("🖥️", style: TextStyle(fontSize: 95, color: Colors.white.withOpacity(0.06)))),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.15))), child: const Text("CONTROL", style: TextStyle(color: Color(0xFFE1BEE7), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontFamily: 'Orbitron'))),
                          Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(18)), child: Center(child: Icon(Icons.devices_rounded, color: Colors.white.withOpacity(0.8), size: 20))),
                        ]),
                        const SizedBox(height: 28),
                        const Text("Remote Access\nTrojan", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2, fontFamily: 'Orbitron')),
                        const SizedBox(height: 12),
                        Text("Full control over target device.", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500, fontFamily: 'ShareTechMono')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // WHATSAPP CRASH - Sekarang di KANAN (warna hijau seperti WhatsApp)
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() { _selectedPremiumMenu = 'bug'; });
              Navigator.push(context, MaterialPageRoute(builder: (_) => BugSenderPage(sessionKey: sessionKey, username: username, role: role)));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF075E54), Color(0xFF128C7E), Color(0xFF25D366)]),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _selectedPremiumMenu == 'bug' ? const Color(0xFF25D366).withOpacity(0.8) : Colors.transparent, width: 2),
                boxShadow: [BoxShadow(color: const Color(0xFF25D366).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Stack(
                children: [
                  Positioned(bottom: -30, right: -30, child: Text("💬", style: TextStyle(fontSize: 100, color: Colors.white.withOpacity(0.06)))),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.15))), child: const Text("PREMIUM", style: TextStyle(color: Color(0xFFDCF8C6), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontFamily: 'Orbitron'))),
                          Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(18)), child: const Center(child: Text("⚡", style: TextStyle(fontSize: 18)))),
                        ]),
                        const SizedBox(height: 28),
                        const Text("WhatsApp\nCrash", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2, fontFamily: 'Orbitron')),
                        const SizedBox(height: 12),
                        Text("Send payloads to crash target device.", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500, fontFamily: 'ShareTechMono')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildMantaBanner() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.25), width: 2),
                bottom: BorderSide(color: Colors.grey.withOpacity(0.25), width: 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF808080), Color(0xFFA9A9A9), Color(0xFFC0C0C0)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(bounds),
                  child: const Text("TR4SVORTEX", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 4, shadows: [Shadow(color: Color(0xFF808080), blurRadius: 15), Shadow(color: Color(0xFF696969), blurRadius: 8)])),
                ),
                const SizedBox(width: 22),
                Row(
                  children: [
                    AnimatedContainer(duration: const Duration(milliseconds: 500), width: 12, height: 12, decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.8), blurRadius: 8, spreadRadius: 2)])),
                    const SizedBox(width: 12),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF808080), Color(0xFFA9A9A9), Color(0xFF696969)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(bounds),
                      child: const Text("SYSTEM ONLINE", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5, shadows: [Shadow(color: Color(0xFF808080), blurRadius: 10)])),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 0),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("•", style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 14),
                Text("the new version", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                const SizedBox(width: 14),
                Text("•", style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStatsCard() {
    String displayUid = androidId != "unknown" ? androidId : "f4424219-4faf-4417-9dc5-57a862d202ba";
    String shortUid = displayUid.length > 12 ? "${displayUid.substring(0, 12)}..." : displayUid;
    bool isVideoPlaying = _bannerVideoController != null && _bannerVideoController!.value.isPlaying;
    
    // Format tanggal expired untuk ditampilkan
    String formattedExpiredDate = _formatExpiredDate(_realExpiredDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            if (_bannerVideoController != null && _bannerVideoController!.value.isInitialized)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(width: _bannerVideoController!.value.size.width, height: _bannerVideoController!.value.size.height, child: VideoPlayer(_bannerVideoController!)),
                ),
              ),
            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.black.withOpacity(0.4), Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.4)]))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImageFromGallery,
                        child: Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.neonRed, AppColors.neonDarkRed]), shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.neonRed.withOpacity(0.5), blurRadius: 15)]),
                          child: ClipOval(child: _profileImagePath != null && File(_profileImagePath!).existsSync() ? Image.file(File(_profileImagePath!), fit: BoxFit.cover, width: 60, height: 60) : const Center(child: Icon(Icons.person, color: Colors.white, size: 30))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Welcome back,", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(username, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Orbitron"), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(border: Border.all(color: AppColors.neonRed.withOpacity(0.5)), borderRadius: BorderRadius.circular(20), color: Colors.black.withOpacity(0.5)), child: Text(role.toUpperCase(), style: const TextStyle(color: AppColors.neonRed, fontSize: 10, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.2)), borderRadius: BorderRadius.circular(16), color: Colors.black.withOpacity(0.3)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hexagon, color: Colors.grey.withOpacity(0.7), size: 14),
                        const SizedBox(width: 8),
                        const Text("TR4SVORTEX 6.0", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: "Orbitron", letterSpacing: 2)),
                        const SizedBox(width: 8),
                        Icon(Icons.hexagon, color: Colors.grey.withOpacity(0.7), size: 14),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tiga Stat Item - Online Users & Connections (Random), Expiration (Real)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAnimatedStatItem(_onlineUsers.toString(), "Online Users", AppColors.neonRed),
                      _buildAnimatedStatItem(_activeConnections.toString(), "Connections", AppColors.neonPink),
                      _buildAnimatedStatItem(_remainingDays.toString(), "Days Left", AppColors.gold),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Progress Bar untuk Expiration (Real)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Expiration: $formattedExpiredDate", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                          Text("${_expiryPercentage.toStringAsFixed(1)}%", style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _expiryPercentage / 100,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text("UID: $shortUid", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: displayUid));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UID Copied!'), backgroundColor: AppColors.neonRed, duration: Duration(seconds: 1)));
                            },
                            child: Icon(Icons.copy, color: Colors.white.withOpacity(0.6), size: 14),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _toggleBannerVideo,
                        child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.3))), child: Icon(isVideoPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 14)),
                      ),
                      Row(
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.white.withOpacity(0.7), size: 14),
                          const SizedBox(width: 4),
                          Text("28°C", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                          const SizedBox(width: 12),
                          Icon(Icons.battery_charging_full, color: Colors.white.withOpacity(0.7), size: 14),
                          const SizedBox(width: 4),
                          Text("100%", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStatItem(String value, String label, Color color) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: double.tryParse(value)?.toDouble() ?? 0),
      builder: (context, double val, child) {
        return Column(
          children: [
            Container(
              width: 55, 
              height: 55, 
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                border: Border.all(color: color.withOpacity(0.5), width: 2), 
                boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12)]
              ), 
              child: Center(
                child: Text(
                  val.toInt().toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "ShareTechMono")
                )
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
          ],
        );
      },
    );
  }

  Widget _buildPremiumQuickCard({
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
    required Color accentColor,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: MediaQuery.of(context).size.width * 0.9,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withOpacity(0.5), width: 2),
          boxShadow: [BoxShadow(color: accentColor.withOpacity(0.4), blurRadius: 20, spreadRadius: 3, offset: const Offset(0, 10)), BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Stack(
          children: [
            Positioned(top: -50, right: -50, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.white.withOpacity(0.3), Colors.transparent])))),
            Row(
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5), boxShadow: [BoxShadow(color: accentColor.withOpacity(0.5), blurRadius: 10)]), child: Icon(icon, color: Colors.white, size: 30)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Orbitron', letterSpacing: 1.5, shadows: [Shadow(color: Colors.black54, blurRadius: 3)]), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'ShareTechMono'), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text(description, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontFamily: 'ShareTechMono'), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.5), width: 1)), child: Icon(Icons.arrow_forward_rounded, color: accentColor, size: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleChip(String r) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.4))), child: Text(r.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'Orbitron')));
  }

  Widget _buildModernNewsCarousel() {
    final List<Map<String, dynamic>> dummyNews = [
      {"title": "TR4SVORTEX V6.0", "date": "2026-04-21", "image": "assets/images/news1.jpg", "isNew": true, "description": "Latest update with enhanced security features and performance improvements."},
      {"title": "NEW FITUR RAT", "date": "2026-05-08", "image": "assets/images/news2.jpg", "isNew": true, "description": "Remote Access Tool now supports more devices and platforms."},
      {"title": "FUNCTION UPDATED", "date": "2026-05-05", "image": "assets/images/news3.jpg", "isNew": true, "description": "Multiple functions optimized for better user experience."},
      {"title": "GLOBAL SENDER", "date": "2026-05-02", "image": "assets/images/news4.jpg", "isNew": true, "description": "Send messages globally with improved delivery system."},
      {"title": "NEW UPDATES", "date": "2026-04-28", "image": "assets/images/news5.jpg", "isNew": true, "description": "General improvements and bug fixes."},
    ];

    final List<Map<String, dynamic>> allNews = [];
    allNews.addAll(dummyNews);
    if (_customNewsItems.isNotEmpty) { allNews.addAll(_customNewsItems); }

    if (allNews.isEmpty) {
      return const Center(child: Text('No news available', style: TextStyle(color: Colors.white54, fontFamily: 'ShareTechMono')));
    }

    return SizedBox(
      height: 320,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        scrollDirection: Axis.horizontal,
        itemCount: allNews.length,
        itemBuilder: (context, index) {
          final item = allNews[index];
          final String title = item["title"]?.toString() ?? "No Title";
          final String date = item["date"]?.toString() ?? "";
          final String? imagePath = item["image"]?.toString();
          final bool isNew = item["isNew"] == true;
          final bool isCatbox = item["type"] == "catbox";
          final String? url = item["url"];
          final String description = item["description"]?.toString() ?? "Click to view more details about this update.";

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: url != null ? () async { final uri = Uri.parse(url); if (await canLaunchUrl(uri)) { await launchUrl(uri, mode: LaunchMode.externalApplication); } } : null,
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10)), BoxShadow(color: AppColors.neonRed.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(child: _buildNewsImage(imagePath, isCatbox)),
                      Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.4), Colors.black.withOpacity(0.85)], stops: const [0.0, 0.4, 0.7, 1.0])))),
                      if (isNew) Positioned(top: 16, right: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.neonRed, AppColors.neonPink]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.neonRed.withOpacity(0.5), blurRadius: 8)]), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.fiber_new, color: Colors.white, size: 14), SizedBox(width: 4), Text("NEW", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Orbitron'))]))),
                      if (isCatbox) Positioned(top: 16, left: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.purple.withOpacity(0.85), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.3))), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.cloud_upload, color: Colors.white, size: 12), SizedBox(width: 4), Text("CATBOX", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Orbitron'))]))),
                      Positioned(
                        bottom: 20, left: 20, right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Orbitron", letterSpacing: 1, shadows: [Shadow(color: Colors.black54, blurRadius: 5)]), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Text(description, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, fontFamily: 'ShareTechMono', shadows: [const Shadow(color: Colors.black54, blurRadius: 4)]), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.access_time, color: Colors.white70, size: 12), const SizedBox(width: 4), Text(date, style: const TextStyle(color: Colors.white70, fontSize: 10))])),
                                const Spacer(),
                                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.neonRed, AppColors.neonPink]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.neonRed.withOpacity(0.4), blurRadius: 8)]), child: const Row(children: [Text("READ", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Orbitron')), SizedBox(width: 4), Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12)])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsImage(String? imagePath, bool isCatbox) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: isCatbox ? [const Color(0xFF1A0F1A), const Color(0xFF0A0A0F)] : [const Color(0xFF1A0F1A), const Color(0xFF0A0A0F)])), child: Center(child: Icon(isCatbox ? Icons.cloud_queue : Icons.newspaper, color: Colors.white.withOpacity(0.3), size: 50)));
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(imagePath, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: isCatbox ? [const Color(0xFF1A0F1A), const Color(0xFF0A0A0F)] : [const Color(0xFF1A0F1A), const Color(0xFF0A0A0F)])), child: const Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 40))));
    } else {
      return Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: isCatbox ? [const Color(0xFF1A0F1A), const Color(0xFF0A0A0F)] : [const Color(0xFF1A0F1A), const Color(0xFF0A0A0F)])), child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white54, size: 40))));
    }
  }

  Widget _buildDashboardHome() {
    final List<Widget> quickActionItems = [
      _buildPremiumQuickCard(label: 'MANAGE SENDERS', icon: Icons.phone_android_rounded, gradientColors: const [Color(0xFFD4AF37), Color(0xFF996515), Color(0xFF665000)], accentColor: const Color(0xFFFFD700), subtitle: 'WhatsApp Manager', description: 'Kirim pesan massal ke device', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BugSenderPage(sessionKey: sessionKey, username: username, role: role)))),
      _buildPremiumQuickCard(label: 'RAT CONTROL', icon: Icons.devices_rounded, gradientColors: const [Color(0xFF9B111E), Color(0xFFDC143C), Color(0xFF8B0000)], accentColor: const Color(0xFFFF3366), subtitle: 'Remote Access', description: 'Kontrol device remote', onTap: () => _onNavTapped(4)),
      _buildPremiumQuickCard(label: 'NIK CHECK', icon: Icons.badge_rounded, gradientColors: const [Color(0xFF0F52BA), Color(0xFF0039A6), Color(0xFF002266)], accentColor: const Color(0xFF4D9EFF), subtitle: 'Data Verification', description: 'Cek data NIK secara realtime', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NikCheckerPage()))),
      _buildPremiumQuickCard(label: 'CHAT ROOM', icon: Icons.chat_bubble_rounded, gradientColors: const [Color(0xFF9966CC), Color(0xFF6A0DAD), Color(0xFF4B0082)], accentColor: const Color(0xFFB77CFF), subtitle: 'Real-time Chat', description: 'Obrolan realtime antar user', onTap: () => _navigateToChatPage()),
      _buildPremiumQuickCard(label: 'WA BLAST', icon: Icons.send_rounded, gradientColors: const [Color(0xFF50C878), Color(0xFF228B22), Color(0xFF006400)], accentColor: const Color(0xFF7CFC00), subtitle: 'Broadcast', description: 'Blast pesan WhatsApp', onTap: () => _onNavTapped(1)),
      _buildPremiumQuickCard(label: 'GROUP RAID', icon: Icons.groups_rounded, gradientColors: const [Color(0xFFFF7E00), Color(0xFFFF4500), Color(0xFFCC3300)], accentColor: const Color(0xFFFFB347), subtitle: 'Group Manager', description: 'Raid grup WhatsApp', onTap: () => _onNavTapped(2)),
      _buildPremiumQuickCard(label: 'TOOLS', icon: Icons.build_rounded, gradientColors: const [Color(0xFFE5E4E2), Color(0xFFA9A9A9), Color(0xFF696969)], accentColor: const Color(0xFFC0C0C0), subtitle: 'Utility', description: 'Koleksi tools lengkap', onTap: () => _onNavTapped(3)),
    ];
    
    if (role == 'owner' || role == 'dev' || role == 'admin') {
      quickActionItems.add(_buildPremiumQuickCard(label: 'ADMIN PANEL', icon: Icons.admin_panel_settings_rounded, gradientColors: const [Color(0xFFDC143C), Color(0xFF8B0000), Color(0xFF4A0000)], accentColor: const Color(0xFFFF6B6B), subtitle: 'Full Access', description: 'Panel admin full akses', onTap: _navigateToAdminPage));
    }
    if (role == 'owner' || role == 'dev' || role == 'reseller') {
      quickActionItems.add(_buildPremiumQuickCard(label: 'SELLER PANEL', icon: Icons.store_rounded, gradientColors: const [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFB8860B)], accentColor: const Color(0xFFFFD700), subtitle: 'License', description: 'Jual lisensi & manage user', onTap: _navigateToSellerPage));
    }

    return HexagonTechBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMantaBanner(),
            _buildAccountStatsCard(),
            const SizedBox(height: 16),
            _buildPremiumControlCard(),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(width: 5, height: 22, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFDC143C), Color(0xFF9B111E)]), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 12),
                  const Text('✨ PREMIUM ACTIONS ✨', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 2, fontFamily: 'Orbitron', shadows: [Shadow(color: Color(0xFFFFD700), blurRadius: 8)])),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFF996515)]), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.3), blurRadius: 8)]), child: const Row(children: [Icon(Icons.auto_awesome, color: Colors.white, size: 12), SizedBox(width: 4), Text('AUTO SCROLL', style: TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'ShareTechMono', fontWeight: FontWeight.bold))])),
                ],
              ),
            ),
            const SizedBox(height: 18),
            QuickActionCarousel(items: quickActionItems),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () async { final uri = Uri.parse('https://t.me/Tarsax_Reals02'); if (await canLaunchUrl(uri)) { launchUrl(uri, mode: LaunchMode.externalApplication); } },
                      child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF1A0F1A).withOpacity(0.9), const Color(0xFF0A0A0F).withOpacity(0.9)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))]), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0088CC), Color(0xFF006699)]), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.telegram, color: Colors.white, size: 26)), const SizedBox(width: 14), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('JOIN CHANNEL', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Orbitron')), Text('TR4SVORTEX', style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'ShareTechMono'))]))])),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF1A0F1A).withOpacity(0.9), const Color(0xFF0A0A0F).withOpacity(0.9)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFDC143C).withOpacity(0.3), width: 1.5)), child: Column(children: [const Icon(Icons.trending_up_rounded, color: Color(0xFFFFD700), size: 24), const SizedBox(height: 6), TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0, end: _onlineUsers.toDouble()),
                      builder: (context, val, child) => Text(
                        val.toInt().toString(),
                        style: const TextStyle(color: Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Orbitron', shadows: [Shadow(color: Color(0xFFFFD700), blurRadius: 5)]),
                      ),
                    ), const Text('Online Users', style: TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'ShareTechMono'))])),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(width: 5, height: 22, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFDC143C)]), borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 12),
                  const Text('🏆 LATEST UPDATES 🏆', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 1.5, fontFamily: 'Orbitron', shadows: [Shadow(color: Color(0xFFFFD700), blurRadius: 5)])),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showAddCatboxDialog,
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFF996515)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.3), blurRadius: 8)]), child: const Row(children: [Icon(Icons.cloud_upload, color: Colors.white, size: 12), SizedBox(width: 4), Text('ADD CATBOX', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Orbitron'))])),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildModernNewsCarousel(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _bottomNavIndex == 0,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_bottomNavIndex != 0) {
          _onNavTapped(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        drawer: _buildDrawer(),
        appBar: _buildAppBar(),
        body: Container(color: AppColors.bg, child: FadeTransition(opacity: _fadeAnim, child: _selectedPage)),
        extendBody: true,
        bottomNavigationBar: _buildFloatingBottomNav(),
        floatingActionButton: _buildFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: Builder(builder: (ctx) => IconButton(icon: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [_barLine(26), const SizedBox(height: 5), _barLine(18), const SizedBox(height: 5), _barLine(12)]), onPressed: () => Scaffold.of(ctx).openDrawer())),
      title: Row(children: [const Icon(Icons.bolt_rounded, color: AppColors.neonRed, size: 22), const SizedBox(width: 8), Text("Hai, $username", style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: 0.5, fontFamily: 'Orbitron')), const SizedBox(width: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.iosGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.iosGreen.withOpacity(0.3))), child: Row(children: [Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.iosGreen, shape: BoxShape.circle)), const SizedBox(width: 6), TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        tween: Tween<double>(begin: 0, end: _onlineUsers.toDouble()),
        builder: (context, val, child) => Text(
          val.toInt().toString(),
          style: const TextStyle(color: AppColors.iosGreen, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'ShareTechMono'),
        ),
      )]))]),
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: Colors.white.withOpacity(0.05))),
      actions: [
        IconButton(icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: Icon(_musicPlaying ? Icons.music_note_rounded : Icons.music_off_rounded, color: _musicPlaying ? AppColors.white : AppColors.textMuted, size: 20)), onPressed: () { setState(() { _selectedPage = MusikPage(sharedPlayer: _audioPlayer, initialTrack: _currentTrack); _bottomNavIndex = 0; }); }),
        IconButton(icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.account_circle_rounded, color: AppColors.textSec, size: 22)), onPressed: () => Scaffold.of(context).openDrawer()),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _barLine(double w) => Container(width: w, height: 2.5, decoration: BoxDecoration(color: AppColors.textSec, borderRadius: BorderRadius.circular(4)));

  Widget _buildFloatingBottomNav() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(35), border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: AppColors.neonRed.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 5)), BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 10))]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: AppColors.neonRed,
              unselectedItemColor: Colors.white70,
              selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Orbitron'),
              unselectedLabelStyle: const TextStyle(fontSize: 11, fontFamily: 'ShareTechMono'),
              currentIndex: _bottomNavIndex,
              onTap: _onNavTapped,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'HOME'),
                BottomNavigationBarItem(icon: Icon(Icons.bug_report_outlined), activeIcon: Icon(Icons.bug_report_rounded), label: 'BUG'),
                BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups_rounded), label: 'GROUP'),
                BottomNavigationBarItem(icon: Icon(Icons.build_outlined), activeIcon: Icon(Icons.build_rounded), label: 'TOOLS'),
                BottomNavigationBarItem(icon: Icon(Icons.devices_outlined), activeIcon: Icon(Icons.devices_rounded), label: 'RAT'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(children: [
        Container(width: double.infinity, height: 200, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.neonRed, AppColors.neonDarkRed, AppColors.bloodRed]), border: Border(bottom: BorderSide(color: AppColors.border))), child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.flash_on_rounded, color: Colors.white, size: 45), SizedBox(height: 10), Text("TR4S VORTEX", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Orbitron', letterSpacing: 2))]))),
        Container(padding: const EdgeInsets.all(18), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))), child: Row(children: [
          GestureDetector(onTap: _pickImageFromGallery, child: Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.border)), child: _profileImagePath != null && File(_profileImagePath!).existsSync() ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(File(_profileImagePath!), fit: BoxFit.cover, width: 50, height: 50)) : const Icon(Icons.person_rounded, color: AppColors.textSec, size: 28))),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(username, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Orbitron')), const SizedBox(height: 6), _roleChip(role)]),
        ])),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(vertical: 12), children: [
          if (role.toLowerCase() == "owner") ...[_drawerItem(Icons.admin_panel_settings_rounded, 'Admin Page', _navigateToAdminPage), _drawerItem(Icons.storefront_rounded, 'Seller Page', _navigateToSellerPage)],
          if (role.toLowerCase() == "reseller" || role.toLowerCase() == "vip") _drawerItem(Icons.storefront_rounded, 'Seller Page', _navigateToSellerPage),
          _drawerItem(Icons.lock_clock_rounded, 'Ganti Password', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordPage(username: username, sessionKey: sessionKey))); }),
          _drawerItem(Icons.badge_rounded, 'NIK Check', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => NikCheckerPage())); }),
          _drawerItem(Icons.chat_bubble_rounded, 'Chat Room', () { Navigator.pop(context); _navigateToChatPage(); }),
          _drawerItem(Icons.bug_report_rounded, 'Bug Sender', () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => BugSenderPage(sessionKey: sessionKey, username: username, role: role))); }),
          _drawerItem(Icons.music_note_rounded, 'Music Player', () { Navigator.pop(context); setState(() { _selectedPage = MusikPage(sharedPlayer: _audioPlayer, initialTrack: _currentTrack); _bottomNavIndex = 0; }); }),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 16)),
          const SizedBox(height: 12),
          Container(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: AppColors.iosRed.withOpacity(0.15), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.iosRed.withOpacity(0.3))), child: ListTile(leading: const Icon(Icons.logout_rounded, color: Colors.white, size: 22), title: const Text('LOGOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Orbitron')), onTap: () { Navigator.pop(context); _showLogoutDialog(); })),
          const SizedBox(height: 30),
          Center(child: Column(children: [const Text("CREDITS", style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 2.5, fontWeight: FontWeight.bold, fontFamily: 'Orbitron')), const SizedBox(height: 8), const Text("@T4rsax", style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'ShareTechMono', fontWeight: FontWeight.w600)), const SizedBox(height: 4), const Text("KepowTzy", style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'ShareTechMono'))])),
        ])),
      ]),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ListTile(leading: Icon(icon, color: AppColors.textSec, size: 22), title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Orbitron')), trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14), onTap: onTap));
  }

  Widget _buildFAB() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      AnimatedBuilder(animation: _fabAnim, builder: (_, __) {
        if (_fabAnim.value == 0) return const SizedBox.shrink();
        return FadeTransition(
          opacity: _fabAnim,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - _fabAnim.value)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 25, offset: const Offset(0, 12))]),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _fabItem(Icons.home_rounded, "Home", () { _onNavTapped(0); _toggleFab(); }),
                _fabItem(Icons.animation_rounded, "Drakin", () { _onNavTapped(1); _toggleFab(); }),
                _fabItem(Icons.movie_filter_rounded, "Anime", () { _onNavTapped(3); _toggleFab(); }),
                _fabItem(FontAwesomeIcons.whatsapp, "Bug WA", () { _onNavTapped(1); _toggleFab(); }),
                _fabItem(Icons.build_rounded, "Tools", () { _onNavTapped(3); _toggleFab(); }),
                _fabDivider(),
                _fabItem(Icons.bug_report_rounded, "Bug Sender", () { _toggleFab(); Navigator.push(context, MaterialPageRoute(builder: (_) => BugSenderPage(sessionKey: sessionKey, username: username, role: role))); }),
                _fabItem(Icons.badge_rounded, "NIK Check", () { _toggleFab(); Navigator.push(context, MaterialPageRoute(builder: (_) => NikCheckerPage())); }),
                _fabItem(Icons.chat_bubble_rounded, "Chat Room", () { _toggleFab(); _navigateToChatPage(); }),
                _fabItem(Icons.lock_clock_rounded, "Ganti Password", () { _toggleFab(); Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordPage(username: username, sessionKey: sessionKey))); }),
                if (role.toLowerCase() == "owner" || role.toLowerCase() == "reseller" || role.toLowerCase() == "vip") _fabItem(Icons.storefront_rounded, "Seller Page", () { _toggleFab(); _navigateToSellerPage(); }),
                if (role.toLowerCase() == "owner") _fabItem(Icons.admin_panel_settings_rounded, "Admin Page", () { _toggleFab(); _navigateToAdminPage(); }),
                _fabDivider(),
                _fabItem(Icons.music_note_rounded, "Musik", () { _toggleFab(); setState(() { _selectedPage = MusikPage(sharedPlayer: _audioPlayer, initialTrack: _currentTrack); _bottomNavIndex = 0; }); }),
                _fabItem(Icons.devices_rounded, "Device Dashboard", () { 
                  _toggleFab(); 
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DeviceDashboard(username: username, role: role, sessionKey: sessionKey))); 
                }),
                _fabItem(Icons.security_rounded, "Control Center", () { _toggleFab(); Navigator.push(context, MaterialPageRoute(builder: (_) => ControlCenterPage())); }),
                _fabItem(Icons.logout_rounded, "Logout", () { _toggleFab(); _showLogoutDialog(); }, danger: true),
              ]),
            ),
          ),
        );
      }),
      GestureDetector(
        onTap: _toggleFab,
        child: AnimatedBuilder(
          animation: _fabAnim,
          builder: (_, __) => Container(
            width: 58, height: 58,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.neonRed, AppColors.neonDarkRed, AppColors.bloodRed]), shape: BoxShape.circle, border: Border.all(color: _fabOpen ? AppColors.highlight : Colors.white24, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 6))]),
            child: Center(child: AnimatedRotation(turns: _fabOpen ? 0.125 : 0, duration: const Duration(milliseconds: 300), child: Icon(_fabOpen ? Icons.close_rounded : Icons.menu_rounded, color: Colors.white, size: 28))),
          ),
        ),
      ),
    ]);
  }

  Widget _fabItem(IconData icon, String label, VoidCallback onTap, {bool danger = false}) {
    return Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(children: [Icon(icon, color: danger ? Colors.white : AppColors.textSec, size: 20), const SizedBox(width: 14), Text(label, style: TextStyle(color: danger ? Colors.white : AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Orbitron'))]))));
  }

  Widget _fabDivider() => Container(height: 1, color: AppColors.border, margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10));

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: AppColors.border)),
          title: const Row(children: [Icon(Icons.logout_rounded, color: Colors.white, size: 26), SizedBox(width: 12), Text("Logout", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Orbitron'))]),
          content: const Text("Yakin ingin keluar dari aplikasi?", style: TextStyle(color: AppColors.textSec, fontSize: 14, fontFamily: 'ShareTechMono')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("BATAL", style: TextStyle(color: AppColors.textSec, fontFamily: 'ShareTechMono', fontSize: 13))),
            TextButton(onPressed: () async { Navigator.pop(context); final prefs = await SharedPreferences.getInstance(); await prefs.clear(); if (!mounted) return; Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false); }, child: const Text("LOGOUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Orbitron', fontSize: 13))),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    _randomTimer?.cancel();
    channel?.sink.close(status.goingAway);
    _fadeCtrl.dispose();
    _fabCtrl.dispose();
    _audioPlayer.dispose();
    _bannerVideoController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}