import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AssetDetailScreen extends StatefulWidget {
  final String assetCode;
  final Map<String, dynamic> assetData;

  const AssetDetailScreen({
    super.key,
    required this.assetCode,
    required this.assetData,
  });

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  static const Color primaryColor = Color(0xff1F5FCC);

  bool isOk = true;
  bool raiseTicket = false;
  bool isSubmitting = false;

  final TextEditingController remarkController = TextEditingController();

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Map<String, dynamic> get asset => _asMap(widget.assetData['asset']);
  Map<String, dynamic> get rawAsset => _asMap(asset['raw']);
  Map<String, dynamic> get cycle => _asMap(widget.assetData['cycle']);
  Map<String, dynamic> get lastVerification =>
      _asMap(widget.assetData['lastVerification']);

  @override
  void dispose() {
    remarkController.dispose();
    super.dispose();
  }

  String display(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return '-';
    return value.toString();
  }

  Widget sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 4),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget detailRow(String title, dynamic value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffEEEEEE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              display(value),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle(title, icon),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> submitVerification() async {
    if (isSubmitting) return;

    final String status = isOk ? 'OK' : 'ISSUE';
    final String remark = isOk ? '' : remarkController.text.trim();

    if (status == 'ISSUE' && remark.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a remark for the issue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    bool loadingDialogOpen = false;

    try {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      loadingDialogOpen = true;

      final AuthService service = AuthService();
      final Map<String, dynamic> response = await service.verifyAsset(
        assetCode: widget.assetCode,
        status: status,
        remark: remark,
        raiseTicket: status == 'ISSUE' && raiseTicket,
      );

      if (!mounted) return;

      if (loadingDialogOpen) {
        Navigator.of(context, rootNavigator: true).pop();
        loadingDialogOpen = false;
      }

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'OK'
                  ? 'Asset verification submitted successfully.'
                  : (raiseTicket
                      ? 'Issue submitted. Ticket request sent.'
                      : 'Asset issue submitted successfully.'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        final String message =
            response['message']?.toString() ??
            response['error']?.toString() ??
            'Verification failed.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;

      if (loadingDialogOpen) {
        Navigator.of(context, rootNavigator: true).pop();
        loadingDialogOpen = false;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool alreadyVerified = widget.assetData['alreadyVerified'] == true;

    return Scaffold(
      backgroundColor: const Color(0xffF2F4F7),
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Asset Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 750),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (alreadyVerified)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xfffff5df),
                        border: Border.all(color: Colors.orange.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.deepOrange),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ALREADY VERIFIED',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Status: ${display(lastVerification['Status'])}'),
                          Text(
                            'Verified By: ${display(lastVerification['VerifiedByName'])}',
                          ),
                          Text(
                            'Verified Date: ${display(lastVerification['VerifiedDateTime'])}',
                          ),
                          Text('Remark: ${display(lastVerification['Remark'])}'),
                          const SizedBox(height: 8),
                          const Text(
                            'This asset has already been verified in this cycle.',
                          ),
                        ],
                      ),
                    ),
                  sectionCard(
                    title: 'Asset Information',
                    icon: Icons.inventory_2_outlined,
                    children: [
                      detailRow('Asset Code', asset['assetCode'] ?? widget.assetCode),
                      detailRow('Cycle Name', cycle['CycleName']),
                      detailRow('Description', asset['assetDescription']),
                      detailRow('Location Code', asset['locCode']),
                      if (rawAsset.isNotEmpty) ...[
                        detailRow('Location Description', rawAsset['LocDesc']),
                        detailRow('Department', rawAsset['ConcernDepartment']),
                        detailRow('Region', rawAsset['Region']),
                        detailRow('Asset Type', rawAsset['AssetType']),
                      ],
                    ],
                  ),
                  sectionCard(
                    title: 'Submit Verification',
                    icon: Icons.fact_check_outlined,
                    children: [
                      const Text(
                        'Is this asset functioning properly?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isSubmitting
                                  ? null
                                  : () => setState(() {
                                        isOk = true;
                                        raiseTicket = false;
                                      }),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('OK'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isOk ? Colors.green : Colors.black54,
                                side: BorderSide(
                                  color: isOk ? Colors.green : Colors.grey,
                                ),
                                padding: const EdgeInsets.all(14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isSubmitting
                                  ? null
                                  : () => setState(() => isOk = false),
                              icon: const Icon(Icons.warning_amber),
                              label: const Text('ISSUE'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: !isOk ? Colors.red : Colors.black54,
                                side: BorderSide(
                                  color: !isOk ? Colors.red : Colors.grey,
                                ),
                                padding: const EdgeInsets.all(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isOk) ...[
                        const SizedBox(height: 18),
                        TextField(
                          controller: remarkController,
                          enabled: !isSubmitting,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Remark *',
                            hintText: 'Describe the asset issue',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: raiseTicket,
                          onChanged: isSubmitting
                              ? null
                              : (value) => setState(() {
                                    raiseTicket = value ?? false;
                                  }),
                          title: const Text('Raise complaint ticket'),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: isSubmitting ? null : submitVerification,
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            isSubmitting ? 'Submitting...' : 'Submit Verification',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
