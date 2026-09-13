import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../services/app_state.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/role_switcher_sheet.dart';

class DeliveryProfileScreen extends StatefulWidget {
  final AppState appState;

  const DeliveryProfileScreen({super.key, required this.appState});

  @override
  State<DeliveryProfileScreen> createState() => _DeliveryProfileScreenState();
}

class _DeliveryProfileScreenState extends State<DeliveryProfileScreen> {
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
            SizedBox(width: 8),
            Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of AgriConnect Driver? You will need your phone number to sign back in.',
          style: TextStyle(fontSize: 13, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              widget.appState.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('LOG OUT', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        final driver = widget.appState.currentUser;
        final driverName = driver.name.isNotEmpty && driver.name != 'New User'
            ? driver.name
            : 'Shiva Regonda';
        final phone = driver.phoneNumber.isNotEmpty
            ? driver.phoneNumber
            : '+91 70000 00001';
        final vehicle = driver.vehicleType ?? 'EV Cargo Scooter (300kg)';
        final plate = driver.vehicleNumber ?? 'TS 07 EA 4821';
        final upiId = driver.upiId ?? 'driver@upi';
        final hub = driver.fpoCluster ?? 'Ranga Reddy Organic Producers FPO Hub';
        final isOnline = widget.appState.isDriverOnline;
        final completedTrips = widget.appState.driverCompletedTripsToday;
        final todayEarnings = widget.appState.driverEarningsToday;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8F7),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver Identity Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8E4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 34,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                  child: const Icon(
                                    Icons.electric_moped_rounded,
                                    size: 38,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: isOnline ? const Color(0xFF4CAF50) : Colors.grey,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          driverName,
                                          style: AppTypography.headlineSmall.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    phone,
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Verified Delivery Partner',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 14),
                        // Quick Stats Row
                        Row(
                          children: [
                            _buildDriverStat(
                              '4.95 ⭐',
                              'Customer Rating',
                              subtitle: '82 reviews',
                              color: const Color(0xFFF59E0B),
                            ),
                            _buildDriverDivider(),
                            _buildDriverStat(
                              '$completedTrips Today',
                              'Fulfilled Trips',
                              subtitle: '142 all-time',
                              color: AppColors.primary,
                            ),
                            _buildDriverDivider(),
                            _buildDriverStat(
                              '₹${todayEarnings.toInt()}',
                              'Today Earnings',
                              subtitle: '0% fee',
                              color: const Color(0xFF15803D),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Vehicle & EV Fleet Card
                  _buildSectionHeader(Icons.electric_moped_outlined, 'Vehicle & Fleet Specifications'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8E4)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.two_wheeler, 'Vehicle Model', vehicle),
                        const Divider(height: 16),
                        _buildDetailRow(Icons.pin, 'Registration Plate', plate, isBadge: true),
                        const Divider(height: 16),
                        _buildDetailRow(Icons.battery_charging_full, 'Battery State of Charge', '82% • 65 km Range', badgeColor: Colors.green),
                        const Divider(height: 16),
                        _buildDetailRow(Icons.fitness_center, 'Max Cargo Payload', '300 kg (4 Insulated Crates)'),
                        const Divider(height: 16),
                        _buildDetailRow(Icons.eco_rounded, 'Environmental Classification', 'Zero-Emission Green EV', badgeColor: AppColors.primary),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logistics Hub Card
                  _buildSectionHeader(Icons.hub_outlined, 'Assigned Aggregation Hub'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8E4)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.store_mall_directory_rounded, 'Primary Hub', hub),
                        const Divider(height: 16),
                        _buildDetailRow(Icons.local_shipping_outlined, 'Designated Dock', 'Dock #2 (Cold Storage Cargo)'),
                        const Divider(height: 16),
                        _buildDetailRow(Icons.radar_rounded, 'Coverage Radius', '15 km Local Consumer Delivery Zone'),
                        const Divider(height: 16),
                        _buildDetailRow(Icons.support_agent_rounded, 'Hub Dispatcher', '+91 94400 12345 (Dock Lead)'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Direct Jan Dhan / Bank Settlement Card
                  _buildSectionHeader(Icons.account_balance_outlined, 'Direct Settlement & Payouts'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8E4)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.qr_code_2_rounded, 'Jan Dhan UPI VPA', upiId, isBadge: true),
                        const Divider(height: 16),
                        _buildDetailRow(Icons.account_balance, 'Linked Account', 'State Bank of India (•••• 9812)'),
                        const Divider(height: 16),
                        _buildDetailRow(Icons.percent_rounded, 'Platform Fee', '0% Commission (100% to Driver)', badgeColor: Colors.green),
                        const Divider(height: 16),
                        _buildDetailRow(Icons.speed_rounded, 'Settlement Speed', 'Instant per-trip OTP verification'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // KYC Documents Card
                  _buildSectionHeader(Icons.assignment_turned_in_outlined, 'KYC & License Documentation'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8E4)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.badge, 'Commercial Driving License', 'TS-2022-099412 (Verified)', badgeColor: AppColors.primary),
                        const Divider(height: 16),
                        _buildDetailRow(Icons.credit_card, 'Aadhaar Identity', '•••• •••• 4921 (UIDAI Verified)', badgeColor: AppColors.primary),
                        const Divider(height: 16),
                        _buildDetailRow(Icons.health_and_safety_outlined, 'Cargo Hygiene Training', 'Certified for Fresh Produce Transit'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Demo Switcher
                  PrimaryButton(
                    text: 'SWITCH ROLE FOR DEMO',
                    icon: Icons.swap_horiz_rounded,
                    onPressed: () => RoleSwitcherSheet.show(context, widget.appState),
                  ),

                  const SizedBox(height: 12),

                  // Logout Button
                  SecondaryButton(
                    text: 'LOG OUT OF DRIVER ACCOUNT',
                    icon: Icons.logout_rounded,
                    borderColor: AppColors.error,
                    textColor: AppColors.error,
                    onPressed: () => _confirmLogout(context),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverStat(String value, String label, {required String subtitle, required Color color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverDivider() {
    return Container(width: 1, height: 36, color: Colors.grey.shade200);
  }

  Widget _buildDetailRow(IconData icon, String title, String value, {bool isBadge = false, Color? badgeColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              if (isBadge || badgeColor != null)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? AppColors.primary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: badgeColor ?? AppColors.primary,
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
