import 'package:flutter/material.dart';

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
            const SizedBox(height: 20),
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
        height: 75,
        width: 75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
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
    if (icon == null) return const SizedBox(width: 75);
    return InkWell(
      onTap: isLockedOut ? null : onTap,
      borderRadius: BorderRadius.circular(40),
      child: SizedBox(
        height: 75,
        width: 75,
        child: Icon(
          icon,
          size: 28,
          color: isLockedOut ? Colors.grey : Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
