import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';

import 'login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> glowAnimation;
  late VideoPlayerController _videoController;

  // Premium Red Neon Theme Colors
  final Color _primaryColor = const Color(0xFFFF0033);   // Red Neon
  final Color _secondaryColor = const Color(0xFFFF0066); // Pink Neon
  final Color _accentColor = const Color(0xFFDC143C);    // Crimson
  final Color _goldColor = const Color(0xFFFFD700);      // Gold accent
  final Color _darkBg = const Color(0xFF0A0A0F);
  final Color _darkerBg = const Color(0xFF000000);
  
  final Color glassColor = Colors.white.withOpacity(0.06);
  final Color glassBorder = Colors.white.withOpacity(0.12);

  // Selected plan
  String _selectedPlan = 'premium';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)
    );
    scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack)
    );
    glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
    _controller.forward();

    _videoController = VideoPlayerController.asset('assets/videos/animek.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.setVolume(0.0);
        _videoController.play();
        setState(() {});
      }).catchError((error) {
        debugPrint("Video initialization error: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Error launching $uri");
    }
  }

  void _showCheckoutModal(String planId, String planName, String price) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: _buildGlassContainer(
            padding: const EdgeInsets.all(24),
            borderRadius: 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.green, Colors.lightGreen]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 20),
                Text(
                  "$planName Plan",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Orbitron',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Menyiapkan transaksi untuk $planName seharga $price",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _openUrl("https://t.me/aboutmeyuji");
                        },
                        child: const Text("Lanjutkan ke Pembayaran"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Kembali",
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassContainer({
    required Widget child, 
    double borderRadius = 28, 
    EdgeInsetsGeometry? padding,
    bool withBorder = true,
    List<Color>? gradient,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient != null 
                ? LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight)
                : null,
            color: gradient == null ? glassColor : null,
            borderRadius: BorderRadius.circular(borderRadius),
            border: withBorder ? Border.all(color: glassBorder, width: 1.2) : null,
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: -5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkBg, _darkerBg],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -150,
            right: -100,
            child: AnimatedBuilder(
              animation: glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _primaryColor.withOpacity(0.15 * glowAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: AnimatedBuilder(
              animation: glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _secondaryColor.withOpacity(0.12 * glowAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 200,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accentColor.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _goldColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DEVELOPER SECTION ====================
  Widget _buildDeveloperSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Developer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Developer",
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              Text(
                "/ 01",
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Developer Card
        _buildGlassContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD3D3D3), Color(0xFFA9A9A9)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 31,
                      backgroundColor: Colors.transparent,
                      child: Icon(Icons.code, size: 30, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Detail Nama & Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "T4rsaxTzy666",
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                border: Border.all(color: Colors.green.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "Verified",
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontFamily: 'Orbitron',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "• Lead Developer",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: glassBorder),
              const SizedBox(height: 16),
              Text(
                "Founder of TR4SVILOiD Project. Bangun tools private, payload custom & dashboard real-time.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildGlassContainer(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      borderRadius: 16,
                      child: InkWell(
                        onTap: () => _openUrl("https://t.me/aboutmeyuji"),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.telegram, size: 16, color: Colors.black87),
                            SizedBox(width: 8),
                            Text(
                              "Telegram",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGlassContainer(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      borderRadius: 16,
                      child: InkWell(
                        onTap: () => _openUrl("mailto:contact@domain.com"),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.email, size: 16, color: Colors.white70),
                            const SizedBox(width: 8),
                            Text(
                              "Contact",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== ACCESS PLANS SECTION (UPDATED WITH SCROLL) ====================
  Widget _buildAccessPlansSection() {
    final Map<String, Map<String, dynamic>> plans = {
      'basic': {
        'name': 'member',
        'price': 'Rp 30K',
        'period': '/ permanently',
        'features': ['Basic tools', 'Limited bug', 'Akses Tools', 'Akses Tools panel'],
        'isHot': false,
      },
      'premium': {
        'name': 'reseller',
        'price': 'Rp 40k',
        'period': '/ permamently',
        'features': ['All bug Akses', 'Tools full akses', 'Real-time chat', 'Priority support'],
        'isHot': true,
      },
      'vip': {
        'name': 'owner',
        'price': 'Rp 70k',
        'period': '/ permanently',
        'features': ['All Premium perks', 'Custom payload', 'Direct dev line', 'Lifetime updates'],
        'isHot': false,
      },
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Access Plans
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Access Plans",
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              Text(
                "/ 02",
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Horizontal Scrolling untuk Plan Cards
        SizedBox(
          height: 520, // Tinggi yang cukup untuk card
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: plans.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              String key = plans.keys.elementAt(index);
              var plan = plans[key];
              
              return Container(
                width: MediaQuery.of(context).size.width - 48, // Lebar card hampir penuh
                margin: const EdgeInsets.only(right: 16),
                child: _buildPlanCard(
                  planId: key,
                  name: plan!['name'],
                  price: plan['price'],
                  period: plan['period'],
                  features: List<String>.from(plan['features']),
                  isHot: plan['isHot'],
                  isSelected: _selectedPlan == key,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String planId,
    required String name,
    required String price,
    required String period,
    required List<String> features,
    required bool isHot,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = planId;
        });
        _showCheckoutModal(planId, name, price);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.grey.shade300, Colors.grey.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : glassColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.grey.shade500 : glassBorder,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black87 : Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            if (isHot) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "HOT",
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: isSelected ? 28 : 24,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black87 : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              period,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? Colors.black54 : Colors.white.withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black12 : Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black26 : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      size: 18,
                      color: isSelected ? Colors.black54 : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: isSelected ? Colors.black12 : glassBorder),
              const SizedBox(height: 16),
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black12 : Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black26 : Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: const Icon(Icons.check, size: 12, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      feature,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected ? Colors.black87 : Colors.white.withOpacity(0.8),
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: _buildGlassContainer(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  borderRadius: 16,
                  gradient: isSelected
                      ? [Colors.black87, Colors.black54]
                      : null,
                  child: Center(
                    child: Text(
                      isSelected ? "Beli Sekarang" : "Pilih $name",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: _buildGlassContainer(
        padding: const EdgeInsets.all(6),
        borderRadius: 24,
        gradient: [Colors.white.withOpacity(0.05), Colors.transparent],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 220,
                color: Colors.black26,
                child: _videoController.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0033)),
                        ),
                      ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeonTitle() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: glowAnimation,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [_primaryColor, _secondaryColor, _goldColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                "TR4SVORTEX v6.0",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: _primaryColor.withOpacity(0.5 * glowAnimation.value),
                      blurRadius: 20,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_primaryColor, _secondaryColor]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.4),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Text(
            "APPS BUGS X RAT",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return _buildGlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_primaryColor, _secondaryColor]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const FaIcon(
              FontAwesomeIcons.handshake,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Welcome to the future of digital security. TR4SVORTEX delivers cutting-edge protection with innovative features designed for professionals.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w400,
              fontFamily: 'ShareTechMono',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeatureChip("STABLE", _primaryColor),
              const SizedBox(width: 8),
              _buildFeatureChip("BUGS", _secondaryColor),
              const SizedBox(width: 8),
              _buildFeatureChip("RAT", _goldColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _primaryButton() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryColor, _secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(FontAwesomeIcons.rocket, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                "SIGN IN",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(width: 12),
              Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: _buildGlassContainer(
        padding: const EdgeInsets.all(0),
        borderRadius: 30,
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => _openUrl("https://t.me/aboutmeyuji"),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.telegramPlane, color: _primaryColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  "JOIN COMMUNITY",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.chevron_right, color: _primaryColor, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(color: _primaryColor.withOpacity(0.3), height: 1),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.green, blurRadius: 5)],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "APPS UPDATES",
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.fingerprint, color: _primaryColor.withOpacity(0.5), size: 14),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "TR4SVORTEX V6.0",
          style: TextStyle(
            color: _primaryColor.withOpacity(0.4),
            fontSize: 9,
            letterSpacing: 1,
            fontFamily: 'ShareTechMono',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkerBg,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // ==================== NEW SECTION: DEVELOPER & ACCESS PLANS ====================
                      _buildDeveloperSection(),
                      const SizedBox(height: 40),
                      _buildAccessPlansSection(),
                      const SizedBox(height: 40),
                      // ==================== EXISTING CONTENT ====================
                      _buildVideoCard(),
                      const SizedBox(height: 30),
                      _buildNeonTitle(),
                      const SizedBox(height: 30),
                      _buildWelcomeCard(),
                      const SizedBox(height: 30),
                      const Text(
                        "ENTER THE LOGIN",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _primaryButton(),
                      const SizedBox(height: 14),
                      _secondaryButton(),
                      const SizedBox(height: 30),
                      _buildFooter(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}