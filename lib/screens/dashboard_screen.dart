import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/auth_service.dart';
import 'asset_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final String locCode;

  const DashboardScreen({
    super.key,
    required this.userName,
    required this.locCode,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color primaryBlue = Color(0xff0D5BE1);
  static const Color pageBackground = Color(0xffF3F5F9);

  final MobileScannerController scannerController = MobileScannerController();
  final TextEditingController assetController = TextEditingController();

  bool showCamera = false;
  bool scanned = false;
  bool isLoading = false;

  // Update these values from your cycle API if the API returns them.
  String cycleName = 'OCT-2026';
  String cycleStart = '2026-10-01';
  String cycleEnd = '2026-10-31';
  bool cycleIsOpen = true;

  @override
  void dispose() {
    scannerController.dispose();
    assetController.dispose();
    super.dispose();
  }

  String extractAssetCode(String value) {
    final String text = value.trim();
    if (text.isEmpty) return '';

    final Uri? uri = Uri.tryParse(text);
    if (uri != null) {
      final Map<String, String> params = uri.queryParameters;
      final String? assetId =
          params['assetid'] ?? params['assetCode'] ?? params['AssetCode'];
      if (assetId != null && assetId.trim().isNotEmpty) {
        return assetId.trim();
      }
    }
    return text;
  }

  Future<void> openAssetDetail() async {
    final String assetCode = extractAssetCode(assetController.text);

    if (assetCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or scan Asset Code')),
      );
      return;
    }
    if (isLoading) return;

    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    try {
      final AuthService service = AuthService();
      final Map<String, dynamic> response =
          await service.getAssetByCode(assetCode: assetCode);

      debugPrint('FULL ASSET RESPONSE: $response');
      if (!mounted) return;

      if (response['success'] != true) {
        throw Exception(response['message']?.toString() ?? 'Asset not found.');
      }
      if (response['asset'] is! Map) {
        throw Exception('Asset details are missing from API response.');
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AssetDetailScreen(
            assetCode: assetCode,
            assetData: response,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> toggleCamera() async {
    FocusScope.of(context).unfocus();
    final bool shouldShow = !showCamera;

    setState(() {
      showCamera = shouldShow;
      scanned = false;
    });

    try {
      if (shouldShow) {
        await scannerController.start();
      } else {
        await scannerController.stop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => showCamera = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not start QR scanner: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void handleBarcode(BarcodeCapture capture) {
    if (scanned || capture.barcodes.isEmpty || isLoading) return;
    final String? value = capture.barcodes.first.rawValue;
    if (value == null || value.trim().isEmpty) return;

    final String code = extractAssetCode(value);
    if (code.isEmpty) return;

    setState(() {
      scanned = true;
      assetController.text = code;
      showCamera = false;
    });
    scannerController.stop();
  }

  @override
  Widget build(BuildContext context) {
    final String displayName =
        widget.userName.trim().isEmpty ? 'User' : widget.userName.trim();

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: AppBar(
          elevation: 0,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          titleSpacing: 0,


          title: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
                // child: const Icon(

                //   Icons.bar_chart_rounded,
                //   color: primaryBlue,
                //   size: 25,
                // ),

                child: Padding(
  padding: const EdgeInsets.all(4),
  child: Image.asset(
    'assets/logo.png',
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      return const Icon(
        Icons.image_not_supported,
        color: primaryBlue,
        size: 25,
      );
    },
  ),
),
              ),
              const Expanded(
                child: Text(
                  'Asset Verification',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 185),
                  child: Text(
                    '$displayName · ${widget.locCode}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: cycleIsOpen
                          ? const Color(0xffE8F7EF)
                          : const Color(0xffFDECEC),
                      border: Border.all(
                        color: cycleIsOpen
                            ? const Color(0xffB4E4C7)
                            : const Color(0xffF3B9B9),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: cycleIsOpen
                              ? const Color(0xff087443)
                              : const Color(0xffB42318),
                        ),
                        children: [
                          TextSpan(
                            text: '$cycleName ',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text:
                                'window is ${cycleIsOpen ? 'OPEN' : 'CLOSED'} ($cycleStart → $cycleEnd).',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: const Color(0xffDDE4EF)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Scan asset QR / barcode',
                          style: TextStyle(
                            color: Color(0xff58677D),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: isLoading ? null : toggleCamera,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryBlue,
                              side: const BorderSide(
                                color: primaryBlue,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(
                              showCamera ? 'Stop camera' : 'Start camera',
                            ),
                          ),
                        ),
                        if (showCamera) ...[
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 260,
                              child: MobileScanner(
                                controller: scannerController,
                                onDetect: handleBarcode,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 13),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Color(0xffD9E0EA))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'or enter the code manually',
                                style: TextStyle(
                                  color: Color(0xff65748B),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Color(0xffD9E0EA))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: TextField(
                                  controller: assetController,
                                  enabled: !isLoading,
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  onSubmitted: (_) => openAssetDetail(),
                                  decoration: InputDecoration(
                                    hintText: 'Asset code',
                                    hintStyle: const TextStyle(
                                      color: Color(0xff65748B),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xffDDE4EF),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xffDDE4EF),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: primaryBlue,
                                        width: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 52,
                              width: 65,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : openAssetDetail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Go'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
