import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/contract.dart';
import '../services/contract_service.dart';
import '../services/report_service.dart';
import '../utils/date_utils.dart';
import 'pdf_viewer_page.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final ContractService _contractService = ContractService();
  final ReportService _reportService = ReportService();
  
  List<Contract> _contracts = [];
  bool _isLoading = true;
  String? _selectedContractId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadContracts();
  }

  Future<void> _loadContracts() async {
    setState(() => _isLoading = true);
    try {
      final contracts = await _contractService.getAllContracts();
      setState(() {
        _contracts = contracts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePDF() async {
    if (_selectedContractId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('കരാർ തിരഞ്ഞെടുക്കുക', style: GoogleFonts.notoSansMalayalam())),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final pdfBytes = await _reportService.generateContractBillingPDF(
        _selectedContractId!,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      setState(() => _isGenerating = false);
      if (!mounted) return;
      
      // Show preview dialog
      _showPDFPreviewDialog(pdfBytes);
    } catch (e) {
      setState(() => _isGenerating = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('എന്തോ തെറ്റ് സംഭവിച്ചു', style: GoogleFonts.notoSansMalayalam())),
      );
    }
  }

  void _showPDFPreviewDialog(Uint8List pdfBytes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ബില്ലിംഗ് റിപ്പോർട്ട്', style: GoogleFonts.notoSansMalayalam(fontWeight: FontWeight.w600)),
        content: Text(
          'PDF വിജയകരമായി ജനറേറ്റ് ചെയ്തു. നിങ്ങൾക്ക് ഇത് കാണുകയോ ഡൗൺലോഡ് ചെയ്യുകയോ ചെയ്യാം.',
          style: GoogleFonts.notoSansMalayalam(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('റദ്ദാക്കുക', style: GoogleFonts.notoSansMalayalam()),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _reportService.downloadPDF(
                  pdfBytes,
                  'contract_billing_${DateTime.now().millisecondsSinceEpoch}.pdf',
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('PDF ഡൗൺലോഡ് ചെയ്തു', style: GoogleFonts.notoSansMalayalam())),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ഡൗൺലോഡ് പരാജയപ്പെട്ടു', style: GoogleFonts.notoSansMalayalam())),
                );
              }
            },
            icon: const Icon(Icons.download, color: Colors.white),
            label: Text('ഡൗൺലോഡ്', style: GoogleFonts.notoSansMalayalam(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _viewPDF(pdfBytes);
            },
            icon: const Icon(Icons.visibility, color: Colors.white),
            label: Text('കാണുക', style: GoogleFonts.notoSansMalayalam(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4B39EF)),
          ),
        ],
      ),
    );
  }

  void _viewPDF(Uint8List pdfBytes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(pdfBytes: pdfBytes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B39EF),
        title: Text(
          'സംഗ്രഹങ്ങൾ',
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    'കരാർ ബില്ലിംഗ് റിപ്പോർട്ട്',
                    'ക്ലയന്റിന് സമർപ്പിക്കാൻ കരാർ ബില്ലിംഗ് PDF ജനറേറ്റ് ചെയ്യുക',
                    Icons.picture_as_pdf,
                    const Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 24),
                  _buildContractSelector(),
                  const SizedBox(height: 16),
                  _buildDateRangeSelector(),
                  const SizedBox(height: 24),
                  _buildGenerateButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansMalayalam(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSansMalayalam(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'കരാർ തിരഞ്ഞെടുക്കുക',
            style: GoogleFonts.notoSansMalayalam(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedContractId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: Text('കരാർ തിരഞ്ഞെടുക്കുക', style: GoogleFonts.notoSansMalayalam()),
            items: _contracts.map((contract) {
              return DropdownMenuItem(
                value: contract.id,
                child: Text(
                  contract.contractName,
                  style: GoogleFonts.notoSansMalayalam(),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedContractId = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'കാലാവധി (ഓപ്ഷണൽ)',
            style: GoogleFonts.notoSansMalayalam(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
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
                      setState(() => _startDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _startDate != null ? AppDateUtils.formatDate(_startDate!) : 'ആരംഭ തീയതി',
                            style: GoogleFonts.notoSansMalayalam(
                              fontSize: 13,
                              color: _startDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                      setState(() => _endDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _endDate != null ? AppDateUtils.formatDate(_endDate!) : 'അവസാന തീയതി',
                            style: GoogleFonts.notoSansMalayalam(
                              fontSize: 13,
                              color: _endDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_startDate != null || _endDate != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _startDate = null;
                  _endDate = null;
                });
              },
              icon: const Icon(Icons.clear, size: 16),
              label: Text('തീയതി മായ്ക്കുക', style: GoogleFonts.notoSansMalayalam(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isGenerating ? null : _generatePDF,
        icon: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.picture_as_pdf, color: Colors.white),
        label: Text(
          _isGenerating ? 'ജനറേറ്റ് ചെയ്യുന്നു...' : 'PDF ജനറേറ്റ് ചെയ്യുക',
          style: GoogleFonts.notoSansMalayalam(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
