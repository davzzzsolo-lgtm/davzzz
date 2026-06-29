import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'splash.dart';

const String baseUrl = "http://draoffice.danzxnhosting.my.id:11860";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final userController = TextEditingController();
  final passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool _obscurePassword = true;
  String? androidId;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Premium Red Neon Theme Colors
  final Color primaryNeon = const Color(0xFFFF0033);   // Red Neon
  final Color secondaryNeon = const Color(0xFFFF0066); // Pink Neon
  final Color accentNeon = const Color(0xFFDC143C);    // Crimson
  final Color goldAccent = const Color(0xFFFFD700);    // Gold premium
  final Color deepDark = const Color(0xFF0A0A0F);
  final Color cardBg = const Color(0xFF1A0F1A).withOpacity(0.85);
  
  // Gradient premium
  late LinearGradient primaryGradient;
  late LinearGradient neonGradient;
  late LinearGradient backgroundGradient;

  @override
  void initState() {
    super.initState();
    initGradients();
    _initAnim();
    initLogin();
  }

  void initGradients() {
    primaryGradient = LinearGradient(
      colors: [primaryNeon, secondaryNeon],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
    neonGradient = LinearGradient(
      colors: [primaryNeon, secondaryNeon, goldAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0.0, 0.5, 1.0],
    );
    
    backgroundGradient = LinearGradient(
      colors: [
        const Color(0xFF0A0A0F),
        const Color(0xFF1A0A15),
        const Color(0xFF0A0A0F),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  void _initAnim() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  Future<void> initLogin() async {
    androidId = await getAndroidId();

    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString("username");
    final savedPass = prefs.getString("password");
    final savedKey = prefs.getString("key");

    if (savedUser != null && savedPass != null && savedKey != null) {
      final uri = Uri.parse(
          "$baseUrl/myInfo?username=$savedUser&password=$savedPass&androidId=$androidId&key=$savedKey");

      try {
        final res = await http.get(uri);
        final data = jsonDecode(res.body);

        if (data['valid'] == true) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SplashScreen(
                  username: savedUser,
                  password: savedPass,
                  role: data['role'],
                  sessionKey: data['key'],
                  expiredDate: data['expiredDate'],
                  listBug: (data['listBug'] as List? ?? [])
                      .map((e) => Map<String, dynamic>.from(e as Map))
                      .toList(),
                  listDoos: (data['listDDoS'] as List? ?? [])
                      .map((e) => Map<String, dynamic>.from(e as Map))
                      .toList(),
                  news: (data['news'] as List? ?? [])
                      .map((e) => Map<String, dynamic>.from(e as Map))
                      .toList(),
                ),
              ),
            );
          }
        }
      } catch (_) {}
    }
  }

  Future<String> getAndroidId() async {
    final deviceInfo = DeviceInfoPlugin();
    final android = await deviceInfo.androidInfo;
    return android.id ?? "unknown_device";
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    final username = userController.text.trim();
    final password = passController.text.trim();

    setState(() => isLoading = true);

    try {
      final validate = await http.post(
        Uri.parse("$baseUrl/validate"),
        body: {
          "username": username,
          "password": password,
          "androidId": androidId ?? "unknown_device",
        },
      ).timeout(const Duration(seconds: 30));

      final validData = jsonDecode(validate.body);

      if (validData['expired'] == true) {
        _showNeonDialog(
          title: "⏳ ACCESS EXPIRED",
          message: "Your access has expired.\nPlease renew it.",
          icon: Icons.timer_off,
          color: goldAccent,
          showContact: true,
        );
      } else if (validData['valid'] != true) {
        _showNeonDialog(
          title: "⚠️ LOGIN FAILED",
          message: "Invalid username or password.",
          icon: Icons.error_outline,
          color: primaryNeon,
        );
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("username", username);
        await prefs.setString("password", password);
        await prefs.setString("key", validData['key']);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SplashScreen(
                username: username,
                password: password,
                role: validData['role'],
                sessionKey: validData['key'],
                expiredDate: validData['expiredDate'],
                listBug: (validData['listBug'] as List? ?? [])
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList(),
                listDoos: (validData['listDDoS'] as List? ?? [])
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList(),
                news: (validData['news'] as List? ?? [])
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      _showNeonDialog(
        title: "🔌 CONNECTION ERROR",
        message: "Failed to connect to the server.\nPlease check your internet connection.",
        icon: Icons.wifi_off,
        color: primaryNeon,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showNeonDialog({
    required String title,
    required String message,
    required IconData icon,
    Color color = Colors.red,
    bool showContact = false,
  }) {
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
          ),
          title: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          actions: [
            if (showContact)
              _buildNeonButton(
                text: "CONTACT ADMIN",
                onPressed: () async {
                  final uri = Uri.parse("https://t.me/Tarsax_Reals02");
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                color: secondaryNeon,
              ),
            _buildNeonButton(
              text: "CLOSE",
              onPressed: () => Navigator.pop(context),
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeonButton({required String text, required VoidCallback onPressed, required Color color}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.5), width: 1),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    userController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: deepDark,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: backgroundGradient,
            ),
          ),
          
          // Animated Floating Bubbles (Red Theme)
          ...List.generate(3, (index) {
            return Positioned(
              top: screenSize.height * (0.1 + index * 0.2),
              left: screenSize.width * (0.1 + index * 0.3),
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(seconds: 3 + index),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: 0.3 - (index * 0.1),
                    child: Container(
                      width: 50 + (index * 30),
                      height: 50 + (index * 30),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [primaryNeon.withOpacity(0.3), Colors.transparent],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          // Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo dengan efek neon merah
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: neonGradient,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: primaryNeon.withOpacity(0.6),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: secondaryNeon.withOpacity(0.4),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.asset(
                              'assets/images/logo.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Animated Title with Red Gradient
                        ShaderMask(
                          shaderCallback: (bounds) => neonGradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: const Text(
                            "TR4SVORTEX",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: neonGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primaryNeon.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Text(
                            "POWERED BY TARSAX",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Login Card
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: primaryNeon.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryNeon.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      _buildNeonTextField(
                                        controller: userController,
                                        label: "USERNAME",
                                        icon: Icons.person_outline,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildNeonTextField(
                                        controller: passController,
                                        label: "PASSWORD",
                                        icon: Icons.lock_outline,
                                        obscureText: _obscurePassword,
                                        isPassword: true,
                                      ),
                                      const SizedBox(height: 32),
                                      
                                      // Login Button
                                      Container(
                                        width: double.infinity,
                                        height: 55,
                                        decoration: BoxDecoration(
                                          gradient: neonGradient,
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryNeon.withOpacity(0.5),
                                              blurRadius: 15,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: isLoading ? null : login,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: isLoading
                                              ? SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      primaryNeon,
                                                    ),
                                                  ),
                                                )
                                              : const Text(
                                                  "SIGN IN →",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      
                                      // Footer
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 1,
                                            color: primaryNeon.withOpacity(0.3),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            "SECURE CONNECTION",
                                            style: TextStyle(
                                              fontSize: 10,
                                              letterSpacing: 1.5,
                                              color: primaryNeon.withOpacity(0.6),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            width: 40,
                                            height: 1,
                                            color: primaryNeon.withOpacity(0.3),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: primaryNeon.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: primaryNeon, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: primaryNeon.withOpacity(0.6),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryNeon.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryNeon.withOpacity(0.3), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryNeon, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? "Please enter ${label.toLowerCase()}" : null,
        ),
      ],
    );
  }
}