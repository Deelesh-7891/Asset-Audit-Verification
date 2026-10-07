import 'dart:io';

import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'package:assetaudit/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController empCodeController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  // ============================================================
  // API SERVICE
  // ============================================================

  final AuthService apiService = AuthService();

  // ============================================================
  // VARIABLES
  // ============================================================

  bool loading = false;

  bool obscurePassword = true;

  String? error;

  // ============================================================
  // LOGIN
  // ============================================================
  

  





  Future<void> login() async {
    // ------------------------------------------------------------
    // Employee Code Validation
    // ------------------------------------------------------------

    if (empCodeController.text.trim().isEmpty) {
      setState(() {
        error = "Employee Code enter करें";
      });

      return;
    }

    // ------------------------------------------------------------
    // Password Validation
    // ------------------------------------------------------------

    if (passwordController.text.trim().isEmpty) {
      setState(() {
        error = "Password enter करें";
      });

      return;
    }

    // ------------------------------------------------------------
    // START LOADING
    // ------------------------------------------------------------

    setState(() {
      loading = true;
      error = null;
    });

    debugPrint("======================================");
    debugPrint("LOGIN BUTTON CLICKED");
    debugPrint(
      "Employee Code: ${empCodeController.text.trim()}",
    );
    debugPrint("======================================");

    try {
      // ==========================================================
      // API LOGIN
      // ==========================================================

      final result = await apiService.login(
        empCodeController.text.trim(),
        passwordController.text.trim(),
      );

      debugPrint("API RESPONSE => $result");

      if (!mounted) return;

      // ==========================================================
      // LOGIN SUCCESS
      // ==========================================================

      if (result["success"] == true) {
  debugPrint("LOGIN SUCCESS");

  final user = result["user"];

  final String userName =
      user?["userName"]?.toString() ?? "";

  final String locCode =
      user?["locCode"]?.toString() ?? "";

  debugPrint("User Name: $userName");
  debugPrint("Location Code: $locCode");

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => DashboardScreen(
        userName: userName,
        locCode: locCode,
      ),
    ),
  );
}

      // ==========================================================
      // LOGIN FAILED
      // ==========================================================

      else {
        debugPrint("LOGIN FAILED");

        setState(() {
          error = result["message"]?.toString() ??
              "Employee Code and Password Not Found";
        });
      }
    }

    // ============================================================
    // EXCEPTION
    // ============================================================

    catch (e) {
      debugPrint("======================================");
      debugPrint("LOGIN ERROR => $e");
      debugPrint("======================================");

      if (!mounted) return;

      final String errorText = e.toString();

      // ==========================================================
      // SSL CERTIFICATE ERROR
      // ==========================================================

      if (errorText.contains("CERTIFICATE_VERIFY_FAILED") ||
          errorText.contains("HandshakeException") ||
          errorText.contains("unable to get local issuer")) {
        setState(() {
          error =
              "API SSL Certificate Error.\n\n"
              "Server का SSL certificate trusted नहीं है.\n"
              "API server का SSL certificate और "
              "certificate chain check करें.";
        });
      }

      // ==========================================================
      // SOCKET / INTERNET ERROR
      // ==========================================================

      else if (errorText.contains("SocketException")) {
        setState(() {
          error =
              "API server से connection नहीं हो पाया.\n"
              "Internet connection और API URL check करें.";
        });
      }

      // ==========================================================
      // OTHER ERROR
      // ==========================================================

      else {
        setState(() {
          error =
              "Login करते समय error आया.\n\n"
              "$errorText";
        });
      }
    }

    // ============================================================
    // STOP LOADING
    // ============================================================

    finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    empCodeController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // LINK TEXT
  // ============================================================

  Widget linkText(
    String text,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,

      child: Text(
        text,

        style: const TextStyle(
          color: Color(0xff6A1B9A),
          fontSize: 16,
          decoration: TextDecoration.underline,
          decorationColor: Color(0xff6A1B9A),
        ),
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F5F8),

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // TOP BLUE HEADER
            // ==================================================

            Container(
              width: double.infinity,
              height: 74,

              color: const Color(0xff1261D6),

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: Row(
                  children: [

                    // ------------------------------------------
                    // HEADER LOGO
                    // ------------------------------------------

                    Container(
                      width: 52,
                      height: 52,

                      padding: const EdgeInsets.all(7),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(8),
                      ),

                      child: Image.asset(
                        "assets/logo.png",

                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(width: 14),

                    // ------------------------------------------
                    // HEADER TITLE
                    // ------------------------------------------

                    const Text(
                      "Asset Verification",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // BODY
            // ==================================================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 24,
                ),

                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 655,
                    ),

                    child: Container(
                      width: double.infinity,

                      padding: const EdgeInsets.fromLTRB(
                        25,
                        28,
                        25,
                        22,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(18),

                        border: Border.all(
                          color: const Color(0xffDDE3EA),
                        ),

                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          // ==================================================
                          // PREM MOTORS LOGO
                          // ==================================================

                          Center(
                            child: Image.asset(
                              "assets/logo.png",

                              width: 220,
                              height: 72,

                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ==================================================
                          // INFORMATION BOX
                          // ==================================================

                          Container(
                            width: double.infinity,

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),

                            decoration: BoxDecoration(
                              color:
                                  const Color(0xffE9F2FF),

                              border: Border.all(
                                color:
                                    const Color(0xffB9D5FF),
                              ),

                              borderRadius:
                                  BorderRadius.circular(12),
                            ),

                            child: const Text(
                              "Sign in with your maintenance "
                              "EmpCode to start verifying assets.",

                              style: TextStyle(
                                color:
                                    Color(0xff164A91),

                                fontSize: 17,

                                height: 1.35,
                              ),
                            ),
                          ),

                          const SizedBox(height: 21),

                          // ==================================================
                          // EMPLOYEE CODE LABEL
                          // ==================================================

                          const Text(
                            "Employee Code",

                            style: TextStyle(
                              fontSize: 17,

                              fontWeight:
                                  FontWeight.w600,

                              color:
                                  Color(0xff526170),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ==================================================
                          // EMPLOYEE CODE FIELD
                          // ==================================================

                          TextField(
                            controller:
                                empCodeController,

                            enabled: !loading,

                            keyboardType:
                                TextInputType.text,

                            textInputAction:
                                TextInputAction.next,

                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                            ),

                            decoration:
                                InputDecoration(
                              hintText:
                                  "e.g. EMP1042",

                              filled: true,

                              fillColor:
                                  const Color(0xffE8F0FD),

                              contentPadding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 18,
                                vertical: 18,
                              ),

                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  13,
                                ),

                                borderSide:
                                    BorderSide.none,
                              ),

                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  13,
                                ),

                                borderSide:
                                    BorderSide.none,
                              ),

                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  13,
                                ),

                                borderSide:
                                    const BorderSide(
                                  color:
                                      Color(0xff1565D8),

                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ==================================================
                          // PASSWORD LABEL
                          // ==================================================

                          const Text(
                            "Password",

                            style: TextStyle(
                              fontSize: 17,

                              fontWeight:
                                  FontWeight.w600,

                              color:
                                  Color(0xff526170),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ==================================================
                          // PASSWORD FIELD
                          // ==================================================

                          TextField(
                            controller:
                                passwordController,

                            enabled: !loading,

                            obscureText:
                                obscurePassword,

                            textInputAction:
                                TextInputAction.done,

                            onSubmitted: (_) {
                              if (!loading) {
                                login();
                              }
                            },

                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                            ),

                            decoration:
                                InputDecoration(
                              hintText:
                                  "Password",

                              filled: true,

                              fillColor:
                                  const Color(0xffE8F0FD),

                              contentPadding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 18,
                                vertical: 18,
                              ),

                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  13,
                                ),

                                borderSide:
                                    BorderSide.none,
                              ),

                              enabledBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  13,
                                ),

                                borderSide:
                                    BorderSide.none,
                              ),

                              focusedBorder:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  13,
                                ),

                                borderSide:
                                    const BorderSide(
                                  color:
                                      Color(0xff1565D8),

                                  width: 1.5,
                                ),
                              ),

                              // --------------------------------
                              // PASSWORD SHOW / HIDE
                              // --------------------------------

                              suffixIcon:
                                  IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons
                                          .visibility_off
                                      : Icons.visibility,

                                  color:
                                      Colors.grey.shade700,
                                ),

                                onPressed: loading
                                    ? null
                                    : () {
                                        setState(() {
                                          obscurePassword =
                                              !obscurePassword;
                                        });
                                      },
                              ),
                            ),
                          ),

                          // ==================================================
                          // ERROR MESSAGE
                          // ==================================================

                          if (error != null) ...[
                            const SizedBox(height: 14),

                            Container(
                              width: double.infinity,

                              padding:
                                  const EdgeInsets.all(12),

                              decoration: BoxDecoration(
                                color:
                                    Colors.red.shade50,

                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),

                                border: Border.all(
                                  color:
                                      Colors.red.shade200,
                                ),
                              ),

                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [

                                  const Icon(
                                    Icons.error_outline,

                                    color: Colors.red,

                                    size: 21,
                                  ),

                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: Text(
                                      error!,

                                      style:
                                          const TextStyle(
                                        color: Colors.red,

                                        fontSize: 13,

                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 21),

                          // ==================================================
                          // SIGN IN BUTTON
                          // ==================================================

                          SizedBox(
                            width: double.infinity,

                            height: 64,

                            child: ElevatedButton(
                              onPressed:
                                  loading ? null : login,

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(
                                  0xff1261D6,
                                ),

                                disabledBackgroundColor:
                                    Colors.grey.shade400,

                                elevation: 0,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    13,
                                  ),
                                ),
                              ),

                              child: loading

                                  // --------------------------------
                                  // LOADING
                                  // --------------------------------
                                  ? const SizedBox(
                                      width: 25,
                                      height: 25,

                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2.5,

                                        valueColor:
                                            AlwaysStoppedAnimation<
                                                Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )

                                  // --------------------------------
                                  // SIGN IN TEXT
                                  // --------------------------------
                                  : const Text(
                                      "Sign In",

                                      style: TextStyle(
                                        color: Colors.white,

                                        fontSize: 21,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 17),

                          // ==================================================
                          // BOTTOM LINKS
                          // ==================================================

                          // Center(
                          //   child: Wrap(
                          //     alignment:
                          //         WrapAlignment.center,

                          //     children: [

                          //       linkText(
                          //         "Set / change password",
                          //         () {
                          //           // TODO:
                          //           // Password screen open करें
                          //         },
                          //       ),

                          //       const Text(
                          //         "   ·   ",

                          //         style: TextStyle(
                          //           color:
                          //               Color(0xff555555),

                          //           fontSize: 16,
                          //         ),
                          //       ),

                          //       // linkText(
                          //       //   "Asset Console",
                          //       //   () {
                          //       //     // TODO:
                          //       //     // Asset Console open करें
                          //       //   },
                          //       // ),

                          //       // const Text(
                          //       //   "   ·   ",

                          //       //   style: TextStyle(
                          //       //     color:
                          //       //         Color(0xff555555),

                          //       //     fontSize: 16,
                          //       //   ),
                          //       // ),

                          //       // linkText(
                          //       //   "Guide",
                          //       //   () {
                          //       //     // TODO:
                          //       //     // Guide screen open करें
                          //       //   },
                          //       // ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}