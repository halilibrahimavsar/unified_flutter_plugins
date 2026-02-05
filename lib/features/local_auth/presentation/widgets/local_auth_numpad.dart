import 'package:flutter/material.dart';
import '../constants/local_auth_constants.dart';

class LocalAuthNumpad extends StatelessWidget {
  final bool isLockedOut;
  final bool showBiometric;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onBiometric;

  const LocalAuthNumpad({
    super.key,
    required this.isLockedOut,
    required this.showBiometric,
    required this.onDigit,
    required this.onBackspace,
    required this.onBiometric,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var j = 1; j <= 3; j++)
                  _NumberButton(
                    digit: (i * 3 + j).toString(),
                    isLockedOut: isLockedOut,
                    onTap: onDigit,
                  ),
              ],
            ),
            SizedBox(height: LocalAuthConstants.numpadSpacing),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ActionButton(
                icon: showBiometric ? Icons.fingerprint_rounded : null,
                isLockedOut: isLockedOut,
                onTap: onBiometric,
              ),
              _NumberButton(
                digit: '0',
                isLockedOut: isLockedOut,
                onTap: onDigit,
              ),
              _ActionButton(
                icon: Icons.backspace_outlined,
                isLockedOut: isLockedOut,
                onTap: onBackspace,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final String digit;
  final bool isLockedOut;
  final ValueChanged<String> onTap;

  const _NumberButton({
    required this.digit,
    required this.isLockedOut,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLockedOut ? null : () => onTap(digit),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        height: LocalAuthConstants.numpadButtonSize,
        width: LocalAuthConstants.numpadButtonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData? icon;
  final bool isLockedOut;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.isLockedOut,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (icon == null)
      return SizedBox(width: LocalAuthConstants.numpadButtonSize);
    return InkWell(
      onTap: isLockedOut ? null : onTap,
      borderRadius: BorderRadius.circular(40),
      child: SizedBox(
        height: LocalAuthConstants.numpadButtonSize,
        width: LocalAuthConstants.numpadButtonSize,
        child: Icon(
          icon,
          size: 28,
          color: isLockedOut ? Colors.grey : Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
