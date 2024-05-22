import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
        create: (context) => ThemeNotifier(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: const CommonSwipeButton(
        buttonWidth: 200,
        buttonHeight: 100,
        dark: false,
      ),
    );
  }
}

class CommonSwipeButton extends StatefulWidget {
  final bool dark; // can we change the initial theme
  final double buttonHeight;
  final double buttonWidth;

  const CommonSwipeButton(
      {super.key,
      this.dark = true,
      this.buttonHeight = 90,
      this.buttonWidth = 200});

  @override
  State<CommonSwipeButton> createState() => _CommonSwipeButtonState();
}

class _CommonSwipeButtonState extends State<CommonSwipeButton> {
  double buttonPosition = 0.0;
  bool isSwiped = false;
  double maxButtonPosition = 0;
  double buttonHeight = 0;
  bool dark = false;
  bool turn = false;

  @override
  void initState() {
    dark = widget.dark;
    _toggleTheme(dark);
    if (widget.buttonHeight > 100) {
      buttonHeight = 100;
    }
    buttonHeight = widget.buttonHeight;
    maxButtonPosition = widget.buttonWidth - buttonHeight + 2;
    super.initState();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      buttonPosition += details.delta.dx;
      buttonPosition = buttonPosition.clamp(0.0, maxButtonPosition);
      if (buttonPosition >= maxButtonPosition) {
        buttonPosition = maxButtonPosition;
        isSwiped = true;
      } else if (buttonPosition < 0) {
        buttonPosition = 0;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (buttonPosition < maxButtonPosition) {
      _toggleTheme(dark);
      Future.microtask(() {
        setState(() {
          buttonPosition = 0.0;
        });
      });
    } else {
      _toggleTheme(!dark);
    }
  }

  void _toggleTheme(bool isDark) {
    Future.microtask(() {
      final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
      themeNotifier.toggleTheme(isDark);
    });
  }

  bool turnLight(double n) {
    bool lightTrn = false;
    if (dark == true && (buttonPosition > maxButtonPosition / n)) {
      lightTrn = (buttonPosition > maxButtonPosition / n);
    } else if (dark == false && (buttonPosition > maxButtonPosition / n)) {
      lightTrn = (buttonPosition < maxButtonPosition * (n - 1) / n);
    }
    turn = lightTrn;
    return dark ? lightTrn : (buttonPosition < maxButtonPosition * (n - 1) / n);
  }

  bool turnDark(double n) {
    bool darkTrn = false;
    if (dark == true && (buttonPosition < maxButtonPosition / n)) {
      darkTrn = (buttonPosition < maxButtonPosition / n);
    } else if (dark == false && (buttonPosition < maxButtonPosition / n)) {
      darkTrn = (buttonPosition > maxButtonPosition * (n - 1) / n);
    }
    turn = darkTrn;
    return dark ? darkTrn : (buttonPosition > maxButtonPosition * (n - 1) / n);
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: colorTheme.background,
      body: Center(
        child: Stack(
          children: [
            _buildBackground(screenSize),
            _buildButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(Size screenSize) {
    return Container(
      width: widget.buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            turnLight(2) ? const Color(0xFF86C988) : const Color(0xFF111F51),
            turnLight(2) ? const Color(0xFFA8FFAC) : const Color(0xFF364BBA),
            turnLight(2) ? const Color(0xFFA8FFAC) : const Color(0xFF364BBA),
            turnLight(2) ? const Color(0xFF9FDEF2) : const Color(0xFFA979D9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: turnLight(2)
                ? Colors.transparent
                : Colors.black.withOpacity(0.35),
            offset: const Offset(0, -3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: turnLight(2)
                ? const Color(0xFF86C988)
                : const Color(0xFF111F51),
            blurRadius: 0,
            spreadRadius: -0.8,
            offset: const Offset(0, -3),
          ),
          BoxShadow(
            color: turnLight(2)
                ? const Color(0xFF4C868A)
                : const Color(0xFF463B80),
            blurRadius: 0,
            spreadRadius: -0.8,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(100),
      ),
      child: Stack(
        children: [
          _buildStars(screenSize),
          _buildMoon(screenSize),
          _buildSun(screenSize),
          turnDark(2)
              ? Positioned(
                  top: buttonHeight / 2,
                  child: SizedBox(
                    height: buttonHeight / 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft:
                            Radius.circular(70 - (widget.buttonWidth / 10)),
                        bottomRight:
                            Radius.circular(70 - (widget.buttonWidth / 10)),
                      ),
                      child: SvgPicture.asset(
                        "assets/images/dark.svg",
                        fit: BoxFit.fill,
                        alignment: Alignment.bottomCenter,
                        width: widget.buttonWidth,
                      ),
                    ),
                  ),
                )
              : Positioned(
                  top: buttonHeight / 2,
                  child: SizedBox(
                    height: buttonHeight / 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft:
                            Radius.circular(70 - (widget.buttonWidth / 10)),
                        bottomRight:
                            Radius.circular(70 - (widget.buttonWidth / 10)),
                      ),
                      child: SvgPicture.asset(
                        "assets/images/light.svg",
                        fit: BoxFit.fill,
                        alignment: Alignment.bottomCenter,
                        width: widget.buttonWidth,
                      ),
                    ),
                  ),
                )
          // _buildLight(imageBottomPosition, screenSize),
        ],
      ),
    );
  }

  Widget _buildStars(Size screenSize) {
    return turnDark(2)
        ? AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: turnLight(5) ? 0 : buttonHeight / 2,
            left: widget.buttonWidth / 10,
            right: widget.buttonWidth / 10,
            child: Image.asset(
              "assets/images/stars.png",
              height: buttonHeight / 2,
              width: widget.buttonWidth,
              fit: BoxFit.fitHeight,
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildMoon(Size screenSize) {
    return turnDark(2)
        ? AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: turn ? screenSize.width / 3 : 16,
            bottom: turnLight(3) ? 0 : buttonHeight / 2.5,
            child: Image.asset("assets/images/moon.png",
                width: buttonHeight / 3, height: buttonHeight / 3),
          )
        : const SizedBox.shrink();
  }

  Widget _buildSun(Size screenSize) {
    return turnLight(2)
        ? AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: turn ? screenSize.width / 3 : 16,
            bottom: turnLight(1.5) ? buttonHeight / 2.5 : 10,
            child: Image.asset("assets/images/sun.png",
                width: buttonHeight / 3, height: buttonHeight / 3),
          )
        : const SizedBox.shrink();
  }

  Widget _buildButton() {
    final colorTheme = Theme.of(context).colorScheme;
    return AnimatedPositioned(
      left: buttonPosition,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          width: buttonHeight - 20,
          height: buttonHeight - 20,
          decoration: BoxDecoration(
            color: colorTheme.background,
            borderRadius: BorderRadius.circular(100.0),
          ),
        ),
      ),
    );
  }
}

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool startItemDark) {
    _isDarkMode = startItemDark;
    notifyListeners();
  }
}
