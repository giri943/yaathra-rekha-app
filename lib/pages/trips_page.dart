import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trip.dart';
import '../models/contract.dart';
import '../models/vehicle.dart';
import '../models/driver.dart';
import '../services/trip_service.dart';
import '../services/driver_service.dart';
import '../utils/date_utils.dart';
import '../widgets/trip_accordion_card.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> with SingleTickerProviderStateMixin {
  final TripService _tripService = TripService();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  List<Trip> _trips = [];
  List<Trip> _filteredTrips = [];
  List<Contract> _contracts = [];
  List<Vehicle> _vehicles = [];
  List<Driver> _drivers = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isFiltering = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _expandedTripId;
  
  // Filter variables
  String? _selectedVehicleId;
  String? _selectedContractId;
  String? _selectedSalaryStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadData();
      }
    });
    _loadData();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreTrips();
      }
    }
  }

  Future<void> _loadData({bool isFilter = false}) async {
    setState(() {
      if (isFilter) {
        _isFiltering = true;
      } else {
        _isLoading = true;
        _trips.clear();
      }
      _error = null;
      _currentPage = 1;
    });

    try {
      final tripType = _tabController.index == 0 ? 'contract' : 'savari';
      final data = await _tripService.getTrips(
        page: 1,
        tripType: tripType,
        vehicleId: _selectedVehicleId,
        contractId: _selectedContractId,
        salaryPaid: _selectedSalaryStatus,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      setState(() {
        _trips = data['trips'];
        _filteredTrips = _trips;
        if (!isFilter) {
          _contracts = data['contracts'];
          _vehicles = data['vehicles'];
          _drivers = data['drivers'];
        }
        _hasMore = data['pagination']['hasNext'];
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
  
  Future<void> _loadMoreTrips() async {
    if (_isLoadingMore || !_hasMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      final tripType = _tabController.index == 0 ? 'contract' : 'savari';
      final tripsData = await _tripService.getTrips(
        page: _currentPage + 1,
        tripType: tripType,
        vehicleId: _selectedVehicleId,
        contractId: _selectedContractId,
        salaryPaid: _selectedSalaryStatus,
        startDate: _startDate,
        endDate: _endDate,
      );
      setState(() {
        _trips.addAll(tripsData['trips']);
        _filteredTrips.addAll(tripsData['trips']);
        _currentPage++;
        _hasMore = tripsData['pagination']['hasNext'];
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
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
          'യാത്രകൾ',
          style: GoogleFonts.notoSansMalayalam(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list, color: Colors.white),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          labelStyle: GoogleFonts.notoSansMalayalam(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.notoSansMalayalam(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            Tab(text: 'കരാർ'),
            Tab(text: 'സവാരി'),
          ],
        ),
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
              : _filteredTrips.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'യാത്രകൾ ഇല്ല',
                            style: GoogleFonts.notoSansMalayalam(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'ആദ്യത്തെ യാത്ര ചേർക്കാൻ + ബട്ടൺ അമർത്തുക',
                            style: GoogleFonts.notoSansMalayalam(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        _buildFilterSection(),
                        Expanded(
                          child: Stack(
                            children: [
                              ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(16),
                            itemCount: _filteredTrips.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _filteredTrips.length) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final trip = _filteredTrips[index];
                              return TripAccordionCard(
                                trip: trip,
                                contracts: _contracts,
                                isExpanded: _expandedTripId == trip.id,
                                onToggle: () {
                                  setState(() {
                                    _expandedTripId = _expandedTripId == trip.id ? null : trip.id;
                                  });
                                },
                                onEdit: () => _showEditTripDialog(trip),
                                onDelete: () => _showDeleteConfirmation(trip),
                              );
                            },
                          ),
                          if (_isFiltering)
                            Container(
                              color: Colors.white.withValues(alpha: 0.8),
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'ഫിൽട്ടർ ചെയ്യുന്നു...',
                                        style: GoogleFonts.notoSansMalayalam(
                                          fontSize: 14,
                                          color: Color(0xFF4B39EF),
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
                      ],
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTripDialog(),
        backgroundColor: Color(0xFF4B39EF),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddTripDialog() {
    _showTripDialog();
  }

  void _showEditTripDialog(Trip trip) {
    _showTripDialog(trip: trip);
  }

  void _showTripDialog({Trip? trip}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripFormPage(
          trip: trip,
          contracts: _contracts,
          vehicles: _vehicles,
          drivers: _drivers,
          onSaved: () {
            _loadData();
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'യാത്ര നീക്കം ചെയ്യുക',
          style: GoogleFonts.notoSansMalayalam(fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${trip.clientName} യുടെ യാത്ര നീക്കം ചെയ്യാൻ ആഗ്രഹിക്കുന്നുണ്ടോ?',
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
                await _tripService.deleteTrip(trip.id);
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'യാത്ര നീക്കം ചെയ്തു',
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

  Widget _buildFilterSection() {
    if (!_showFilters) return SizedBox();
    
    return Container(
      padding: EdgeInsets.all(16),
      color: Color(0xFFF8FAFC),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedVehicleId,
                  decoration: InputDecoration(
                    labelText: 'വാഹനം',
                    labelStyle: GoogleFonts.notoSansMalayalam(fontSize: 12),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text('എല്ലാം', style: GoogleFonts.notoSansMalayalam(fontSize: 12))),
                    ..._vehicles.map((vehicle) => DropdownMenuItem(
                      value: vehicle.id,
                      child: Text(vehicle.vehicleNumber, style: GoogleFonts.notoSansMalayalam(fontSize: 12)),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedVehicleId = value;
                    });
                    _loadData(isFilter: true);
                  },
                ),
              ),
            ],
          ),
          if (_tabController.index == 0) ...[
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedContractId,
              decoration: InputDecoration(
                labelText: 'കരാർ',
                labelStyle: GoogleFonts.notoSansMalayalam(fontSize: 12),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text('എല്ലാം', style: GoogleFonts.notoSansMalayalam(fontSize: 12))),
                ..._contracts.map((contract) => DropdownMenuItem(
                  value: contract.id,
                  child: Text(contract.contractName, style: GoogleFonts.notoSansMalayalam(fontSize: 12)),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedContractId = value;
                });
                _loadData(isFilter: true);
              },
            ),
          ],
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedSalaryStatus,
            decoration: InputDecoration(
              labelText: 'ശമ്പള സ്ഥിതി',
              labelStyle: GoogleFonts.notoSansMalayalam(fontSize: 12),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              DropdownMenuItem(value: null, child: Text('എല്ലാം', style: GoogleFonts.notoSansMalayalam(fontSize: 12))),
              DropdownMenuItem(value: 'true', child: Text('ശമ്പളം നൽകി', style: GoogleFonts.notoSansMalayalam(fontSize: 12))),
              DropdownMenuItem(value: 'false', child: Text('ശമ്പളം നൽകിയില്ല', style: GoogleFonts.notoSansMalayalam(fontSize: 12))),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSalaryStatus = value;
              });
              _loadData(isFilter: true);
            },
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                      });
                      _loadData(isFilter: true);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Color(0xFF64748B)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _startDate != null 
                                ? AppDateUtils.formatDate(_startDate!) 
                                : 'ആരംഭ തീയതി',
                            style: GoogleFonts.notoSansMalayalam(
                              fontSize: 12,
                              color: _startDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        if (_startDate != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _startDate = null;
                              });
                              _loadData(isFilter: true);
                            },
                            child: Icon(Icons.clear, size: 16, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: _startDate ?? DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _endDate = picked;
                      });
                      _loadData(isFilter: true);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Color(0xFF64748B)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _endDate != null 
                                ? AppDateUtils.formatDate(_endDate!) 
                                : 'അവസാന തീയതി',
                            style: GoogleFonts.notoSansMalayalam(
                              fontSize: 12,
                              color: _endDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        if (_endDate != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _endDate = null;
                              });
                              _loadData(isFilter: true);
                            },
                            child: Icon(Icons.clear, size: 16, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: _clearFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
            child: Text('ഫിൽട്ടർ മായ്ക്കുക', style: GoogleFonts.notoSansMalayalam(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }



  void _clearFilters() {
    setState(() {
      _selectedVehicleId = null;
      _selectedContractId = null;
      _selectedSalaryStatus = null;
      _startDate = null;
      _endDate = null;
    });
    _loadData(isFilter: true);
  }
}

// Trip Form Page will be created next
class TripFormPage extends StatefulWidget {
  final Trip? trip;
  final List<Contract> contracts;
  final List<Vehicle> vehicles;
  final List<Driver> drivers;
  final VoidCallback onSaved;

  const TripFormPage({
    super.key,
    this.trip,
    required this.contracts,
    required this.vehicles,
    required this.drivers,
    required this.onSaved,
  });

  @override
  State<TripFormPage> createState() => _TripFormPageState();
}

class _TripFormPageState extends State<TripFormPage> {
  final TripService _tripService = TripService();
  final DriverService _driverService = DriverService();
  List<Driver> _drivers = [];

  String _tripType = 'contract';
  String? _selectedContractId;
  String? _selectedVehicleId;

  final _clientNameController = TextEditingController();
  final _clientMobileController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverSalaryController = TextEditingController();
  final _tripRateController = TextEditingController();
  final _startKmController = TextEditingController();
  final _endKmController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _tripDate = DateTime.now();
  bool _driverSalaryPaid = false;
  bool _isDriverSalaryManual = false;

  @override
  void initState() {
    super.initState();
    _drivers = List.from(widget.drivers);
    if (widget.trip != null) {
      _initializeWithTrip(widget.trip!);
    }
  }

  void _initializeWithTrip(Trip trip) {
    _tripType = trip.tripType;
    _selectedContractId = trip.contractId;
    _selectedVehicleId = trip.vehicleId;
    _clientNameController.text = trip.clientName;
    _clientMobileController.text = trip.clientMobile ?? '';
    _driverNameController.text = trip.driverName;
    _driverSalaryController.text = trip.driverSalary.toString();
    _tripRateController.text = trip.tripRate.toString();
    _startKmController.text = trip.startKm?.toString() ?? '';
    _endKmController.text = trip.endKm?.toString() ?? '';
    _notesController.text = trip.notes ?? '';
    _tripDate = trip.tripDate;
    _driverSalaryPaid = trip.driverSalaryPaid;
    _isDriverSalaryManual = trip.isDriverSalaryManual;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: Color(0xFF4B39EF),
        title: Text(
          widget.trip != null ? 'യാത്ര പുതുക്കുക' : 'യാത്ര ചേർക്കുക',
          style: GoogleFonts.notoSansMalayalam(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTripTypeSelector(),
            SizedBox(height: 16),
            if (_tripType == 'contract') ..._buildContractFields(),
            if (_tripType == 'savari') ..._buildSavariFields(),
            _buildCommonFields(),
            SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeSelector() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'യാത്രയുടെ തരം',
              style: GoogleFonts.notoSansMalayalam(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _tripType = 'contract';
                        _clearFields();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _tripType == 'contract' ? Color(0xFF4B39EF).withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _tripType == 'contract' ? Color(0xFF4B39EF) : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _tripType == 'contract' ? Color(0xFF4B39EF) : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: _tripType == 'contract'
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF4B39EF),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(width: 8),
                          Text('കരാർ', style: GoogleFonts.notoSansMalayalam()),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _tripType = 'savari';
                        _clearFields();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _tripType == 'savari' ? Color(0xFF4B39EF).withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _tripType == 'savari' ? Color(0xFF4B39EF) : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _tripType == 'savari' ? Color(0xFF4B39EF) : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: _tripType == 'savari'
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF4B39EF),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(width: 8),
                          Text('സവാരി', style: GoogleFonts.notoSansMalayalam()),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContractFields() {
    return [
      Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'കരാർ വിവരങ്ങൾ',
                style: GoogleFonts.notoSansMalayalam(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedContractId,
                decoration: InputDecoration(
                  labelText: 'കരാർ തിരഞ്ഞെടുക്കുക',
                  labelStyle: GoogleFonts.notoSansMalayalam(),
                  border: OutlineInputBorder(),
                ),
                items: _getActiveContracts().map((contract) {
                  return DropdownMenuItem<String>(
                    value: contract.id,
                    child: Text(
                      contract.contractName,
                      style: GoogleFonts.notoSansMalayalam(),
                    ),
                  );
                }).toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedContractId = value;
                  });
                  if (value != null) {
                    await _loadContractDetails(value);
                  }
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedVehicleId,
                decoration: InputDecoration(
                  labelText: 'വാഹനം തിരഞ്ഞെടുക്കുക',
                  labelStyle: GoogleFonts.notoSansMalayalam(),
                  border: OutlineInputBorder(),
                ),
                items: widget.vehicles.map((vehicle) {
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
                    _selectedVehicleId = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startKmController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'ആരംഭ കി.മീ',
                        labelStyle: GoogleFonts.notoSansMalayalam(),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.speed),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _endKmController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'അവസാന കി.മീ',
                        labelStyle: GoogleFonts.notoSansMalayalam(),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.speed),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ],
              ),
              if (_startKmController.text.isNotEmpty && _endKmController.text.isNotEmpty && _selectedContractId != null)
                _buildContractDistanceInfo(),
            ],
          ),
        ),
      ),
      SizedBox(height: 16),
    ];
  }

  List<Widget> _buildSavariFields() {
    return [
      Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'സവാരി വിവരങ്ങൾ',
                style: GoogleFonts.notoSansMalayalam(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedVehicleId,
                decoration: InputDecoration(
                  labelText: 'വാഹനം തിരഞ്ഞെടുക്കുക',
                  labelStyle: GoogleFonts.notoSansMalayalam(),
                  border: OutlineInputBorder(),
                ),
                items: widget.vehicles.map((vehicle) {
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
                    _selectedVehicleId = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startKmController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'ആരംഭ കി.മീ',
                        labelStyle: GoogleFonts.notoSansMalayalam(),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.speed),
                      ),
                      onChanged: (value) => _calculateSavariRate(),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _endKmController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'അവസാന കി.മീ',
                        labelStyle: GoogleFonts.notoSansMalayalam(),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.speed),
                      ),
                      onChanged: (value) => _calculateSavariRate(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Rate breakup display
              if (_startKmController.text.isNotEmpty && 
                  _endKmController.text.isNotEmpty && 
                  _selectedVehicleId != null) 
                _buildRateBreakup(),
            ],
          ),
        ),
      ),
      SizedBox(height: 16),
    ];
  }

  Widget _buildRateBreakup() {
    final startKm = double.tryParse(_startKmController.text) ?? 0;
    final endKm = double.tryParse(_endKmController.text) ?? 0;
    final distance = endKm - startKm;
    
    if (distance <= 0 || _selectedVehicleId == null) return SizedBox();
    
    final vehicle = widget.vehicles.firstWhere((v) => v.id == _selectedVehicleId);
    final fixedRate = vehicle.fixedRateFor5Km;
    final perKmRate = vehicle.perKmRate;
    final additionalKm = distance > 5 ? distance - 5 : 0;
    final additionalAmount = additionalKm * perKmRate;
    final totalRate = distance <= 5 ? fixedRate : fixedRate + additionalAmount;
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate, size: 16, color: Color(0xFF1D4ED8)),
              SizedBox(width: 8),
              Text(
                'നിരക്ക് വിവരണം',
                style: GoogleFonts.notoSansMalayalam(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D4ED8),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'മൊത്തം ദൂരം: ${distance.toStringAsFixed(1)} കി.മീ',
            style: GoogleFonts.notoSansMalayalam(
              fontSize: 12,
              color: Color(0xFF1E3A8A),
            ),
          ),
          SizedBox(height: 4),
          if (distance <= 5) ...[
            Text(
              '5 കി.മീ വരെ നിശ്ചിത നിരക്ക്: ₹${fixedRate.toStringAsFixed(0)}',
              style: GoogleFonts.notoSansMalayalam(
                fontSize: 12,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ] else ...[
            Text(
              '5 കി.മീ വരെ നിശ്ചിത നിരക്ക്: ₹${fixedRate.toStringAsFixed(0)}',
              style: GoogleFonts.notoSansMalayalam(
                fontSize: 12,
                color: Color(0xFF1E3A8A),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'അധിക ${additionalKm.toStringAsFixed(1)} കി.മീ × ₹${perKmRate.toStringAsFixed(0)} = ₹${additionalAmount.toStringAsFixed(0)}',
              style: GoogleFonts.notoSansMalayalam(
                fontSize: 12,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ],
          Divider(color: Color(0xFFBFDBFE)),
          Text(
            'മൊത്തം നിരക്ക്: ₹${totalRate.toStringAsFixed(0)}',
            style: GoogleFonts.notoSansMalayalam(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonFields() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'പൊതു വിവരങ്ങൾ',
              style: GoogleFonts.notoSansMalayalam(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _clientNameController,
              decoration: InputDecoration(
                labelText: 'ഉപഭോക്താവിന്റെ പേര്',
                labelStyle: GoogleFonts.notoSansMalayalam(),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _clientMobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'ഉപഭോക്താവിന്റെ മോബൈൽ നംബർ',
                labelStyle: GoogleFonts.notoSansMalayalam(),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'ഡ്രൈവർ തിരഞ്ഞെടുക്കുക',
                      labelStyle: GoogleFonts.notoSansMalayalam(),
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'new',
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 16, color: Color(0xFF4B39EF)),
                            SizedBox(width: 8),
                            Text('പുതിയത് ചേർക്കുക', style: GoogleFonts.notoSansMalayalam(fontSize: 14)),
                          ],
                        ),
                      ),
                      ..._drivers.map((driver) => DropdownMenuItem(
                        value: driver.id,
                        child: Text('${driver.name} - ${driver.phone}', style: GoogleFonts.notoSansMalayalam(fontSize: 14)),
                      )),
                    ],
                    onChanged: (value) async {
                      if (value == 'new') {
                        await _showAddDriverDialog();
                      } else if (value != null) {
                        final driver = _drivers.firstWhere((d) => d.id == value);
                        setState(() {
                          _driverNameController.text = driver.name;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _driverNameController,
                    decoration: InputDecoration(
                      labelText: 'പേര്',
                      labelStyle: GoogleFonts.notoSansMalayalam(),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _tripRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'യാത്രാ നിരക്ക് (₹)',
                labelStyle: GoogleFonts.notoSansMalayalam(),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              onChanged: (value) => setState(() {}),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _driverSalaryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ഡ്രൈവർ ശമ്പളം (₹)',
                      labelStyle: GoogleFonts.notoSansMalayalam(),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance_wallet),
                      suffixIcon: _isDriverSalaryManual 
                        ? Icon(Icons.edit, color: Colors.orange, size: 20)
                        : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isDriverSalaryManual = true;
                      });
                    },
                  ),
                ),
                if (_isDriverSalaryManual) ...[
                  SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isDriverSalaryManual = false;
                        _calculateDriverSalary();
                      });
                    },
                    icon: Icon(Icons.refresh, color: Colors.blue),
                    tooltip: 'ഓടോ കണക്കുലേഷൻ',
                  ),
                ],
              ],
            ),
            if (_isDriverSalaryManual) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ശമ്പളം മാനുവൽ നൽകിയത്',
                        style: GoogleFonts.notoSansMalayalam(
                          fontSize: 12,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text(
                'ഡ്രൈവർ ശമ്പളം നൽകി',
                style: GoogleFonts.notoSansMalayalam(),
              ),
              value: _driverSalaryPaid,
              onChanged: (value) {
                setState(() {
                  _driverSalaryPaid = value ?? false;
                });
              },
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _tripDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _tripDate = picked;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'യാത്രാ തീയതി',
                      style: GoogleFonts.notoSansMalayalam(fontSize: 16),
                    ),
                    Text(
                      AppDateUtils.formatDate(_tripDate),
                      style: GoogleFonts.notoSansMalayalam(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Owner take home display
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, size: 16, color: Color(0xFF059669)),
                  SizedBox(width: 8),
                  Text(
                    'ഉടമയുടെ വരുമാനം:',
                    style: GoogleFonts.notoSansMalayalam(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF059669),
                    ),
                  ),
                  Spacer(),
                  Text(
                    '₹${_calculateOwnerTakeHome().toStringAsFixed(0)}',
                    style: GoogleFonts.notoSansMalayalam(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF047857),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'കുറിപ്പ് (ഓപ്ഷണൽ)',
                labelStyle: GoogleFonts.notoSansMalayalam(),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTrip,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4B39EF),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          widget.trip != null ? 'പുതുക്കുക' : 'സേവ് ചെയ്യുക',
          style: GoogleFonts.notoSansMalayalam(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _clearFields() {
    _selectedContractId = null;
    _selectedVehicleId = null;
    _clientNameController.clear();
    _clientMobileController.clear();
    _driverNameController.clear();
    _driverSalaryController.clear();
    _tripRateController.clear();
    _startKmController.clear();
    _endKmController.clear();
    _isDriverSalaryManual = false;
  }

  List<Contract> _getActiveContracts() {
    final now = DateTime.now();
    List<Contract> activeContracts = widget.contracts.where((contract) => 
      contract.contractEndDate.isAfter(now)
    ).toList();
    
    // If editing a trip with an expired contract, include that contract in the list
    if (widget.trip != null && widget.trip!.contractId != null) {
      try {
        final existingContract = widget.contracts.firstWhere((c) => c.id == widget.trip!.contractId);
        if (!activeContracts.any((c) => c.id == existingContract.id)) {
          activeContracts.add(existingContract);
        }
      } catch (e) {
        // Contract not found, ignore
      }
    }
    
    return activeContracts;
  }

  Future<void> _loadContractDetails(String contractId) async {
    try {
      final contract = widget.contracts.firstWhere((c) => c.id == contractId);
      setState(() {
        _selectedVehicleId = contract.vehicleId;
        _tripRateController.text = contract.rate.toString();
        _clientNameController.text = contract.contractName;
        if (contract.contactPhone != null && contract.contactPhone!.isNotEmpty) {
          _clientMobileController.text = contract.contactPhone!;
        }
        if (!_isDriverSalaryManual) {
          _calculateDriverSalary();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'കരാർ വിവരങ്ങൾ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല',
            style: GoogleFonts.notoSansMalayalam(),
          ),
        ),
      );
    }
  }

  void _calculateSavariRate() {
    if (_startKmController.text.isNotEmpty &&
        _endKmController.text.isNotEmpty &&
        _selectedVehicleId != null) {
      final startKm = double.tryParse(_startKmController.text) ?? 0;
      final endKm = double.tryParse(_endKmController.text) ?? 0;
      if (endKm > startKm) {
        final distance = endKm - startKm;
        final selectedVehicle = widget.vehicles.firstWhere((v) => v.id == _selectedVehicleId);
        final rate = _tripService.calculateSavariRate(
          distance, 
          selectedVehicle.fixedRateFor5Km, 
          selectedVehicle.perKmRate
        );
        setState(() {
          _tripRateController.text = rate.toStringAsFixed(2);
        });
        if (!_isDriverSalaryManual) {
          _calculateDriverSalary();
        }
      }
    }
  }

  void _calculateDriverSalary() {
    if (_tripRateController.text.isNotEmpty && !_isDriverSalaryManual) {
      final tripRate = double.tryParse(_tripRateController.text) ?? 0;
      final driverSalary = _tripService.calculateDriverSalary(tripRate);
      setState(() {
        _driverSalaryController.text = driverSalary.toStringAsFixed(2);
      });
    }
  }
  
  double _calculateOwnerTakeHome() {
    final tripRate = double.tryParse(_tripRateController.text) ?? 0;
    final driverSalary = double.tryParse(_driverSalaryController.text) ?? 0;
    return tripRate - driverSalary;
  }

  Future<void> _saveTrip() async {
    if (!_validateForm()) return;

    try {
      final trip = Trip(
        id: widget.trip?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        tripType: _tripType,
        contractId: _tripType == 'contract' ? _selectedContractId : null,
        vehicleId: _selectedVehicleId!,
        clientName: _clientNameController.text,
        clientMobile: _clientMobileController.text.isEmpty ? null : _clientMobileController.text,
        driverName: _driverNameController.text,
        driverSalary: double.parse(_driverSalaryController.text),
        driverSalaryPaid: _driverSalaryPaid,
        isDriverSalaryManual: _isDriverSalaryManual,
        tripRate: double.parse(_tripRateController.text),
        startKm: double.tryParse(_startKmController.text),
        endKm: double.tryParse(_endKmController.text),
        distance: _startKmController.text.isNotEmpty &&
                _endKmController.text.isNotEmpty
            ? (double.tryParse(_endKmController.text) ?? 0) -
                (double.tryParse(_startKmController.text) ?? 0)
            : null,
        tripDate: _tripDate,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        userId: 'temp', // Will be set by backend from token
        createdAt: widget.trip?.createdAt ?? DateTime.now(),
        fixedRateUsed: _tripType == 'savari' && _selectedVehicleId != null
            ? widget.vehicles.firstWhere((v) => v.id == _selectedVehicleId).fixedRateFor5Km
            : null,
        perKmRateUsed: _tripType == 'savari' && _selectedVehicleId != null
            ? widget.vehicles.firstWhere((v) => v.id == _selectedVehicleId).perKmRate
            : null,
        additionalKm: _tripType == 'savari' &&
                _startKmController.text.isNotEmpty &&
                _endKmController.text.isNotEmpty
            ? _calculateAdditionalKm()
            : null,
        ownerTakeHome: _calculateOwnerTakeHome(),
      );

      if (widget.trip != null) {
        await _tripService.updateTrip(trip);
      } else {
        await _tripService.addTrip(trip);
      }

      widget.onSaved();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.trip != null ? 'യാത്ര പുതുക്കി' : 'യാത്ര ചേർത്തു',
            style: GoogleFonts.notoSansMalayalam(),
          ),
        ),
      );
    } catch (e) {
      print('Trip save error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'എന്തോ തെറ്റ് സംഭവിച്ചു: $e',
            style: GoogleFonts.notoSansMalayalam(),
          ),
        ),
      );
    }
  }

  bool _validateForm() {
    if (_tripType == 'contract' && _selectedContractId == null) {
      _showError('കരാർ തിരഞ്ഞെടുക്കുക');
      return false;
    }
    if (_selectedVehicleId == null) {
      _showError('വാഹനം തിരഞ്ഞെടുക്കുക');
      return false;
    }
    if (_clientNameController.text.isEmpty) {
      _showError('ഉപഭോക്താവിന്റെ പേര് നൽകുക');
      return false;
    }
    if (_driverNameController.text.isEmpty) {
      _showError('ഡ്രൈവറുടെ പേര് നൽകുക');
      return false;
    }
    if (_tripRateController.text.isEmpty) {
      _showError('യാത്രാ നിരക്ക് നൽകുക');
      return false;
    }
    if (_tripType == 'savari') {
      if (_startKmController.text.isEmpty || _endKmController.text.isEmpty) {
        _showError('കിലോമീറ്റർ റീഡിംഗ് നൽകുക');
        return false;
      }
      final startKm = double.tryParse(_startKmController.text) ?? 0;
      final endKm = double.tryParse(_endKmController.text) ?? 0;
      if (endKm <= startKm) {
        _showError('അവസാന കി.മീ ആരംഭ കി.മീ യേക്കാൾ കൂടുതലായിരിക്കണം');
        return false;
      }
    }
    return true;
  }

  double _calculateAdditionalKm() {
    final startKm = double.tryParse(_startKmController.text) ?? 0;
    final endKm = double.tryParse(_endKmController.text) ?? 0;
    final distance = endKm - startKm;
    return distance > 5 ? distance - 5 : 0;
  }

  Widget _buildContractDistanceInfo() {
    final startKm = double.tryParse(_startKmController.text) ?? 0;
    final endKm = double.tryParse(_endKmController.text) ?? 0;
    final distance = endKm - startKm;
    
    if (distance <= 0 || _selectedContractId == null) return SizedBox();
    
    final contract = widget.contracts.firstWhere((c) => c.id == _selectedContractId);
    final isExceeded = distance > contract.averageDistance;
    
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isExceeded ? Color(0xFFFEF2F2) : Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isExceeded ? Color(0xFFFECACA) : Color(0xFFBBF7D0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExceeded ? Icons.warning : Icons.check_circle,
                size: 16,
                color: isExceeded ? Color(0xFFDC2626) : Color(0xFF059669),
              ),
              SizedBox(width: 8),
              Text(
                'മൊത്തം ദൂരം: ${distance.toStringAsFixed(1)} കി.മീ',
                style: GoogleFonts.notoSansMalayalam(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isExceeded ? Color(0xFFDC2626) : Color(0xFF059669),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'കരാർ ശരാശരി: ${contract.averageDistance.toStringAsFixed(1)} കി.മീ',
            style: GoogleFonts.notoSansMalayalam(
              fontSize: 12,
              color: isExceeded ? Color(0xFFB91C1C) : Color(0xFF047857),
            ),
          ),
          if (isExceeded) ...[
            SizedBox(height: 4),
            Text(
              'അധിക ദൂരം: ${(distance - contract.averageDistance).toStringAsFixed(1)} കി.മീ',
              style: GoogleFonts.notoSansMalayalam(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFB91C1C),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showAddDriverDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('പുതിയ ഡ്രൈവർ ചേർക്കുക', style: GoogleFonts.notoSansMalayalam(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'പേര്',
                labelStyle: GoogleFonts.notoSansMalayalam(),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'ഫോൺ നമ്പർ',
                labelStyle: GoogleFonts.notoSansMalayalam(),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('റദ്ദാക്കുക', style: GoogleFonts.notoSansMalayalam()),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                try {
                  final newDriver = Driver(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    phone: phoneController.text,
                    userId: 'temp',
                    createdAt: DateTime.now(),
                  );
                  final savedDriver = await _driverService.addDriver(newDriver);
                  setState(() {
                    _drivers.add(savedDriver);
                    _driverNameController.text = savedDriver.name;
                  });
                  Navigator.pop(context, true);
                } catch (e) {
                  _showError('ഡ്രൈവർ ചേർക്കാൻ കഴിഞ്ഞില്ല');
                }
              }
            },
            child: Text('ചേർക്കുക', style: GoogleFonts.notoSansMalayalam()),
          ),
        ],
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ഡ്രൈവർ ചേർത്തു', style: GoogleFonts.notoSansMalayalam())),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.notoSansMalayalam()),
        backgroundColor: Colors.red,
      ),
    );
  }
}
