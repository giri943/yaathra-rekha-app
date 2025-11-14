import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'sign.dart';

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({super.key});

  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4B39EF)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'പാസ്വേഡ് റീസെറ്റ് ചെയ്യുക',
                  style: GoogleFonts.notoSansMalayalam(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4B39EF),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'നിങ്ങളുടെ ഇമെയിൽ/ഫോൺ നമ്പറും പുതിയ പാസ്വേഡും നൽകുക',
                  style: GoogleFonts.notoSansMalayalam(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                
                TextFormField(
                  controller: _emailOrPhoneController,
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'പുതിയ പാസ്വേഡ്',
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
                    if (value?.isEmpty ?? true) return 'പുതിയ പാസ്വേഡ് ആവശ്യമാണ്';
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value != _newPasswordController.text) return 'പാസ്വേഡ് മാച്ച് ആവുന്നില്ല';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'പാസ്വേഡ് റീസെറ്റ് ചെയ്യുക',
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SignWidget()),
                      );
                    },
                    child: Text(
                      'സൈൻ ഇൻ പേജിലേക്ക് മടങ്ങുക',
                      style: GoogleFonts.notoSansMalayalam(
                        color: const Color(0xFF4B39EF),
                        fontWeight: FontWeight.w600,
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

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.resetPassword(
        _emailOrPhoneController.text.trim(),
        _newPasswordController.text,
      );

      if (result != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'പാസ്വേഡ് റീസെറ്റ് ചെയ്തു! ഇപ്പോൾ സൈൻ ഇൻ ചെയ്യാം',
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
            'പരാജയപ്പെട്ടു: ${e.toString()}',
            style: GoogleFonts.notoSansMalayalam(),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}