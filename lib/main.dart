```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _operator;
  bool _waitingForSecondOperand = false;

  void _inputDigit(String digit) {
    if (_waitingForSecondOperand) {
      setState(() {
        _display = digit;
        _waitingForSecondOperand = false;
      });
    } else {
      setState(() {
        if (_display == '0' && digit != '.') {
          _display = digit;
        } else if (_display.contains('.') && digit == '.') {
          // ignore duplicate decimal point
        } else {
          _display += digit;
        }
      });
    }
  }

  void _inputOperator(String op) {
    if (_operator != null && !_waitingForSecondOperand) {
      _calculate();
    }
    setState(() {
      _firstOperand = double.tryParse(_display);
      _operator = op;
      _waitingForSecondOperand = true;
      _expression = '$_display $op';
    });
  }

  void _calculate() {
    if (_operator == null || _firstOperand == null) return;

    final double secondOperand = double.tryParse(_display) ?? 0;
    double result;

    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = _firstOperand! - secondOperand;
        break;
      case 'Ã':
        result = _firstOperand! * secondOperand;
        break;
      case 'Ã·':
        result = secondOperand != 0 ? _firstOperand! / secondOperand : double.nan;
        break;
      default:
        return;
    }

    setState(() {
      _display = result.isNaN ? 'Error' : _formatResult(result);
      _expression = '$_firstOperand $_operator $secondOperand =';
      _operator = null;
      _firstOperand = result.isNaN ? null : result;
      _waitingForSecondOperand = true;
    });
  }

  String _formatResult(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    // Limit to 8 decimal places to avoid overflow
    return value.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _clear() {
    setState(() {
      _display = '0';
      _expression = '';
      _firstOperand = null;
      _operator = null;
      _waitingForSecondOperand = false;
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else if (_display != '0') {
        _display = '-$_display';
      }
    });
  }

  void _percent() {
    setState(() {
      final value = double.tryParse(_display) ?? 0;
      _display = _formatResult(value / 100);
    });
  }

  void _decimalPoint() {
    if (_waitingForSecondOperand) {
      setState(() {
        _display = '0.';
        _waitingForSecondOperand = false;
      });
    } else if (!_display.contains('.')) {
      setState(() {
        _display += '.';
      });
    }
  }

  void _backspace() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  Widget _buildButton(String text, {Color? color, double flex = 1}) {
    return Expanded(
      flex: flex.round(),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: 70,
          child: ElevatedButton(
            onPressed: () {
              switch (text) {
                case 'C':
                  _clear();
                  break;
                case 'â«':
                  _backspace();
                  break;
                case 'Â±':
                  _toggleSign();
                  break;
                case '%':
                  _percent();
                  break;
                case 'Ã·':
                case 'Ã':
                case '-':
                case '+':
                  _inputOperator(text);
                  break;
                case '=':
                  _calculate();
                  break;
                case '.':
                  _decimalPoint();
                  break;
                default:
                  _inputDigit(text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: color != null ? Colors.white : Theme.of(context).colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Display area
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _expression,
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _display,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Button area
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Row 1: C, â«, %, Ã·
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('C', color: colorScheme.error),
                          _buildButton('â«'),
                          _buildButton('%'),
                          _buildButton('Ã·', color: colorScheme.primary),
                        ],
                      ),
                    ),
                    // Row 2: 7, 8, 9, Ã
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('7'),
                          _buildButton('8'),
                          _buildButton('9'),
                          _buildButton('Ã', color: colorScheme.primary),
                        ],
                      ),
                    ),
                    // Row 3: 4, 5, 6, -
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('4'),
                          _buildButton('5'),
                          _buildButton('6'),
                          _buildButton('-', color: colorScheme.primary),
                        ],
                      ),
                    ),
                    // Row 4: 1, 2, 3, +
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('1'),
                          _buildButton('2'),
                          _buildButton('3'),
                          _buildButton('+', color: colorScheme.primary),
                        ],
                      ),
                    ),
                    // Row 5: Â±, 0, ., =
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('Â±'),
                          _buildButton('0'),
                          _buildButton('.'),
                          _buildButton('=', color: colorScheme.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```