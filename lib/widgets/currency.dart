// lib/widgets/currency_display.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyDisplay extends StatelessWidget {
  final double amount;
  final TextStyle? textStyle;
  final bool showSymbol;

  const CurrencyDisplay({
    super.key,
    required this.amount,
    this.textStyle,
    this.showSymbol = true,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'en_CA',
      symbol: showSymbol ? 'CAD ' : '',
    );

    return Text(
      formatter.format(amount),
      style:
          textStyle ??
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    );
  }
}
