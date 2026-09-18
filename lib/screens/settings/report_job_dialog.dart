import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../models/job_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/primary_button.dart';

class ReportJobDialog extends StatefulWidget {
  final JobModel job;

  const ReportJobDialog({super.key, required this.job});

  @override
  State<ReportJobDialog> createState() => _ReportJobDialogState();
}

class _ReportJobDialogState extends State<ReportJobDialog> {
  String _selectedReason = 'Misleading Description';
  final _descCtrl = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'Scam',
    'Incorrect Salary',
    'Misleading Description',
    'Asking for Money',
    'Impersonation',
    'Other',
  ];

  Future<void> _submitReport() async {
    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();
    final firestore = FirestoreService();
    await firestore.reportJob(
      userId: auth.user?.uid ?? 'anonymous_user',
      jobId: widget.job.id,
      reason: _selectedReason,
      description: _descCtrl.text.trim(),
    );

    setState(() => _isSubmitting = false);
    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report submitted. Our trust & safety team will review this listing.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
      title: Row(
        children: [
          const Icon(Icons.report_problem_outlined, color: AppColors.danger),
          const SizedBox(width: 8),
          Text('Report Job Listing', style: AppTypography.titleSm),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reporting: ${widget.job.title} at ${widget.job.companyName}',
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Text('Select Reason', style: AppTypography.labelSm),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedReason,
            isExpanded: true,
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r, style: AppTypography.bodySm))).toList(),
            onChanged: (val) => setState(() => _selectedReason = val!),
          ),
          const SizedBox(height: 14),
          Text('Additional Details (Optional)', style: AppTypography.labelSm),
          const SizedBox(height: 6),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Describe why this listing violates terms...'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        SizedBox(
          width: 120,
          child: PrimaryButton(
            text: 'Submit',
            isLoading: _isSubmitting,
            backgroundColor: AppColors.danger,
            height: 38,
            onPressed: _submitReport,
          ),
        ),
      ],
    );
  }
}
