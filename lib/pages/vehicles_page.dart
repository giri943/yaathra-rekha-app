import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  final String userId = 'current_user_id'; // Replace with actual user ID

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
      body: FutureBuilder<List<Vehicle>>(
        future: _vehicleService.getVehicles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'എന്തോ തെറ്റ് സംഭവിച്ചു',
                style: GoogleFonts.notoSansMalayalam(fontSize: 16),
              ),
            );
          }

          final vehicles = snapshot.data ?? [];

          if (vehicles.isEmpty) {
            return Center(
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
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return _buildVehicleCard(vehicle);
            },
          );
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
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.model,
                        style: GoogleFonts.notoSansMalayalam(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        vehicle.manufacturer,
                        style: GoogleFonts.notoSansMalayalam(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('പുതുക്കുക', style: GoogleFonts.notoSansMalayalam()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
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
            
            SizedBox(height: 16),
            
            _buildDateRow('ഇൻഷുറൻസ്:', AppDateUtils.formatDate(vehicle.insuranceExpiry)),
            _buildDateRow('ടാക്സ്:', AppDateUtils.formatDate(vehicle.taxDate)),
            _buildDateRow('ടെസ്റ്റ്:', AppDateUtils.formatDate(vehicle.testDate)),
            _buildDateRow('പൊള്യൂഷൻ:', AppDateUtils.formatDate(vehicle.pollutionDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, String date) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSansMalayalam(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            date,
            style: GoogleFonts.notoSansMalayalam(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showAddVehicleDialog() {
    _showVehicleDialog();
  }

  void _showEditVehicleDialog(Vehicle vehicle) {
    _showVehicleDialog(vehicle: vehicle);
  }

  void _showVehicleDialog({Vehicle? vehicle}) {
    final isEdit = vehicle != null;
    final modelController = TextEditingController(text: vehicle?.model ?? '');
    final manufacturerController = TextEditingController(text: vehicle?.manufacturer ?? '');
    
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
                  controller: modelController,
                  decoration: InputDecoration(
                    labelText: 'മോഡൽ',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: manufacturerController,
                  decoration: InputDecoration(
                    labelText: 'നിർമ്മാതാവ്',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(),
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
                if (modelController.text.isNotEmpty && manufacturerController.text.isNotEmpty) {
                  final newVehicle = Vehicle(
                    id: isEdit ? vehicle!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                    model: modelController.text,
                    manufacturer: manufacturerController.text,
                    insuranceExpiry: insuranceDate,
                    taxDate: taxDate,
                    testDate: testDate,
                    pollutionDate: pollutionDate,
                    userId: userId,
                    createdAt: isEdit ? vehicle!.createdAt : DateTime.now(),
                  );

                  try {
                    if (isEdit) {
                      await _vehicleService.updateVehicle(newVehicle);
                    } else {
                      await _vehicleService.addVehicle(newVehicle);
                    }
                    Navigator.pop(context);
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