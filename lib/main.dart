import 'package:flutter/material.dart';
import 'dart:math' as Math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robot Color Animation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RobotAnimationScreen(),
    );
  }
}

class RobotAnimationScreen extends StatefulWidget {
  @override
  _RobotAnimationScreenState createState() => _RobotAnimationScreenState();
}

class _RobotAnimationScreenState extends State<RobotAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _colorController;
  late AnimationController _shapeGrowController; 
  late AnimationController _shapeRotationController; 
  late AnimationController _shakeController;
  late AnimationController _verticalController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _shapeGrowAnimation; 
  late Animation<double> _shapeRotationAnimation; 
  late Animation<double> _shakeAnimation;
  late Animation<double> _verticalAnimation;
  
  Color currentColor = Colors.green;
  String currentShape = 'circle';
  bool isStarted = false; 
  
  @override
  void initState() {
    super.initState();
    
    _colorController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shapeGrowController = AnimationController(
      duration: Duration(milliseconds: 1200), 
      vsync: this,
    );
    
    _shapeRotationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _verticalController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.green,
      end: Colors.green,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));
    
    _shapeGrowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shapeGrowController,
      curve: Curves.easeOutBack, 
    ));

    _shapeRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * Math.pi,
    ).animate(CurvedAnimation(
      parent: _shapeRotationController,
      curve: Curves.easeInOut,
    ));
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));
    
    _verticalAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _verticalController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _colorController.dispose();
    _shapeGrowController.dispose();
    _shapeRotationController.dispose();
    _shakeController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    setState(() {
      isStarted = true;
    });

    _verticalController.repeat(reverse: true);
    _shapeGrowController.forward();
    _shapeRotationController.forward();
  }

  void _changeColor(Color newColor, String shape) {
    setState(() {
      _colorAnimation = ColorTween(
        begin: currentColor,
        end: newColor,
      ).animate(CurvedAnimation(
        parent: _colorController,
        curve: Curves.easeInOut,
      ));
      currentColor = newColor;
      currentShape = shape;
    });
    
    _shakeController.reset();
    _shakeController.forward();
    
    _colorController.reset();
    _colorController.forward();
    
    _shapeGrowController.reset();
    _shapeGrowController.forward();
    
    _shapeRotationController.reset();
    _shapeRotationController.forward();
    
    _verticalController.stop();
    _verticalController.duration = _getVerticalDuration();
    _verticalController.repeat(reverse: true);
  }

  Duration _getVerticalDuration() {
    switch (currentShape) {
      case 'circle': 
        return Duration(seconds: 3);
      case 'triangle': 
        return Duration(milliseconds: 1500);
      case 'square':
        return Duration(milliseconds: 2500);
      default:
        return Duration(seconds: 2);
    }
  }

  Widget _buildControlButton(IconData icon, Color color, String shape, VoidCallback onTap, 
      Size screenSize, {bool isCircle = false}) {
    bool isActive = currentShape == shape;
    

    double buttonSize = screenSize.width < 600 ? 
        Math.min(screenSize.width * 0.12, 60) : 60;
    double iconSize = buttonSize * 0.58;
    double margin = screenSize.width < 600 ? 8 : 15;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: buttonSize,
        height: buttonSize,
        margin: EdgeInsets.symmetric(horizontal: margin),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : color.withOpacity(0.05),
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(12),
          border: Border.all(
            color: color, 
            width: isActive ? 3 : 2
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildStartButton(Size screenSize) {
    // Responsive start button sizing
    double buttonSize = screenSize.width < 600 ? 
        Math.min(screenSize.width * 0.2, 100) : 100;
    double iconSize = buttonSize * 0.5;
    
    return GestureDetector(
      onTap: _startAnimation,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isLandscape = screenSize.width > screenSize.height;

    double robotContainerSize = isSmallScreen ? 
        Math.min(screenSize.width * 0.8, screenSize.height * 0.4) : 
        Math.min(350.0, screenSize.width * 0.4);
    
    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: isLandscape && isStarted ? 
              _buildLandscapeLayout(screenSize, robotContainerSize) :
              _buildPortraitLayout(screenSize, robotContainerSize),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(Size screenSize, double robotContainerSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isStarted) 
            Container(
              margin: EdgeInsets.only(
                top: screenSize.height * 0.05, 
                bottom: screenSize.height * 0.03
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlButton(
                    Icons.stop,
                    Colors.red,
                    'square',
                    () => _changeColor(Colors.red, 'square'),
                    screenSize,
                  ),
                  
                  _buildControlButton(
                    Icons.circle,
                    Colors.green,
                    'circle',
                    () => _changeColor(Colors.green, 'circle'),
                    screenSize,
                    isCircle: true,
                  ),
                  
                  _buildControlButton(
                    Icons.play_arrow,
                    Color(0xFF8B5FBF),
                    'triangle',
                    () => _changeColor(Color(0xFF8B5FBF), 'triangle'),
                    screenSize,
                  ),
                ],
              ),
            ),
          
          if (!isStarted) ...[
            Container(
              width: robotContainerSize,
              height: robotContainerSize,
              child: Center(
                child: _buildStartButton(screenSize),
              ),
            ),
          ] else ...[
            AnimatedBuilder(
              animation: Listenable.merge([_colorAnimation, _shapeGrowAnimation, _shapeRotationAnimation, _shakeAnimation, _verticalAnimation]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    Math.sin(_shakeAnimation.value * 4 * Math.pi) * 5,
                    Math.cos(_shakeAnimation.value * 6 * Math.pi) * 3 + _verticalAnimation.value,
                  ),
                  child: Container(
                    width: robotContainerSize,
                    height: robotContainerSize,
                    child: CustomPaint(
                      painter: RobotPainter(
                        _colorAnimation.value ?? currentColor,
                        currentShape,
                        _shapeGrowAnimation.value,
                        _shapeRotationAnimation.value,
                        robotContainerSize,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(Size screenSize, double robotContainerSize) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Expanded(
            flex: 2,
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_colorAnimation, _shapeGrowAnimation, _shapeRotationAnimation, _shakeAnimation, _verticalAnimation]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      Math.sin(_shakeAnimation.value * 4 * Math.pi) * 5,
                      Math.cos(_shakeAnimation.value * 6 * Math.pi) * 3 + _verticalAnimation.value,
                    ),
                    child: Container(
                      width: robotContainerSize,
                      height: robotContainerSize,
                      child: CustomPaint(
                        painter: RobotPainter(
                          _colorAnimation.value ?? currentColor,
                          currentShape,
                          _shapeGrowAnimation.value,
                          _shapeRotationAnimation.value,
                          robotContainerSize,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
  
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlButton(
                    Icons.stop,
                    Colors.red,
                    'square',
                    () => _changeColor(Colors.red, 'square'),
                    screenSize,
                  ),
                  
                  SizedBox(height: 20),
                  
                  _buildControlButton(
                    Icons.circle,
                    Colors.green,
                    'circle',
                    () => _changeColor(Colors.green, 'circle'),
                    screenSize,
                    isCircle: true,
                  ),
                  
                  SizedBox(height: 20),
                  
                  _buildControlButton(
                    Icons.play_arrow,
                    Color(0xFF8B5FBF),
                    'triangle',
                    () => _changeColor(Color(0xFF8B5FBF), 'triangle'),
                    screenSize,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RobotPainter extends CustomPainter {
  final Color robotColor;
  final String currentShape;
  final double growValue; 
  final double rotationValue;
  final double containerSize;
  
  RobotPainter(this.robotColor, this.currentShape, this.growValue, this.rotationValue, this.containerSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = containerSize * 0.006 // Responsive stroke width
      ..color = Colors.grey.shade600;

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    

    double scaleFactor = containerSize / 350.0;

    _drawBackgroundShapes(canvas, size, centerX, centerY, scaleFactor);

    paint.color = robotColor;
    RRect bodyRect = RRect.fromLTRBR(
      centerX - (50 * scaleFactor), 
      centerY - (10 * scaleFactor), 
      centerX + (50 * scaleFactor), 
      centerY + (90 * scaleFactor),
      Radius.circular(25 * scaleFactor) 
    );
    canvas.drawRRect(bodyRect, paint);
    canvas.drawRRect(bodyRect, strokePaint);

    paint.color = Colors.grey.shade700;
    canvas.drawCircle(
      Offset(centerX, centerY - (30 * scaleFactor)),
      45 * scaleFactor, 
      paint
    );
    canvas.drawCircle(
      Offset(centerX, centerY - (30 * scaleFactor)),
      45 * scaleFactor,
      strokePaint
    );

    paint.color = Colors.grey.shade800;
    canvas.drawCircle(
      Offset(centerX, centerY - (30 * scaleFactor)),
      35 * scaleFactor, 
      paint
    );

    paint.color = Colors.white.withOpacity(0.2);
    canvas.drawCircle(
      Offset(centerX - (10 * scaleFactor), centerY - (40 * scaleFactor)),
      15 * scaleFactor,
      paint
    );

    _drawEmotionalFace(canvas, paint, centerX, centerY, scaleFactor);


    paint.color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(
      Offset(centerX, centerY + (25 * scaleFactor)),
      20 * scaleFactor,
      paint
    );
    
    strokePaint.color = Colors.grey.shade400;
    canvas.drawCircle(
      Offset(centerX, centerY + (25 * scaleFactor)),
      20 * scaleFactor,
      strokePaint
    );


    paint.color = robotColor;
    Path trianglePath = Path();
    trianglePath.moveTo(centerX - (8 * scaleFactor), centerY + (15 * scaleFactor));
    trianglePath.lineTo(centerX + (12 * scaleFactor), centerY + (25 * scaleFactor));
    trianglePath.lineTo(centerX - (8 * scaleFactor), centerY + (35 * scaleFactor));
    trianglePath.close();
    canvas.drawPath(trianglePath, paint);

    strokePaint.color = robotColor.withOpacity(0.6);
    strokePaint.strokeWidth = 2 * scaleFactor;
    canvas.drawLine(
      Offset(centerX - (30 * scaleFactor), centerY + (55 * scaleFactor)),
      Offset(centerX + (30 * scaleFactor), centerY + (55 * scaleFactor)),
      strokePaint
    );
    canvas.drawLine(
      Offset(centerX - (30 * scaleFactor), centerY + (65 * scaleFactor)),
      Offset(centerX + (30 * scaleFactor), centerY + (65 * scaleFactor)),
      strokePaint
    );


    paint.color = robotColor;
    strokePaint.color = Colors.grey.shade600;
    strokePaint.strokeWidth = 2 * scaleFactor;
    
    canvas.drawCircle(
      Offset(centerX - (70 * scaleFactor), centerY + (20 * scaleFactor)),
      18 * scaleFactor,
      paint
    );
    canvas.drawCircle(
      Offset(centerX - (70 * scaleFactor), centerY + (20 * scaleFactor)),
      18 * scaleFactor,
      strokePaint
    );

    canvas.drawCircle(
      Offset(centerX + (70 * scaleFactor), centerY + (20 * scaleFactor)),
      18 * scaleFactor,
      paint
    );
    canvas.drawCircle(
      Offset(centerX + (70 * scaleFactor), centerY + (20 * scaleFactor)),
      18 * scaleFactor,
      strokePaint
    );


    paint.color = robotColor.withOpacity(0.8);
    RRect baseRect = RRect.fromLTRBR(
      centerX - (35 * scaleFactor), 
      centerY + (75 * scaleFactor), 
      centerX + (35 * scaleFactor), 
      centerY + (90 * scaleFactor),
      Radius.circular(10 * scaleFactor)
    );
    canvas.drawRRect(baseRect, paint);
    canvas.drawRRect(baseRect, strokePaint);
  }

  void _drawEmotionalFace(Canvas canvas, Paint paint, double centerX, double centerY, double scaleFactor) {
    switch (currentShape) {
      case 'circle':
        _drawHappyFace(canvas, paint, centerX, centerY, scaleFactor);
        break;
      case 'triangle':
        _drawCryingFace(canvas, paint, centerX, centerY, scaleFactor);
        break;
      case 'square':
        _drawSadFace(canvas, paint, centerX, centerY, scaleFactor);
        break;
    }
  }

  void _drawHappyFace(Canvas canvas, Paint paint, double centerX, double centerY, double scaleFactor) {
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX - (15 * scaleFactor), centerY - (40 * scaleFactor)), 4 * scaleFactor, paint);
    canvas.drawCircle(Offset(centerX + (15 * scaleFactor), centerY - (40 * scaleFactor)), 4 * scaleFactor, paint);

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3 * scaleFactor;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX, centerY - (25 * scaleFactor)), 
        width: 25 * scaleFactor, 
        height: 15 * scaleFactor
      ),
      0, Math.pi, false, paint
    );
  }

  void _drawCryingFace(Canvas canvas, Paint paint, double centerX, double centerY, double scaleFactor) {
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3 * scaleFactor;
    
    canvas.drawLine(
      Offset(centerX - (20 * scaleFactor), centerY - (40 * scaleFactor)),
      Offset(centerX - (10 * scaleFactor), centerY - (40 * scaleFactor)),
      paint
    );
    
    canvas.drawLine(
      Offset(centerX + (10 * scaleFactor), centerY - (40 * scaleFactor)),
      Offset(centerX + (20 * scaleFactor), centerY - (40 * scaleFactor)),
      paint
    );

    paint.style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY - (20 * scaleFactor)), 
        width: 8 * scaleFactor, 
        height: 12 * scaleFactor
      ),
      paint
    );

    paint.color = Colors.lightBlue;
    canvas.drawCircle(Offset(centerX - (18 * scaleFactor), centerY - (35 * scaleFactor)), 2 * scaleFactor, paint);
    canvas.drawCircle(Offset(centerX + (18 * scaleFactor), centerY - (35 * scaleFactor)), 2 * scaleFactor, paint);
  }

  void _drawSadFace(Canvas canvas, Paint paint, double centerX, double centerY, double scaleFactor) {
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX - (15 * scaleFactor), centerY - (40 * scaleFactor)), 3 * scaleFactor, paint);
    canvas.drawCircle(Offset(centerX + (15 * scaleFactor), centerY - (40 * scaleFactor)), 3 * scaleFactor, paint);

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3 * scaleFactor;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX, centerY - (15 * scaleFactor)), 
        width: 20 * scaleFactor, 
        height: 15 * scaleFactor
      ),
      Math.pi, Math.pi, false, paint
    );
  }

  void _drawBackgroundShapes(Canvas canvas, Size size, double centerX, double centerY, double scaleFactor) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 * scaleFactor;

    paint.color = robotColor.withOpacity(0.15);
    
    canvas.save();
    canvas.translate(centerX, centerY);
    double scaleValue = growValue;
    canvas.scale(scaleValue);
    canvas.rotate(rotationValue);
    
    switch (currentShape) {
      case 'circle':
        _drawCircle(canvas, paint, 120 * scaleFactor);
        break;
      case 'square':
        _drawSquare(canvas, paint, 120 * scaleFactor);
        break;
      case 'triangle':
        _drawTriangle(canvas, paint, 120 * scaleFactor);
        break;
    }
    canvas.restore();

    paint.strokeWidth = 10 * scaleFactor;
    paint.color = robotColor.withOpacity(0.2);
    
    canvas.save();
    canvas.translate(centerX - (180 * scaleFactor), centerY);
    canvas.scale(scaleValue);
    canvas.rotate(rotationValue * 0.8);
    switch (currentShape) {
      case 'circle':
        _drawCircle(canvas, paint, 12 * scaleFactor);
        break;
      case 'square':
        _drawSquare(canvas, paint, 12 * scaleFactor);
        break;
      case 'triangle':
        _drawTriangle(canvas, paint, 12 * scaleFactor);
        break;
    }
    canvas.restore();
    
    canvas.save();
    canvas.translate(centerX + (180 * scaleFactor), centerY - (40 * scaleFactor));
    canvas.scale(scaleValue); 
    canvas.rotate(rotationValue * 1.2);
    switch (currentShape) {
      case 'circle':
        _drawCircle(canvas, paint, 10 * scaleFactor);
        break;
      case 'square':
        _drawSquare(canvas, paint, 10 * scaleFactor);
        break;
      case 'triangle':
        _drawTriangle(canvas, paint, 10 * scaleFactor);
        break;
    }
    canvas.restore();
    
    canvas.save();
    canvas.translate(centerX + (180 * scaleFactor), centerY + (40 * scaleFactor));
    canvas.scale(scaleValue); 
    canvas.rotate(rotationValue * 0.6); 
    switch (currentShape) {
      case 'circle':
        _drawCircle(canvas, paint, 8 * scaleFactor);
        break;
      case 'square':
        _drawSquare(canvas, paint, 8 * scaleFactor);
        break;
      case 'triangle':
        _drawTriangle(canvas, paint, 8 * scaleFactor);
        break;
    }
    canvas.restore();
  }

  void _drawCircle(Canvas canvas, Paint paint, double size) {
    canvas.drawCircle(Offset.zero, size, paint);
    
    double originalWidth = paint.strokeWidth;
    paint.strokeWidth = Math.max(containerSize * 0.028, originalWidth * 0.5);
    canvas.drawCircle(Offset.zero, size * 0.6, paint);
    paint.strokeWidth = originalWidth;
  }

  void _drawSquare(Canvas canvas, Paint paint, double size) {
    Rect rect = Rect.fromCenter(center: Offset.zero, width: size * 2, height: size * 2);
    canvas.drawRect(rect, paint);
    
    double originalWidth = paint.strokeWidth;
    paint.strokeWidth = Math.max(containerSize * 0.028, originalWidth * 0.5);
    Rect innerRect = Rect.fromCenter(center: Offset.zero, width: size * 1.2, height: size * 1.2);
    canvas.drawRect(innerRect, paint);
    paint.strokeWidth = originalWidth;
  }

  void _drawTriangle(Canvas canvas, Paint paint, double size) {
    Path path = Path();
    path.moveTo(0, -size);
    path.lineTo(-size * 0.866, size * 0.5);
    path.lineTo(size * 0.866, size * 0.5);
    path.close();
    canvas.drawPath(path, paint);
    
    double originalWidth = paint.strokeWidth;
    paint.strokeWidth = Math.max(containerSize * 0.028, originalWidth * 0.5);
    Path innerPath = Path();
    innerPath.moveTo(0, -size * 0.6);
    innerPath.lineTo(-size * 0.52, size * 0.3);
    innerPath.lineTo(size * 0.52, size * 0.3);
    innerPath.close();
    canvas.drawPath(innerPath, paint);
    paint.strokeWidth = originalWidth;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}