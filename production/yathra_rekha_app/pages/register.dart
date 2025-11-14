import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';
import 'sign.dart';

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  AppConstants.appName,
                  style: GoogleFonts.notoSansMalayalam(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4B39EF),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'ഒരു അക്കൗണ്ട് സൃഷ്ടിക്കുക',
                  style: GoogleFonts.notoSansMalayalam(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ഫോം പൂരിപ്പിച്ച് തുടക്കം കുറിക്കാം',
                  style: GoogleFonts.notoSansMalayalam(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'നിങ്ങളുടെ മുഴുവൻ പേര്',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'പേര് ആവശ്യമാണ്';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'ഇമെയിൽ',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'ഇമെയിൽ ആവശ്യമാണ്';
                    if (!value!.contains('@')) return 'സാധുവായ ഇമെയിൽ നൽകുക';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'ഫോൺ നമ്പർ',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'ഫോൺ നമ്പർ ആവശ്യമാണ്';
                    if (value!.length < 10) return 'സാധുവായ ഫോൺ നമ്പർ നൽകുക';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'പാസ്വേഡ്',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'പാസ്വേഡ് ആവശ്യമാണ്';
                    if (value!.length < 6) return 'പാസ്വേഡ് 6 അക്ഷരങ്ങൾ വേണം';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_confirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'പാസ്വേഡ് സ്ഥിരീകരിക്കുക',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) return 'പാസ്വേഡ് മാച്ച് ആവുന്നില്ല';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'അക്കൗണ്ട് സൃഷ്ടിക്കുക',
                            style: GoogleFonts.notoSansMalayalam(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignWidget()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'ഇതിനകം ഒരു അക്കൗണ്ട് ഉണ്ടോ? ',
                        style: GoogleFonts.notoSansMalayalam(color: Colors.grey[600]),
                        children: [
                          TextSpan(
                            text: 'സൈൻ ഇൻ ചെയ്യൂ',
                            style: GoogleFonts.notoSansMalayalam(
                              color: const Color(0xFF4B39EF),
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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
      );

      if (result != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'അക്കൗണ്ട് സൃഷ്ടിച്ചു! സൈൻ ഇൻ ചെയ്യുക',
              style: GoogleFonts.notoSansMalayalam(),
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignWidget()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'രജിസ്ട്രേഷൻ പരാജയപ്പെട്ടു: ${e.toString()}',
            style: GoogleFonts.notoSansMalayalam(),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}