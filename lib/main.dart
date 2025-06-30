import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// Building a simple Calculator App with Flutter

// Light Theme
final appLightTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Color.fromARGB(255, 238, 237, 237),
);

// Dark Theme
final appDarkTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.dark,
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Calculator',
      theme: _themeMode == ThemeMode.light
          ? appLightTheme
          : appDarkTheme,
      darkTheme: appDarkTheme,
      themeMode: _themeMode,
      home: CalculatorScreen(
        themeMode: _themeMode,
        onThemeChanged: (ThemeMode newTheme) {
          setState(() {
            _themeMode = newTheme;
          });
        },
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const CalculatorScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  String _previousValue = '';
  String _operator = '';
  bool _waitingForOperand = false;

  void _inputNumber(String number) {
    setState(() {
      if (_waitingForOperand) {
        _display = number;
        _waitingForOperand = false;
      } else {
        _display = _display == '0' ? number : _display + number;
      }
    });
  }

  void _inputOperator(String nextOperator) {
    double inputValue = double.parse(_display);

    if (_previousValue.isEmpty) {
      _previousValue = inputValue.toString();
      _expression = '$_display ${_getOperatorSymbol(nextOperator)} ';
    } else if (_operator.isNotEmpty) {
      double previousValue = double.parse(_previousValue);
      double result = _calculate(previousValue, inputValue, _operator);

      setState(() {
        _display = _formatResult(result);
        _previousValue = result.toString();
        _expression =
            '${_formatResult(result)} ${_getOperatorSymbol(nextOperator)} ';
      });
    }

    setState(() {
      _waitingForOperand = true;
      _operator = nextOperator;
    });
  }

  String _getOperatorSymbol(String operator) {
    switch (operator) {
      case '+':
        return '+';
      case '-':
        return '−';
      case '*':
        return '×';
      case '/':
        return '÷';
      default:
        return operator;
    }
  }

  double _calculate(
    double firstOperand,
    double secondOperand,
    String operator,
  ) {
    switch (operator) {
      case '+':
        return firstOperand + secondOperand;
      case '-':
        return firstOperand - secondOperand;
      case '*':
        return firstOperand * secondOperand;
      case '/':
        return firstOperand / secondOperand;
      default:
        return secondOperand;
    }
  }

  String _formatResult(double result) {
    if (result == result.roundToDouble()) {
      return result.round().toString();
    } else {
      return result.toString();
    }
  }

  void _inputEquals() {
    double inputValue = double.parse(_display);

    if (_previousValue.isNotEmpty && _operator.isNotEmpty) {
      double previousValue = double.parse(_previousValue);
      double result = _calculate(previousValue, inputValue, _operator);

      setState(() {
        _expression = _expression + _display;
        _display = _formatResult(result);
        _previousValue = '';
        _operator = '';
        _waitingForOperand = true;
      });
    }
  }

  void _clear() {
    setState(() {
      _display = '0';
      _expression = '';
      _previousValue = '';
      _operator = '';
      _waitingForOperand = false;
    });
  }

  void _inputDecimal() {
    if (_waitingForOperand) {
      setState(() {
        _display = '0.';
        _waitingForOperand = false;
      });
    } else if (!_display.contains('.')) {
      setState(() {
        _display = '$_display.';
      });
    }
  }

  void _backspace() {
    if (_display.length > 1) {
      setState(() {
        _display = _display.substring(0, _display.length - 1);
      });
    } else {
      setState(() {
        _display = '0';
      });
    }
  }

  // Light and Dark mode toggle
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Theme toggle at top center
          Container(
            padding: EdgeInsets.only(top: 50, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Custom Toggle Switch
                GestureDetector(
                  onTap: () {
                    ThemeMode newTheme = widget.themeMode == ThemeMode.light
                        ? ThemeMode.dark
                        : ThemeMode.light;
                    widget.onThemeChanged(newTheme);
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 100),
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: widget.themeMode == ThemeMode.dark
                          ? Color(0xFF2C2C2E) // Dark background
                          : Color(0xFFE5E5E5), // Light background
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Icons positioned in background
                        Positioned(
                          left: 8,
                          top: 8,
                          child: Icon(
                            Icons.wb_sunny_outlined,
                            size: 24,
                            color: widget.themeMode == ThemeMode.light
                                ? Colors.blue
                                // ignore: deprecated_member_use
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Icon(
                            Icons.nightlight_round,
                            size: 24,
                            color: widget.themeMode == ThemeMode.dark
                                ? Colors.blue
                                // ignore: deprecated_member_use
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        // Sliding circle
                        AnimatedPositioned(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          left: widget.themeMode == ThemeMode.dark ? 40 : 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.themeMode == ThemeMode.dark
                                  ? Icons.nightlight_round
                                  : Icons.wb_sunny_outlined,
                              color: widget.themeMode == ThemeMode.dark
                                  ? Colors.blue
                                  : Colors.blue,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Calculator display area
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Expression/calculation history at top
                  Container(
                    height: 60,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _expression.isEmpty ? '' : _expression,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 15),
                  // Current display/result at bottom
                  Text(
                    _display,
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),

          // Calculator buttons
          Expanded(
            flex: 4,
            child: CalculatorButtons(
              onNumberPressed: _inputNumber,
              onOperatorPressed: _inputOperator,
              onEqualsPressed: _inputEquals,
              onClearPressed: _clear,
              onDecimalPressed: _inputDecimal,
              onBackspacePressed: _backspace,
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorButtons extends StatelessWidget {
  final Function(String) onNumberPressed;
  final Function(String) onOperatorPressed;
  final Function() onEqualsPressed;
  final Function() onClearPressed;
  final Function() onDecimalPressed;
  final Function() onBackspacePressed;

  const CalculatorButtons({
    super.key,
    required this.onNumberPressed,
    required this.onOperatorPressed,
    required this.onEqualsPressed,
    required this.onClearPressed,
    required this.onDecimalPressed,
    required this.onBackspacePressed,
  });

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    double flex = 1,
  }) {
    return Expanded(
      flex: flex.round(),
      child: Container(
        margin: EdgeInsets.all(3),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            padding: EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            shadowColor: const Color.fromARGB(0, 0, 0, 1),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final numberColor = isDark
        ? Color.fromARGB(255, 45, 46, 54)
        : Color(0xFFFFFFFF);
    final operatorColor = Colors.blue;
    final operatorTextColor = Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final topOperatorColor = isDark
        ? Color.fromARGB(255, 72, 73, 87)
        : Color.fromARGB(255, 199, 200, 214);

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Row 1
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton(
                  text: 'C',
                  onPressed: onClearPressed,
                  backgroundColor: topOperatorColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '+/-',
                  onPressed: () {},
                  backgroundColor: topOperatorColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '%',
                  onPressed: () => onOperatorPressed('%'),
                  backgroundColor: topOperatorColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '÷',
                  onPressed: () => onOperatorPressed('/'),
                  backgroundColor: Colors.blue,
                  textColor: operatorTextColor,
                ),
              ],
            ),
          ),
          // Row 2
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton(
                  text: '7',
                  onPressed: () => onNumberPressed('7'),
                  backgroundColor: numberColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '8',
                  onPressed: () => onNumberPressed('8'),
                  backgroundColor: numberColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '9',
                  onPressed: () => onNumberPressed('9'),
                  backgroundColor: numberColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '×',
                  onPressed: () => onOperatorPressed('*'),
                  backgroundColor: operatorColor,
                  textColor: operatorTextColor,
                ),
              ],
            ),
          ),
          // Row 3
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton(
                  text: '4',
                  onPressed: () => onNumberPressed('4'),
                  backgroundColor: numberColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '5',
                  onPressed: () => onNumberPressed('5'),
                  backgroundColor: numberColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '6',
                  onPressed: () => onNumberPressed('6'),
                  backgroundColor: numberColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '−',
                  onPressed: () => onOperatorPressed('-'),
                  backgroundColor: operatorColor,
                  textColor: operatorTextColor,
                ),
              ],
            ),
          ),
          // Row 4
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton(
                  text: '1',
                  onPressed: () => onNumberPressed('1'),
                  backgroundColor: numberColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '2',
                  onPressed: () => onNumberPressed('2'),
                  backgroundColor: numberColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '3',
                  onPressed: () => onNumberPressed('3'),
                  backgroundColor: numberColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '+',
                  onPressed: () => onOperatorPressed('+'),
                  backgroundColor: operatorColor,
                  textColor: operatorTextColor,
                ),
              ],
            ),
          ),
          // Row 5
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildButton(
                  text: '.',
                  onPressed: onDecimalPressed,
                  backgroundColor: numberColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '0',
                  onPressed: () => onNumberPressed('0'),
                  backgroundColor: numberColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '⌫',
                  onPressed: onBackspacePressed,
                  backgroundColor: numberColor,
                  textColor: textColor,
                ),
                _buildButton(
                  text: '=',
                  onPressed: onEqualsPressed,
                  backgroundColor: operatorColor,
                  textColor: operatorTextColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
