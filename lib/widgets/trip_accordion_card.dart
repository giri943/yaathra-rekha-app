import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trip.dart';
import '../models/contract.dart';
import '../utils/date_utils.dart';

class TripAccordionCard extends StatelessWidget {
  final Trip trip;
  final List<Contract> contracts;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TripAccordionCard({
    super.key,
    required this.trip,
    required this.contracts,
    required this.isExpanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
          if (!isExpanded) _buildSimpleView(),
          if (isExpanded) _buildDetailedView(),
        ],
      ),
    );
  }

  Widget _buildSimpleView() {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  trip.tripType == 'contract' ? Icons.assignment : Icons.local_taxi,
                  color: Color(0xFF4B39EF),
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.clientName,
                    style: GoogleFonts.notoSansMalayalam(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.expand_more, color: Colors.grey),
              ],
            ),
            SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, 'തീയതി', AppDateUtils.formatDate(trip.tripDate)),
            SizedBox(height: 8),
            _buildInfoRow(Icons.directions_car, 'വാഹനം', trip.vehicle?.vehicleNumber ?? 'N/A'),
            SizedBox(height: 8),
            _buildInfoRow(Icons.person_pin, 'ഡ്രൈവർ', trip.driverName),
            SizedBox(height: 8),
            _buildInfoRow(
              trip.driverSalaryPaid ? Icons.check_circle : Icons.cancel,
              'ശമ്പളം',
              trip.driverSalaryPaid ? 'നൽകി' : 'നൽകിയില്ല',
              color: trip.driverSalaryPaid ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedView() {
    final distance = trip.distance ?? 
      (trip.endKm != null && trip.startKm != null 
        ? trip.endKm! - trip.startKm! 
        : null);
    
    bool isExceeded = false;
    double? averageDistance;
    
    if (trip.tripType == 'contract' && trip.contractId != null) {
      if (trip.contract != null) {
        averageDistance = trip.contract!.averageDistance;
      } else {
        try {
          final contract = contracts.firstWhere((c) => c.id == trip.contractId);
          averageDistance = contract.averageDistance;
        } catch (e) {}
      }
      if (averageDistance != null && distance != null) {
        isExceeded = distance > averageDistance;
      }
    }
    
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: trip.tripType == 'contract' 
                  ? [Color(0xFF4B39EF), Color(0xFF6366F1)]
                  : [Color(0xFF10B981), Color(0xFF059669)],
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
                    trip.tripType == 'contract' ? Icons.assignment : Icons.local_taxi,
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
                        trip.tripType == 'contract' ? 'കരാർ യാത്ര' : 'സവാരി യാത്ര',
                        style: GoogleFonts.notoSansMalayalam(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        AppDateUtils.formatDate(trip.tripDate),
                        style: GoogleFonts.notoSansMalayalam(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trip.driverSalaryPaid ? Color(0xFF10B981) : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trip.driverSalaryPaid ? 'ശമ്പളം നൽകി' : 'ശമ്പളം നൽകിയില്ല',
                    style: GoogleFonts.notoSansMalayalam(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.expand_less, color: Colors.white),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildInfoCard(Icons.person, 'ഉപഭോക്താവ്', trip.clientName, trip.clientMobile)),
                    SizedBox(width: 12),
                    Expanded(child: _buildInfoCard(Icons.directions_car, 'വാഹനം', trip.vehicle?.vehicleNumber ?? 'N/A', trip.vehicle?.model)),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildInfoCard(Icons.person_pin, 'ഡ്രൈവർ', trip.driverName, '₹${trip.driverSalary.toStringAsFixed(0)}${trip.isDriverSalaryManual ? ' (മാനുവൽ)' : ''}')),
                    SizedBox(width: 12),
                    Expanded(child: _buildInfoCard(Icons.currency_rupee, 'യാത്രാ നിരക്ക്', '₹${trip.tripRate.toStringAsFixed(0)}', trip.tripType == 'savari' && trip.distance != null ? '${trip.distance!.toStringAsFixed(1)} കി.മീ' : null)),
                  ],
                ),
                SizedBox(height: 12),
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
                      Text('ഉടമയുടെ വരുമാനം:', style: GoogleFonts.notoSansMalayalam(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF059669))),
                      Spacer(),
                      Text('₹${trip.ownerTakeHome.toStringAsFixed(0)}', style: GoogleFonts.notoSansMalayalam(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF047857))),
                    ],
                  ),
                ),
                if (trip.startKm != null && trip.endKm != null) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isExceeded ? Color(0xFFFEF2F2) : Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isExceeded ? Color(0xFFFECACA) : Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(isExceeded ? Icons.warning : Icons.speed, size: 16, color: isExceeded ? Color(0xFFDC2626) : Color(0xFF64748B)),
                            SizedBox(width: 8),
                            Text('കി.മീ വിവരം:', style: GoogleFonts.notoSansMalayalam(fontSize: 12, color: isExceeded ? Color(0xFFDC2626) : Color(0xFF64748B), fontWeight: FontWeight.w500)),
                            Spacer(),
                            Text('${trip.startKm!.toStringAsFixed(0)} → ${trip.endKm!.toStringAsFixed(0)}', style: GoogleFonts.notoSansMalayalam(fontSize: 12, fontWeight: FontWeight.w600, color: isExceeded ? Color(0xFFB91C1C) : Color(0xFF1E293B))),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text('മൊത്തം ദൂരം: ${distance?.toStringAsFixed(1) ?? '0.0'} കി.മീ', style: GoogleFonts.notoSansMalayalam(fontSize: 11, fontWeight: FontWeight.w600, color: isExceeded ? Color(0xFFDC2626) : Color(0xFF1E293B))),
                            if (averageDistance != null) ...[
                              Spacer(),
                              Text('ശരാശരി: ${averageDistance.toStringAsFixed(1)} കി.മീ', style: GoogleFonts.notoSansMalayalam(fontSize: 10, color: isExceeded ? Color(0xFFB91C1C) : Color(0xFF64748B))),
                            ],
                          ],
                        ),
                        if (isExceeded && averageDistance != null && distance != null) ...[
                          SizedBox(height: 4),
                          Text('അധിക ദൂരം: ${(distance - averageDistance).toStringAsFixed(1)} കി.മീ', style: GoogleFonts.notoSansMalayalam(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFFDC2626))),
                        ],
                      ],
                    ),
                  ),
                ],
                if (trip.tripType == 'savari' && trip.fixedRateUsed != null && trip.perKmRateUsed != null) ...[
                  SizedBox(height: 12),
                  Container(
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
                            Icon(Icons.calculate, size: 14, color: Color(0xFF1D4ED8)),
                            SizedBox(width: 6),
                            Text('നിരക്ക് വിവരണം', style: GoogleFonts.notoSansMalayalam(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1D4ED8))),
                          ],
                        ),
                        SizedBox(height: 6),
                        if (trip.distance != null && trip.distance! <= 5) ...[
                          Text('5 കി.മീ വരെ: ₹${trip.fixedRateUsed!.toStringAsFixed(0)}', style: GoogleFonts.notoSansMalayalam(fontSize: 10, color: Color(0xFF1E3A8A))),
                        ] else if (trip.distance != null && trip.additionalKm != null) ...[
                          Text('5 കി.മീ വരെ: ₹${trip.fixedRateUsed!.toStringAsFixed(0)}', style: GoogleFonts.notoSansMalayalam(fontSize: 10, color: Color(0xFF1E3A8A))),
                          Text('അധിക ${trip.additionalKm!.toStringAsFixed(1)} കി.മീ: ₹${(trip.additionalKm! * trip.perKmRateUsed!).toStringAsFixed(0)}', style: GoogleFonts.notoSansMalayalam(fontSize: 10, color: Color(0xFF1E3A8A))),
                        ],
                      ],
                    ),
                  ),
                ],
                if (trip.notes != null && trip.notes!.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note, size: 16, color: Color(0xFFD97706)),
                        SizedBox(width: 8),
                        Expanded(child: Text(trip.notes!, style: GoogleFonts.notoSansMalayalam(fontSize: 12, color: Color(0xFF92400E)))),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onEdit,
                        icon: Icon(Icons.edit, size: 18),
                        label: Text('പുതുക്കുക', style: GoogleFonts.notoSansMalayalam(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4B39EF),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onDelete,
                        icon: Icon(Icons.delete, size: 18),
                        label: Text('നീക്കം ചെയ്യുക', style: GoogleFonts.notoSansMalayalam(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Color(0xFF64748B)),
        SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.notoSansMalayalam(fontSize: 12, color: Color(0xFF64748B))),
        Text(value, style: GoogleFonts.notoSansMalayalam(fontSize: 12, fontWeight: FontWeight.w600, color: color ?? Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String subtitle, String? extra) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Text(title, style: GoogleFonts.notoSansMalayalam(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
            ],
          ),
          SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.notoSansMalayalam(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (extra != null) ...[
            SizedBox(height: 2),
            Text(extra, style: GoogleFonts.notoSansMalayalam(fontSize: 11, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}
