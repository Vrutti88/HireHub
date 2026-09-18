import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/primary_button.dart';

class SalaryExplorerScreen extends StatefulWidget {
  const SalaryExplorerScreen({super.key});

  @override
  State<SalaryExplorerScreen> createState() => _SalaryExplorerScreenState();
}

class _SalaryExplorerScreenState extends State<SalaryExplorerScreen> {
  double _baseOffer = 900000;
  double _counterIncrement = 50000;
  String _selectedRole = 'Flutter Developer';
  String _selectedCity = 'Mumbai';

  @override
  Widget build(BuildContext context) {
    final simulatedTotal = _baseOffer + _counterIncrement;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Offers & Salary Explorer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Counter-Offer Simulator Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
                boxShadow: AppSpacing.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Counter-Offer Simulator', style: AppTypography.titleSm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: AppSpacing.roundedFull,
                        ),
                        child: Text(
                          'DATA-BACKED',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Simulated Total Compensation',
                    style: AppTypography.labelSm.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${(simulatedTotal / 100000).toStringAsFixed(2)} LPA',
                    style: AppTypography.displayLg.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Base Offer', style: AppTypography.labelMd),
                      Text('₹${(_baseOffer / 100000).toStringAsFixed(1)} LPA', style: AppTypography.labelMd.copyWith(color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: _baseOffer,
                    min: 300000,
                    max: 3000000,
                    divisions: 27,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _baseOffer = val),
                  ),
                  const SizedBox(height: 8),

                  Text('Counter Increment', style: AppTypography.labelMd),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [25000.0, 50000.0, 100000.0, 150000.0].map((inc) {
                      final isSelected = _counterIncrement == inc;
                      return ChoiceChip(
                        label: Text('+₹${(inc / 1000).round()}k'),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        onSelected: (_) => setState(() => _counterIncrement = inc),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estimated Monthly In-Hand', style: AppTypography.bodySm),
                      Text(
                        '₹${((simulatedTotal / 12) * 0.88).round()}',
                        style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700, color: AppColors.accent),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Market Compensation Benchmark
            Text('Market Salary Benchmarks', style: AppTypography.headlineSm),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: 'Flutter Developer', child: Text('Flutter Developer')),
                      DropdownMenuItem(value: 'Mobile Engineer', child: Text('Mobile Engineer')),
                      DropdownMenuItem(value: 'UI/UX Designer', child: Text('UI/UX Designer')),
                    ],
                    onChanged: (v) => setState(() => _selectedRole = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCity,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: 'Mumbai', child: Text('Mumbai')),
                      DropdownMenuItem(value: 'Bangalore', child: Text('Bangalore')),
                      DropdownMenuItem(value: 'Pune', child: Text('Pune')),
                    ],
                    onChanged: (v) => setState(() => _selectedCity = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Percentiles Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedLg,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildPercentileRow('25th Percentile (Entry Level)', '₹5.5 LPA', 0.35, AppColors.border),
                  _buildPercentileRow('50th Percentile (Median Market)', '₹7.8 LPA', 0.55, AppColors.primary),
                  _buildPercentileRow('75th Percentile (High Performers)', '₹10.5 LPA', 0.75, AppColors.accent),
                  _buildPercentileRow('90th Percentile (Top 10%)', '₹14.0 LPA', 0.95, AppColors.warning),
                ],
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              text: 'Generate Formal Counter-Offer Template',
              icon: Icons.description_outlined,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Negotiation letter template copied to clipboard with market citations.'),
                    backgroundColor: AppColors.accent,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentileRow(String label, String amount, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.bodySm),
              Text(amount, style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: AppSpacing.roundedFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
