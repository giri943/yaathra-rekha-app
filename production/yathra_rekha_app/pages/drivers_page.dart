import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/driver.dart';
import '../services/driver_service.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  final DriverService _driverService = DriverService();
  List<Driver> _drivers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final drivers = await _driverService.getAllDrivers();
      setState(() {
        _drivers = drivers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'എന്തോ തെറ്റ് സംഭവിച്ചു';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B39EF),
        title: Text(
          'ഡ്രൈവർമാർ',
          style: GoogleFonts.notoSansMalayalam(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: GoogleFonts.notoSansMalayalam(fontSize: 16),
                  ),
                )
              : _drivers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'ഡ്രൈവർമാർ ഇല്ല',
                            style: GoogleFonts.notoSansMalayalam(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ആദ്യത്തെ ഡ്രൈവർ ചേർക്കാൻ + ബട്ടൺ അമർത്തുക',
                            style: GoogleFonts.notoSansMalayalam(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _drivers.length,
                      itemBuilder: (context, index) {
                        final driver = _drivers[index];
                        return _buildDriverCard(driver);
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDriverDialog(),
        backgroundColor: const Color(0xFF4B39EF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDriverCard(Driver driver) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4B39EF), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    driver.name,
                    style: GoogleFonts.notoSansMalayalam(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 18, color: Color(0xFF4B39EF)),
                          const SizedBox(width: 8),
                          Text('പുതുക്കുക', style: GoogleFonts.notoSansMalayalam()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('നീക്കം ചെയ്യുക',
                              style: GoogleFonts.notoSansMalayalam(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDriverDialog(driver);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(driver);
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Text(
                    'ഫോൺ:',
                    style: GoogleFonts.notoSansMalayalam(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    driver.phone,
                    style: GoogleFonts.notoSansMalayalam(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDriverDialog() {
    _showDriverDialog();
  }

  void _showEditDriverDialog(Driver driver) {
    _showDriverDialog(driver: driver);
  }

  void _showDriverDialog({Driver? driver}) {
    final isEdit = driver != null;
    final nameController = TextEditingController(text: driver?.name ?? '');
    final phoneController = TextEditingController(text: driver?.phone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isEdit ? 'ഡ്രൈവർ പുതുക്കുക' : 'ഡ്രൈവർ ചേർക്കുക',
          style: GoogleFonts.notoSansMalayalam(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'പേര്',
                labelStyle: GoogleFonts.notoSansMalayalam(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'ഫോൺ നമ്പർ',
                labelStyle: GoogleFonts.notoSansMalayalam(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('റദ്ദാക്കുക', style: GoogleFonts.notoSansMalayalam()),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                final newDriver = Driver(
                  id: isEdit ? driver.id : DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  phone: phoneController.text,
                  userId: 'temp',
                  createdAt: isEdit ? driver.createdAt : DateTime.now(),
                );

                try {
                  if (isEdit) {
                    await _driverService.updateDriver(newDriver);
                  } else {
                    await _driverService.addDriver(newDriver);
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _loadDrivers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEdit ? 'ഡ്രൈവർ പുതുക്കി' : 'ഡ്രൈവർ ചേർത്തു',
                        style: GoogleFonts.notoSansMalayalam(),
                      ),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'എന്തോ തെറ്റ് സംഭവിച്ചു',
                        style: GoogleFonts.notoSansMalayalam(),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              isEdit ? 'പുതുക്കുക' : 'ചേർക്കുക',
              style: GoogleFonts.notoSansMalayalam(),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Driver driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'ഡ്രൈവർ നീക്കം ചെയ്യുക',
          style: GoogleFonts.notoSansMalayalam(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${driver.name} നീക്കം ചെയ്യാൻ ആഗ്രഹിക്കുന്നുണ്ടോ?',
          style: GoogleFonts.notoSansMalayalam(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('റദ്ദാക്കുക', style: GoogleFonts.notoSansMalayalam()),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _driverService.deleteDriver(driver.id);
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadDrivers();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'ഡ്രൈവർ നീക്കം ചെയ്തു',
                      style: GoogleFonts.notoSansMalayalam(),
                    ),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'എന്തോ തെറ്റ് സംഭവിച്ചു',
                      style: GoogleFonts.notoSansMalayalam(),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'നീക്കം ചെയ്യുക',
              style: GoogleFonts.notoSansMalayalam(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
