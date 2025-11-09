import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';
import 'dashboard.dart';
import 'register.dart';
import 'forgot_password.dart';

class SignWidget extends StatefulWidget {
  const SignWidget({super.key});

  @override
  State<SignWidget> createState() => _SignWidgetState();
}

class _SignWidgetState extends State<SignWidget> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60),
                Text(
                  AppConstants.appName,
                  style: GoogleFonts.notoSansMalayalam(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B39EF),
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'സ്വാഗതം',
                  style: GoogleFonts.notoSansMalayalam(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'ഫോം പൂരിപ്പിച്ച് തുടക്കം കുറിക്കാം',
                  style: GoogleFonts.notoSansMalayalam(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'ഇമെയിൽ അഥവാ ഫോൺ',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'ഇമെയിൽ അഥവാ ഫോൺ ആവശ്യമാണ്';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'പാസ്വേഡ്',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'പാസ്വേഡ് ആവശ്യമാണ്';
                    return null;
                  },
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'സൈൻ ഇൻ',
                            style: GoogleFonts.notoSansMalayalam(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('അഥവാ', style: GoogleFonts.notoSansMalayalam()),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Google വഴി സൈൻ ഇൻ',
                          style: GoogleFonts.notoSansMalayalam(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ForgotPasswordWidget()),
                      );
                    },
                    child: Text(
                      'പാസ്വേഡ് മറന്നോ?',
                      style: GoogleFonts.notoSansMalayalam(
                        color: Color(0xFF4B39EF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterWidget()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'അക്കൗണ്ട് ഇല്ലേ? ',
                        style: GoogleFonts.notoSansMalayalam(color: Colors.grey[600]),
                        children: [
                          TextSpan(
                            text: 'ഇവിടെ സൈൻ അപ്പ് ചെയ്യൂ',
                            style: GoogleFonts.notoSansMalayalam(
                              color: Color(0xFF4B39EF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signInWithEmailOrPhone(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (result != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardWidget()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'തെറ്റായ ഇമെയിൽ/ഫോൺ അല്ലെങ്കിൽ പാസ്വേഡ്',
              style: GoogleFonts.notoSansMalayalam(),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'സൈൻ ഇൻ പരാജയപ്പെട്ടു: ${e.toString()}',
            style: GoogleFonts.notoSansMalayalam(),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final result = await _authService.signInWithGoogle();

      if (result != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardWidget()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google സൈൻ ഇൻ പരാജയപ്പെട്ടു: ${e.toString()}',
            style: GoogleFonts.notoSansMalayalam(),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}