import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/contract.dart';
import '../models/vehicle.dart';
import '../services/contract_service.dart';
import '../utils/date_utils.dart';

class ContractsPage extends StatefulWidget {
  const ContractsPage({super.key});

  @override
  State<ContractsPage> createState() => _ContractsPageState();
}

class _ContractsPageState extends State<ContractsPage> {
  final ContractService _contractService = ContractService();
  final String userId = 'current_user_id';
  List<Contract> _contracts = [];
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  bool _isFiltering = false;
  String? _error;
  String? _selectedVehicleFilter;
  String? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool showOverlay = false}) async {
    setState(() {
      if (showOverlay) {
        _isFiltering = true;
      } else {
        _isLoading = true;
      }
      _error = null;
    });
    
    try {
      final pageData = await _contractService.getContractsPageData(
        vehicleId: _selectedVehicleFilter,
        status: _selectedStatusFilter,
      );
      setState(() {
        _contracts = pageData['contracts'];
        _vehicles = pageData['vehicles'];
        _isLoading = false;
        _isFiltering = false;
      });
    } catch (e) {
      setState(() {
        _error = 'എന്തോ തെറ്റ് സംഭവിച്ചു';
        _isLoading = false;
        _isFiltering = false;
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
          'കരാറുകൾ',
          style: GoogleFonts.notoSansMalayalam(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedVehicleFilter,
                    decoration: InputDecoration(
                      labelText: 'വാഹനം',
                      labelStyle: GoogleFonts.notoSansMalayalam(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text('എല്ലാം', style: GoogleFonts.notoSansMalayalam(fontSize: 12))),
                      ..._vehicles.map((v) => DropdownMenuItem(
                        value: v.id,
                        child: Text(v.vehicleNumber, style: GoogleFonts.notoSansMalayalam(fontSize: 12)),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedVehicleFilter = value;
                      });
                      _loadData(showOverlay: true);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStatusFilter,
                    decoration: InputDecoration(
                      labelText: 'സ്റ്റാറ്റസ്',
                      labelStyle: GoogleFonts.notoSansMalayalam(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text('എല്ലാം', style: GoogleFonts.notoSansMalayalam(fontSize: 12))),
                      DropdownMenuItem(value: 'active', child: Text('സജീവം', style: GoogleFonts.notoSansMalayalam(fontSize: 12))),
                      DropdownMenuItem(value: 'expiring', child: Text('ഉടൻ അവസാനം', style: GoogleFonts.notoSansMalayalam(fontSize: 12))),
                      DropdownMenuItem(value: 'expired', child: Text('അവസാനിച്ചു', style: GoogleFonts.notoSansMalayalam(fontSize: 12))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatusFilter = value;
                      });
                      _loadData(showOverlay: true);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Text(
                              _error!,
                              style: GoogleFonts.notoSansMalayalam(fontSize: 16),
                            ),
                          )
                        : _contracts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.description, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'കരാറുകൾ ഇല്ല',
                                style: GoogleFonts.notoSansMalayalam(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ആദ്യത്തെ കരാർ ചേർക്കാൻ + ബട്ടൺ അമർത്തുക',
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
                          itemCount: _contracts.length,
                          itemBuilder: (context, index) {
                            final contract = _contracts[index];
                            return _buildContractCard(contract);
                          },
                        ),
                if (_isFiltering)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContractDialog(),
        backgroundColor: const Color(0xFF4B39EF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContractCard(Contract contract) {
    final isExpired = contract.contractEndDate.isBefore(DateTime.now());
    final isExpiringSoon = contract.contractEndDate.difference(DateTime.now()).inDays <= 30 && !isExpired;
    
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
          // Header with contract info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isExpired 
                    ? [const Color(0xFF991B1B), const Color(0xFFDC2626)]
                    : isExpiringSoon
                        ? [const Color(0xFFD97706), const Color(0xFFF59E0B)]
                        : [const Color(0xFF059669), const Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
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
                    Icons.assignment,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contract.contractName,
                        style: GoogleFonts.notoSansMalayalam(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (contract.vehicle != null)
                        Text(
                          contract.vehicle!.vehicleNumber,
                          style: GoogleFonts.notoSansMalayalam(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isExpired || isExpiringSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpired ? Colors.red : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isExpired ? 'അവസാനിച്ചു' : 'ഉടൻ അവസാനം',
                      style: GoogleFonts.notoSansMalayalam(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 18, color: Color(0xFF059669)),
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
                      _showEditContractDialog(contract);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(contract);
                    }
                  },
                ),
              ],
            ),
          ),
          // Content with contract details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.currency_rupee,
                        title: 'നിരക്ക്',
                        value: '₹${contract.rate.toStringAsFixed(0)}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.route,
                        title: 'ശരാശരി ദൂരം',
                        value: '${contract.averageDistance.toStringAsFixed(1)} കി.മീ',
                      ),
                    ),
                  ],
                ),
                if (contract.contactPhone != null && contract.contactPhone!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
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
                          contract.contactPhone!,
                          style: GoogleFonts.notoSansMalayalam(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isExpired ? const Color(0xFFFEE2E2) : isExpiringSoon ? const Color(0xFFFEF3C7) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isExpired ? const Color(0xFFFECACA) : isExpiringSoon ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isExpired ? const Color(0xFFDC2626) : isExpiringSoon ? const Color(0xFFD97706) : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'കരാർ അവസാന തീയതി:',
                        style: GoogleFonts.notoSansMalayalam(
                          fontSize: 12,
                          color: isExpired ? const Color(0xFFDC2626) : isExpiringSoon ? const Color(0xFFD97706) : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        AppDateUtils.formatDate(contract.contractEndDate),
                        style: GoogleFonts.notoSansMalayalam(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isExpired ? const Color(0xFF991B1B) : isExpiringSoon ? const Color(0xFF92400E) : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isExpired)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.notoSansMalayalam(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.notoSansMalayalam(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddContractDialog() {
    _showContractDialog();
  }

  void _showEditContractDialog(Contract contract) {
    _showContractDialog(contract: contract);
  }

  void _showContractDialog({Contract? contract}) {
    final isEdit = contract != null;
    final contractNameController = TextEditingController(text: contract?.contractName ?? '');
    final rateController = TextEditingController(text: contract?.rate.toString() ?? '');
    final distanceController = TextEditingController(text: contract?.averageDistance.toString() ?? '');
    final contactPhoneController = TextEditingController(text: contract?.contactPhone ?? '');
    String? selectedVehicleId = contract?.vehicleId;
    DateTime? contractEndDate = contract?.contractEndDate;
    bool dateSelected = isEdit;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            isEdit ? 'കരാർ പുതുക്കുക' : 'കരാർ ചേർക്കുക',
            style: GoogleFonts.notoSansMalayalam(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contractNameController,
                  decoration: InputDecoration(
                    labelText: 'കരാർ പേര്',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.assignment),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: rateController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'നിരക്ക് (₹)',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.currency_rupee),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedVehicleId,
                  decoration: InputDecoration(
                    labelText: 'വാഹനം',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: const OutlineInputBorder(),
                  ),
                  items: _vehicles.map((vehicle) {
                    return DropdownMenuItem<String>(
                      value: vehicle.id,
                      child: Text(
                        '${vehicle.vehicleNumber} - ${vehicle.model}',
                        style: GoogleFonts.notoSansMalayalam(),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedVehicleId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: distanceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ശരാശരി ദൈർഘ്യം (കി.മീ)',
                    labelStyle: GoogleFonts.notoSansMalayalam(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.route),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contactPhoneController,
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
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final initialDate = contractEndDate != null && contractEndDate!.isAfter(now) 
                        ? contractEndDate! 
                        : now.add(const Duration(days: 365));
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setState(() {
                        contractEndDate = picked;
                        dateSelected = true;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'കരാർ അവസാന തീയതി',
                          style: GoogleFonts.notoSansMalayalam(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateSelected ? AppDateUtils.formatDate(contractEndDate!) : 'തീയതി തിരഞ്ഞെടുക്കുക',
                          style: GoogleFonts.notoSansMalayalam(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: dateSelected ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ],
                    ),
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
                if (contractNameController.text.isNotEmpty && 
                    rateController.text.isNotEmpty && 
                    selectedVehicleId != null &&
                    distanceController.text.isNotEmpty &&
                    contractEndDate != null) {
                  final newContract = Contract(
                    id: isEdit ? contract.id : DateTime.now().millisecondsSinceEpoch.toString(),
                    contractName: contractNameController.text,
                    rate: double.parse(rateController.text),
                    vehicleId: selectedVehicleId!,
                    averageDistance: double.parse(distanceController.text),
                    contractEndDate: contractEndDate!,
                    contactPhone: contactPhoneController.text.isEmpty ? null : contactPhoneController.text,
                    userId: userId,
                    createdAt: isEdit ? contract.createdAt : DateTime.now(),
                  );

                  try {
                    if (isEdit) {
                      await _contractService.updateContract(newContract);
                    } else {
                      await _contractService.addContract(newContract);
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit ? 'കരാർ പുതുക്കി' : 'കരാർ ചേർത്തു',
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
      ),
    );
  }

  void _showDeleteConfirmation(Contract contract) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'കരാർ നീക്കം ചെയ്യുക',
          style: GoogleFonts.notoSansMalayalam(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${contract.contractName} നീക്കം ചെയ്യാൻ ആഗ്രഹിക്കുന്നുണ്ടോ?',
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
                await _contractService.deleteContract(contract.id);
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'കരാർ നീക്കം ചെയ്തു',
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