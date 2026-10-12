part of '../pages/contact_us_page.dart';

class _OtpDialog extends StatefulWidget {
  final String       phoneNumber;
  final bool         isRtl;
  final Color        primaryColor;
  /// Receives the one-time verification token from the server (BUG-51).
  final ValueChanged<String> onVerified;

  const _OtpDialog({
    required this.phoneNumber,
    required this.isRtl,
    required this.primaryColor,
    required this.onVerified,
  });

  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  final List<TextEditingController> _digitCtrls =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  bool   _submitted   = false;
  bool   _hasError     = false;
  int    _countdown    = 30;
  bool   _canResend    = false;
  StreamSubscription? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _countdown = 30;
      _canResend = false;
    });
    _timer = Stream.periodic(const Duration(seconds: 1), (i) => i)
        .take(30)
        .listen((_) {
      if (!mounted) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) _canResend = true;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _digitCtrls) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode =>
      _digitCtrls.map((c) => c.text).join();

  bool get _isOtpEmpty =>
      _digitCtrls.every((c) => c.text.trim().isEmpty);

  void _verifyOtp() {
    setState(() {
      _submitted = true;
      _hasError  = false;
    });
    final code = _otpCode.trim();
    if (code.length < 6) return;
    context.read<ContactOtpCubit>().verifyOtp(
      phoneNumber: widget.phoneNumber,
      code:        code,
    );
  }

  void _resendOtp() {
    for (final c in _digitCtrls) c.clear();
    setState(() {
      _submitted = false;
      _hasError  = false;
    });
    _timer?.cancel();
    _startTimer();

    final locale = widget.isRtl ? 'ar' : 'en';
    context.read<ContactOtpCubit>().sendOtp(
      phoneNumber: widget.phoneNumber,
      locale:      locale,
    );
  }

  void _onDigitChanged(String value, int index) {
    setState(() => _hasError = false);

    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.length == 1 && index == 5 && _otpCode.length == 6) {
      _verifyOtp();
    }
  }

  void _onDigitKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _digitCtrls[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s Sec';
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < _BP.mobile;

    final String title = widget.isRtl
        ? 'رمز التحقق'
        : 'VERIFICATION CODE';
    final String desc = widget.isRtl
        ? 'لقد أرسلنا رمز التحقق إلى هاتفك لإتمام عملية التحقق'
        : 'We have sent the OTP code to your Phone For the verification process';
    final String verifyBtn = widget.isRtl ? 'تحقق الآن'        : 'Verify Now';
    final String resendBtn = widget.isRtl ? 'إعادة إرسال الرمز' : 'Resend Code';
    final String errorMsg  = widget.isRtl
        ? 'رمز غير صحيح، يرجى التحقق والمحاولة مرة أخرى'
        : 'Incorrect code, please check and try again';

    return Directionality(
      textDirection: widget.isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: BlocListener<ContactOtpCubit, ContactOtpState>(
        listener: (context, state) {
          if (state is OtpVerified) widget.onVerified(state.verificationToken);
          if (state is OtpError) {
            setState(() => _hasError = true);
          }
        },
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 16 : 21.r),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : 47.w,
            vertical:   isMobile ? 40 : 47.h,
          ),
          child: SizedBox(
            width: isMobile ? double.infinity : 624.w,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 42.w,
                vertical:   isMobile ? 28 : 42.h,
              ),
              child: BlocBuilder<ContactOtpCubit, ContactOtpState>(
                builder: (context, state) {
                  final isVerifying = state is OtpVerifying;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── BUG-14: close (X) button ──
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: IconButton(
                          tooltip: widget.isRtl ? 'إغلاق' : 'Close',
                          icon: Icon(Icons.close,
                              size: isMobile ? 20 : 29.sp,
                              color: Colors.grey.shade700),
                          onPressed: () {
                            context.read<ContactOtpCubit>().reset();
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      // ── SVG Illustration ── (BUG-14: fallback icon instead
                      // of a blank area if the asset can't be loaded)
                      SvgPicture.asset(
                        'assets/images/mobile_code_dialog.svg',
                        width:  isMobile ? 120 : 182.w,
                        height: isMobile ? 100 : 156.h,
                        fit:    BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.sms_outlined,
                          size:  isMobile ? 72 : 109.sp,
                          color: widget.primaryColor,
                        ),
                      ),
                      SizedBox(height: isMobile ? 20 : 31.h),

                      // ── Title ──
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize22Weight700.copyWith(
                          fontSize:      isMobile ? 18.0 : 26.sp,
                          color:         Colors.black,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: isMobile ? 8 : 13.h),

                      // ── Description ──
                      Text(
                        desc,
                        textAlign: TextAlign.center,
                        style: StyleText.fontSize13Weight400.copyWith(
                          fontSize: isMobile ? 12.0 : 17.sp,
                          color:    Colors.grey.shade600,
                          height:   1.5,
                        ),
                      ),
                      SizedBox(height: isMobile ? 24 : 36.h),

                      // ── 6-Digit OTP Boxes ──
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (i) {
                            final bool filled =
                                _digitCtrls[i].text.isNotEmpty;
                            return Container(
                              width:  isMobile ? 44 : 62.w,
                              height: isMobile ? 50 : 70.h,
                              margin: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 3 : 5.2.w),
                              child: KeyboardListener(
                                focusNode: FocusNode(),
                                onKeyEvent: (e) => _onDigitKey(i, e),
                                child: TextField(
                                  controller:   _digitCtrls[i],
                                  focusNode:    _focusNodes[i],
                                  keyboardType: TextInputType.number,
                                  textAlign:    TextAlign.center,
                                  maxLength:    1,
                                  style: StyleText.fontSize22Weight700
                                      .copyWith(
                                    fontSize: isMobile ? 18.0 : 26.sp,
                                    color:    _hasError
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled:      true,
                                    fillColor: _hasError
                                        ? Colors.red.withOpacity(0.05)
                                        : filled
                                        ? widget.primaryColor
                                        .withOpacity(0.05)
                                        : Colors.grey.shade50,
                                    contentPadding:
                                    EdgeInsets.symmetric(
                                        vertical: isMobile ? 12 : 18.h),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: _hasError
                                            ? Colors.red
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: _hasError
                                            ? Colors.red
                                            : filled
                                            ? widget.primaryColor
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: _hasError
                                            ? Colors.red
                                            : widget.primaryColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  onChanged: (v) =>
                                      _onDigitChanged(v, i),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: isMobile ? 14 : 21.h),

                      // ── Error Message ──
                      if (_hasError)
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: isMobile ? 8 : 13.h),
                          child: Text(
                            errorMsg,
                            textAlign: TextAlign.center,
                            style: StyleText.fontSize12Weight400.copyWith(
                              color:    Colors.red,
                              fontSize: isMobile ? 11.0 : 16.sp,
                            ),
                          ),
                        ),

                      // ── Timer ──
                      if (!_canResend)
                        Text(
                          _formatTime(_countdown),
                          style: StyleText.fontSize13Weight400.copyWith(
                            color:    widget.primaryColor,
                            fontSize: isMobile ? 13.0 : 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      SizedBox(height: isMobile ? 18 : 26.h),

                      // ── Action Button ──
                      SizedBox(
                        width:  double.infinity,
                        height: isMobile ? 46 : 57.h,
                        child: _canResend
                            ? ElevatedButton(
                          onPressed: _resendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            resendBtn,
                            style: StyleText.fontSize16Weight600
                                .copyWith(
                              color:    Colors.white,
                              fontSize: isMobile ? 14.0 : 20.sp,
                            ),
                          ),
                        )
                            : ElevatedButton(
                          onPressed:
                          isVerifying ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.primaryColor,
                            disabledBackgroundColor:
                            widget.primaryColor
                                .withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: isVerifying
                              ? const SizedBox(
                            height: 18,
                            width:  18,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Text(
                            verifyBtn,
                            style: StyleText
                                .fontSize16Weight600
                                .copyWith(
                              color: Colors.white,
                              fontSize:
                              isMobile ? 14.0 : 20.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DESKTOP BODY
// ═══════════════════════════════════════════════════════════════════════════════
