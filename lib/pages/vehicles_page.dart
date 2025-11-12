import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../constants/app_constants.dart';
import '../utils/date_utils.dart';
import '../widgets/date_picker_field.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  final VehicleService _vehicleService = VehicleService();
  final String userId = 'current_user_id';
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final vehiclesData = await _vehicleService.getVehicles();
      setState(() {
        _vehicles = vehiclesData['vehicles'];
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
      backgroundColor: Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: Color(0xFF4B39EF),
        title: Text(
          'വാഹനങ്ങൾ',
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
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: GoogleFonts.notoSansMalayalam(fontSize: 16),
                  ),
                )
              : _vehicles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'വാഹനങ്ങൾ ഇല്ല',
                            style: GoogleFonts.notoSansMalayalam(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'ആദ്യത്തെ വാഹനം ചേർക്കാൻ + ബട്ടൺ അമർത്തുക',
                            style: GoogleFonts.notoSansMalayalam(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = _vehicles[index];
                        return _buildVehicleCard(vehicle);
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVehicleDialog(),
        backgroundColor: Color(0xFF4B39EF),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [
          // Header with vehicle info
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
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
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.vehicleNumber,
                        style: GoogleFonts.notoSansMalayalam(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${vehicle.model} - ${vehicle.manufacturer}',
                        style: GoogleFonts.notoSansMalayalam(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Color(0xFF4B39EF)),
                          SizedBox(width: 8),
                          Text('പുതുക്കുക', style: GoogleFonts.notoSansMalayalam()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('നീക്കം ചെയ്യുക', 
                            style: GoogleFonts.notoSansMalayalam(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditVehicleDialog(vehicle);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(vehicle);
                    }
                  },
                ),
              ],
            ),
          ),
          // Content with dates
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDateCard(
                        icon: Icons.security,
                        title: 'ഇൻഷുറൻസ്',
                        date: AppDateUtils.formatDate(vehicle.insuranceExpiry),
                        isExpiring: _isExpiringSoon(vehicle.insuranceExpiry),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildDateCard(
                        icon: Icons.account_balance,
                        title: 'ടാക്സ്',
                        date: AppDateUtils.formatDate(vehicle.taxDate),
                        isExpiring: _isExpiringSoon(vehicle.taxDate),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateCard(
                        icon: Icons.verified,
                        title: 'ടെസ്റ്റ്',
                        date: AppDateUtils.formatDate(vehicle.testDate),
                        isExpiring: _isExpiringSoon(vehicle.testDate),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildDateCard(
                        icon: Icons.eco,
                        title: 'പൊള്യൂഷൻ',
                        date: AppDateUtils.formatDate(vehicle.pollutionDate),
                        isExpiring: _isExpiringSoon(vehicle.pollutionDate),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Pricing info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.currency_rupee, size: 14, color: Color(0xFF1D4ED8)),
                                SizedBox(width: 4),
                                Text(
                                  '5 കി.മീ വരെ',
                                  style: GoogleFonts.notoSansMalayalam(
                                    fontSize: 11,
                                    color: Color(0xFF1D4ED8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              '₹${vehicle.fixedRateFor5Km.toStringAsFixed(0)}',
                              style: GoogleFonts.notoSansMalayalam(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Color(0xFFBFDBFE),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.speed, size: 14, color: Color(0xFF1D4ED8)),
                                SizedBox(width: 4),
                                Text(
                                  'ഓരോ കി.മീ',
                                  style: GoogleFonts.notoSansMalayalam(
                                    fontSize: 11,
                                    color: Color(0xFF1D4ED8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              '₹${vehicle.perKmRate.toStringAsFixed(0)}',
                              style: GoogleFonts.notoSansMalayalam(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard({
    required IconData icon,
    required String title,
    required String date,
    required bool isExpiring,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isExpiring ? Color(0xFFFEF3C7) : Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isExpiring ? Color(0xFFFDE68A) : Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isExpiring ? Color(0xFFD97706) : Color(0xFF64748B),
              ),
              SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.notoSansMalayalam(
                  fontSize: 11,
                  color: isExpiring ? Color(0xFFD97706) : Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            date,
            style: GoogleFonts.notoSansMalayalam(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isExpiring ? Color(0xFF92400E) : Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  bool _isExpiringSoon(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference <= 30 && difference >= 0;
  }

  void _showAddVehicleDialog() {
    _showVehicleDialog();
  }

  void _showEditVehicleDialog(Vehicle vehicle) {
    _showVehicleDialog(vehicle: vehicle);
  }

  void _showVehicleDialog({Vehicle? vehicle}) {
    final isEdit = vehicle != null;
    final vehicleNumberController = TextEditingController(text: vehicle?.vehicleNumber ?? '');
    final modelController = TextEditingController(text: vehicle?.model ?? '');
    final manufacturerController = TextEditingController(text: vehicle?.manufacturer ?? '');
    final fixedRateController = TextEditingController(text: vehicle?.fixedRateFor5Km.toString() ?? '');
    final perKmRateController = TextEditingController(text: vehicle?.perKmRate.toString() ?? '');
    
    DateTime insuranceDate = vehicle?.insuranceExpiry ?? DateTime.now();
    DateTime taxDate = vehicle?.taxDate ?? DateTime.now();
    DateTime testDate = vehicle?.testDate ?? DateTime.now();
    DateTime pollutionDate = vehicle?.pollutionDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            isEdit ? 'വാഹനം പുതുക്കുക' : 'വാഹനം ചേർക്കുക',
            style: GoogleFonts.notoSansMalayalam(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: vehicleNumberController,
                  decoration: InputDecoration(
                    labelText: 'വാഹന നമ്പർ',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: modelController,
                  decoration: InputDecoration(
                    labelText: 'മോഡൽ',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.car_rental),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: manufacturerController,
                  decoration: InputDecoration(
                    labelText: 'നിർമ്മാതാവ്',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                SizedBox(height: 16),
                DatePickerField(
                  label: AppConstants.insuranceExpiry,
                  selectedDate: insuranceDate,
                  onDateSelected: (date) => setState(() => insuranceDate = date),
                ),
                SizedBox(height: 16),
                DatePickerField(
                  label: AppConstants.taxDate,
                  selectedDate: taxDate,
                  onDateSelected: (date) => setState(() => taxDate = date),
                ),
                SizedBox(height: 16),
                DatePickerField(
                  label: AppConstants.testDate,
                  selectedDate: testDate,
                  onDateSelected: (date) => setState(() => testDate = date),
                ),
                SizedBox(height: 16),
                DatePickerField(
                  label: AppConstants.pollutionDate,
                  selectedDate: pollutionDate,
                  onDateSelected: (date) => setState(() => pollutionDate = date),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: fixedRateController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '5 കി.മീ വരെ നിശ്ചിത നിരക്ക് (₹)',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: perKmRateController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ഓരോ കി.മീ നിരക്ക് (₹)',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.speed),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('റദ്ദാക്കുക', style: GoogleFonts.notoSansMalayalam()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (vehicleNumberController.text.isNotEmpty && 
                    modelController.text.isNotEmpty && 
                    manufacturerController.text.isNotEmpty &&
                    fixedRateController.text.isNotEmpty &&
                    perKmRateController.text.isNotEmpty) {
                  final newVehicle = Vehicle(
                    id: isEdit ? vehicle.id : DateTime.now().millisecondsSinceEpoch.toString(),
                    vehicleNumber: vehicleNumberController.text,
                    model: modelController.text,
                    manufacturer: manufacturerController.text,
                    insuranceExpiry: insuranceDate,
                    taxDate: taxDate,
                    testDate: testDate,
                    pollutionDate: pollutionDate,
                    userId: userId,
                    createdAt: isEdit ? vehicle.createdAt : DateTime.now(),
                    fixedRateFor5Km: double.parse(fixedRateController.text),
                    perKmRate: double.parse(perKmRateController.text),
                  );

                  try {
                    if (isEdit) {
                      await _vehicleService.updateVehicle(newVehicle);
                    } else {
                      await _vehicleService.addVehicle(newVehicle);
                    }
                    Navigator.pop(context);
                    _loadVehicles();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit ? 'വാഹനം പുതുക്കി' : 'വാഹനം ചേർത്തു',
                          style: GoogleFonts.notoSansMalayalam(),
                        ),
                      ),
                    );
                  } catch (e) {
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
      ),
    );
  }

  void _showDeleteConfirmation(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'വാഹനം നീക്കം ചെയ്യുക',
          style: GoogleFonts.notoSansMalayalam(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${vehicle.model} നീക്കം ചെയ്യാൻ ആഗ്രഹിക്കുന്നുണ്ടോ?',
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
                await _vehicleService.deleteVehicle(vehicle.id);
                Navigator.pop(context);
                _loadVehicles();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'വാഹനം നീക്കം ചെയ്തു',
                      style: GoogleFonts.notoSansMalayalam(),
                    ),
                  ),
                );
              } catch (e) {
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