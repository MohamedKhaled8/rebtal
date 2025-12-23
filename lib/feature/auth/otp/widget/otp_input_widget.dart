import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_go/extensions/responsive_nums.dart';

class OtpInputWidget extends StatefulWidget {
  final Function(String) onCompleted;
  final VoidCallback? onChanged;

  const OtpInputWidget({super.key, required this.onCompleted, this.onChanged});

  @override
  State<OtpInputWidget> createState() => OtpInputWidgetState();
}

class OtpInputWidgetState extends State<OtpInputWidget> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.isNotEmpty && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }

        if (_isComplete()) {
          final otp = _getOtp();
          widget.onCompleted(otp);
        }

        widget.onChanged?.call();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool _isComplete() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getOtp() {
    return _controllers.map((c) => c.text).join();
  }

  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void setOtp(String otp) {
    if (otp.length != 6) return;

    for (int i = 0; i < 6; i++) {
      _controllers[i].text = otp[i];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return _buildOtpField(index);
      }),
    );
  }

  Widget _buildOtpField(int index) {
    final hasFocus = _focusNodes[index].hasFocus;
    final hasText = _controllers[index].text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 13.w,
      height: 13.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasFocus
              ? const Color(0xFF3B82F6)
              : hasText
              ? const Color(0xFF3B82F6).withOpacity(0.5)
              : Colors.grey.shade300,
          width: hasFocus ? 2.5 : 2,
        ),
        boxShadow: hasFocus
            ? [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade900,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
        onTap: () {
          _controllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: _controllers[index].text.length),
          );
        },
      ),
    );
  }
}
