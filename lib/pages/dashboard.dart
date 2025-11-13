import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/modern_theme.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';
import 'vehicles_page.dart';
import 'contracts_page.dart';
import 'trips_page.dart';
import 'drivers_page.dart';
import 'welcome.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.background,
      appBar: AppBar(
        backgroundColor: ModernTheme.primary,
        title: Text(
          'യാത്ര രേഖ',
          style: GoogleFonts.notoSansMalayalam(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: _currentUser?['avatar'] != null
                ? ClipOval(
                    child: Image.network(
                      '${AppConfig.apiBaseUrl.replaceAll('/api', '')}/api/proxy-image?url=${Uri.encodeComponent(_currentUser!['avatar'])}',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          _currentUser?['name']?.substring(0, 1).toUpperCase() ?? 'U',
                          style: GoogleFonts.notoSansMalayalam(
                            color: ModernTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  )
                : Text(
                    _currentUser?['name']?.substring(0, 1).toUpperCase() ?? 'U',
                    style: GoogleFonts.notoSansMalayalam(
                      color: ModernTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?['name'] ?? '',
                      style: GoogleFonts.notoSansMalayalam(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currentUser?['email'] ?? '',
                      style: GoogleFonts.notoSansMalayalam(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('ലോഗൗട്', style: GoogleFonts.notoSansMalayalam()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('അക്കൗണ്ട് ഡിലീറ്റ് ചെയ്യുക', 
                      style: GoogleFonts.notoSansMalayalam(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'delete') {
                _showDeleteAccountDialog();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'സ്വാഗതം ${_currentUser?['name'] ?? ''}',
                style: GoogleFonts.notoSansMalayalam(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ModernTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildDashboardCard(
                      context,
                      'വാഹനങ്ങൾ',
                      'വാഹനങ്ങൾ കൈകാര്യം ചെയ്യുക',
                      Icons.directions_car,
                      ModernTheme.primary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VehiclesPage()),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'കരാറുകൾ',
                      'കരാറുകൾ കൈകാര്യം ചെയ്യുക',
                      Icons.description,
                      ModernTheme.secondary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContractsPage()),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'യാത്രകൾ',
                      'സവാരി യാത്രകൾ ട്രാക്ക് ചെയ്യുക',
                      Icons.route,
                      ModernTheme.tertiary,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TripsPage()),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'ഡ്രൈവർമാർ',
                      'ഡ്രൈവർ വിവരങ്ങൾ കൈകാര്യം ചെയ്യുക',
                      Icons.contacts,
                      Color(0xFFF59E0B),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DriversPage()),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'സംഗ്രഹങ്ങൾ',
                      'റിപ്പോർട്ടുകൾ കാണുക',
                      Icons.analytics,
                      ModernTheme.accent,
                      () => _showComingSoon(context, 'സംഗ്രഹങ്ങൾ'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.notoSansMalayalam(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSansMalayalam(
                    fontSize: 12,
                    color: Color(0xFF64748B),
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
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'ഉടൻ വരുന്നു',
            style: GoogleFonts.notoSansMalayalam(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '$feature ഫീച്ചർ ഉടൻ ലഭ്യമാകും!',
            style: GoogleFonts.notoSansMalayalam(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ശരി',
                style: GoogleFonts.notoSansMalayalam(
                  color: ModernTheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await _authService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WelcomeWidget()),
      (route) => false,
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'അക്കൗണ്ട് ഡിലീറ്റ് ചെയ്യുക',
          style: GoogleFonts.notoSansMalayalam(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'നിങ്ങളുടെ അക്കൗണ്ട് സ്ഥിരമായി ഡിലീറ്റ് ചെയ്യാനാഗ്രഹിക്കുന്നുണ്ടോ? ഈ പ്രവർത്തനം തിരിച്ചുവരാൻ കഴിയില്ല.',
          style: GoogleFonts.notoSansMalayalam(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('റദ്ദാക്കുക', style: GoogleFonts.notoSansMalayalam()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _authService.deleteAccount();
              if (success) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeWidget()),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'അക്കൗണ്ട് ഡിലീറ്റ് ചെയ്തു',
                      style: GoogleFonts.notoSansMalayalam(),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'ഡിലീറ്റ് ചെയ്യുക',
              style: GoogleFonts.notoSansMalayalam(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}