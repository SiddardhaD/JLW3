import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final Function(String username) onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordHidden = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final name = _usernameController.text.trim();
    widget.onLoginSuccess(name.isNotEmpty ? name : "Guest Approver");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 240),
                  painter: CurvedHeaderPainter(),
                ),
                Positioned(
                  top: 54,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () {},
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF021733),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Login to continue",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Username
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "User Name",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: "Enter your user name",
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFFF6F8FB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF021733)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Password
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isPasswordHidden,
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: const Color(0xFF64748B),
                            ),
                            onPressed: () => setState(() => _isPasswordHidden = !_isPasswordHidden),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6F8FB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF021733)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Action Banner Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF021733),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Biometrics Separator
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("OR", style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Biometrics Row 1
                  _buildBiometricOption(
                    icon: Icons.face,
                    label: "Login with Face ID",
                    onPress: _handleLogin,
                  ),
                  const SizedBox(height: 12),

                  // Biometrics Row 2
                  _buildBiometricOption(
                    icon: Icons.fingerprint,
                    label: "Login with Fingerprint",
                    onPress: _handleLogin,
                  ),

                  const SizedBox(height: 32),

                  // Footer Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, color: Color(0xFF1CB55C), size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Secure • Fast • Reliable",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      )
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

  Widget _buildBiometricOption({
    required IconData icon,
    required String label,
    required VoidCallback onPress,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPress,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurvedHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF021733), Color(0xFF03224B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    final Path path = Path()
      ..lineTo(0, size.height * 0.85)
      ..cubicTo(
        size.width * 0.35,
        size.height * 1.05,
        size.width * 0.65,
        size.height * 0.75,
        size.width,
        size.height * 0.90,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
