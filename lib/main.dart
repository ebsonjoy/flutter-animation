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
  late AnimationController _shapeRotationController;
  late AnimationController _shakeController;
  late AnimationController _verticalController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _shapeRotationAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _verticalAnimation;
  
  Color currentColor = Colors.green;
  String currentShape = 'circle'; // circle, square, triangle
  bool isStarted = false; // Track if animation has started
  
  @override
  void initState() {
    super.initState();
    
    // Color transition controller
    _colorController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Shape rotation controller (for background shape rotation when button clicked)
    _shapeRotationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Shake controller for robot
    _shakeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Vertical movement controller for robot up/down movement
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
    _shapeRotationController.dispose();
    _shakeController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    setState(() {
      isStarted = true;
    });
    // Start only robot vertical movement (up and down)
    _verticalController.repeat(reverse: true);
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
    
    // Trigger shake animation for robot
    _shakeController.reset();
    _shakeController.forward();
    
    // Trigger color transition
    _colorController.reset();
    _colorController.forward();
    
    // Trigger background shape rotation animation (only rotates, doesn't move)
    _shapeRotationController.reset();
    _shapeRotationController.forward();
    
    // Update vertical animation speed based on emotion
    _verticalController.stop();
    _verticalController.duration = _getVerticalDuration();
    _verticalController.repeat(reverse: true);
  }

  Duration _getVerticalDuration() {
    switch (currentShape) {
      case 'circle': // Happy - slow movement
        return Duration(seconds: 3);
      case 'triangle': // Crying - medium movement
        return Duration(milliseconds: 1500);
      case 'square': // Sad - slow movement
        return Duration(milliseconds: 2500);
      default:
        return Duration(seconds: 2);
    }
  }

  Widget _buildControlButton(IconData icon, Color color, String shape, VoidCallback onTap, {bool isCircle = false}) {
    bool isActive = currentShape == shape;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 60,
        height: 60,
        margin: EdgeInsets.symmetric(horizontal: 15),
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
          size: 35,
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _startAnimation,
      child: Container(
        width: 100,
        height: 100,
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
          size: 50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Control Buttons - show at top after start
            if (isStarted) 
              Container(
                margin: EdgeInsets.only(top: 60, bottom: 40),
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Square Button (Red) - Sad face
                    _buildControlButton(
                      Icons.stop,
                      Colors.red,
                      'square',
                      () => _changeColor(Colors.red, 'square'),
                    ),
                    
                    // Circle Button (Green) - Happy face
                    _buildControlButton(
                      Icons.circle,
                      Colors.green,
                      'circle',
                      () => _changeColor(Colors.green, 'circle'),
                      isCircle: true,
                    ),
                    
                    // Triangle Button (Purple) - Crying face
                    _buildControlButton(
                      Icons.play_arrow,
                      Color(0xFF8B5FBF),
                      'triangle',
                      () => _changeColor(Color(0xFF8B5FBF), 'triangle'),
                    ),
                  ],
                ),
              ),
            
            if (!isStarted) ...[
              // Show only play button initially
              Container(
                width: 350,
                height: 350,
                child: Center(
                  child: _buildStartButton(),
                ),
              ),
            ] else ...[
              // Show robot animation after start - only robot moves up and down
              AnimatedBuilder(
                animation: Listenable.merge([_colorAnimation, _shapeRotationAnimation, _shakeAnimation, _verticalAnimation]),
                builder: (context, child) {
                  return Transform.translate(
                    // Only robot moves with shake and vertical movement
                    offset: Offset(
                      Math.sin(_shakeAnimation.value * 4 * Math.pi) * 5,
                      Math.cos(_shakeAnimation.value * 6 * Math.pi) * 3 + _verticalAnimation.value,
                    ),
                    child: Container(
                      width: 350,
                      height: 350,
                      child: CustomPaint(
                        painter: RobotPainter(
                          _colorAnimation.value ?? currentColor,
                          currentShape,
                          _shapeRotationAnimation.value,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RobotPainter extends CustomPainter {
  final Color robotColor;
  final String currentShape;
  final double rotationValue;
  
  RobotPainter(this.robotColor, this.currentShape, this.rotationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.black54;

    double centerX = size.width / 2;
    double centerY = size.height / 2;

    // Draw background shapes first (behind the robot)
    _drawBackgroundShapes(canvas, size, centerX, centerY);

    // Robot body (main body)
    paint.color = robotColor;
    RRect bodyRect = RRect.fromLTRBR(
      centerX - 60, centerY - 20, centerX + 60, centerY + 80,
      Radius.circular(20)
    );
    canvas.drawRRect(bodyRect, paint);
    canvas.drawRRect(bodyRect, strokePaint);

    // Robot head (helmet/visor)
    paint.color = Colors.grey.shade700;
    RRect headRect = RRect.fromLTRBR(
      centerX - 50, centerY - 60, centerX + 50, centerY + 10,
      Radius.circular(25)
    );
    canvas.drawRRect(headRect, paint);
    canvas.drawRRect(headRect, strokePaint);

    // Visor/Screen with reflection
    paint.color = Colors.grey.shade800;
    RRect visorRect = RRect.fromLTRBR(
      centerX - 40, centerY - 45, centerX + 40, centerY - 5,
      Radius.circular(20)
    );
    canvas.drawRRect(visorRect, paint);

    // Visor reflection
    paint.color = Colors.white.withOpacity(0.2);
    RRect reflectionRect = RRect.fromLTRBR(
      centerX - 35, centerY - 40, centerX - 10, centerY - 25,
      Radius.circular(15)
    );
    canvas.drawRRect(reflectionRect, paint);

    // Draw emotional face based on current shape
    _drawEmotionalFace(canvas, paint, centerX, centerY);

    // Play button triangle on chest
    paint.color = Colors.white;
    Path trianglePath = Path();
    trianglePath.moveTo(centerX - 8, centerY + 15);
    trianglePath.lineTo(centerX + 12, centerY + 30);
    trianglePath.lineTo(centerX - 8, centerY + 45);
    trianglePath.close();
    canvas.drawPath(trianglePath, paint);

    // Body details (animated lines)
    strokePaint.color = robotColor.withOpacity(0.8);
    strokePaint.strokeWidth = 2;
    canvas.drawLine(
      Offset(centerX - 30, centerY + 55),
      Offset(centerX + 30, centerY + 55),
      strokePaint
    );
    canvas.drawLine(
      Offset(centerX - 30, centerY + 65),
      Offset(centerX + 30, centerY + 65),
      strokePaint
    );

    // Arms
    paint.color = robotColor;
    strokePaint.color = Colors.black54;
    strokePaint.strokeWidth = 3;
    
    // Left arm
    RRect leftArm = RRect.fromLTRBR(
      centerX - 90, centerY + 10, centerX - 60, centerY + 50,
      Radius.circular(15)
    );
    canvas.drawRRect(leftArm, paint);
    canvas.drawRRect(leftArm, strokePaint);

    // Right arm
    RRect rightArm = RRect.fromLTRBR(
      centerX + 60, centerY + 10, centerX + 90, centerY + 50,
      Radius.circular(15)
    );
    canvas.drawRRect(rightArm, paint);
    canvas.drawRRect(rightArm, strokePaint);

    // Chest panel details
    paint.color = robotColor.withOpacity(0.7);
    canvas.drawRRect(
      RRect.fromLTRBR(centerX - 20, centerY + 55, centerX + 20, centerY + 70, Radius.circular(5)),
      paint
    );
  }

  void _drawEmotionalFace(Canvas canvas, Paint paint, double centerX, double centerY) {
    switch (currentShape) {
      case 'circle': // Happy face
        _drawHappyFace(canvas, paint, centerX, centerY);
        break;
      case 'triangle': // Crying face
        _drawCryingFace(canvas, paint, centerX, centerY);
        break;
      case 'square': // Sad face
        _drawSadFace(canvas, paint, centerX, centerY);
        break;
    }
  }

  void _drawHappyFace(Canvas canvas, Paint paint, double centerX, double centerY) {
    // Happy eyes (crescents)
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    
    // Left eye (happy crescent)
    canvas.drawArc(
      Rect.fromCenter(center: Offset(centerX - 15, centerY - 25), width: 16, height: 12),
      0, Math.pi, false, paint
    );
    
    // Right eye (happy crescent)
    canvas.drawArc(
      Rect.fromCenter(center: Offset(centerX + 15, centerY - 25), width: 16, height: 12),
      0, Math.pi, false, paint
    );

    // Happy mouth (smile)
    canvas.drawArc(
      Rect.fromCenter(center: Offset(centerX, centerY - 15), width: 25, height: 20),
      0, Math.pi, false, paint
    );

    // Eye glow effect
    paint.style = PaintingStyle.fill;
    paint.color = robotColor.withOpacity(0.3);
    canvas.drawCircle(Offset(centerX - 15, centerY - 25), 10, paint);
    canvas.drawCircle(Offset(centerX + 15, centerY - 25), 10, paint);
  }

  void _drawCryingFace(Canvas canvas, Paint paint, double centerX, double centerY) {
    // Crying eyes (closed with tears)
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    
    // Left eye (closed/crying)
    canvas.drawLine(
      Offset(centerX - 22, centerY - 25),
      Offset(centerX - 8, centerY - 25),
      paint
    );
    
    // Right eye (closed/crying)
    canvas.drawLine(
      Offset(centerX + 8, centerY - 25),
      Offset(centerX + 22, centerY - 25),
      paint
    );

    // Crying mouth (open oval)
    paint.style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX, centerY - 10), width: 12, height: 20),
      paint
    );

    // Tears
    paint.color = Colors.lightBlue;
    canvas.drawCircle(Offset(centerX - 18, centerY - 15), 3, paint);
    canvas.drawCircle(Offset(centerX + 18, centerY - 15), 3, paint);
    
    // Tear drops
    Path leftTear = Path();
    leftTear.moveTo(centerX - 18, centerY - 12);
    leftTear.lineTo(centerX - 16, centerY - 5);
    leftTear.lineTo(centerX - 20, centerY - 5);
    leftTear.close();
    canvas.drawPath(leftTear, paint);
    
    Path rightTear = Path();
    rightTear.moveTo(centerX + 18, centerY - 12);
    rightTear.lineTo(centerX + 20, centerY - 5);
    rightTear.lineTo(centerX + 16, centerY - 5);
    rightTear.close();
    canvas.drawPath(rightTear, paint);

    // Eye glow effect
    paint.color = robotColor.withOpacity(0.3);
    canvas.drawCircle(Offset(centerX - 15, centerY - 25), 10, paint);
    canvas.drawCircle(Offset(centerX + 15, centerY - 25), 10, paint);
  }

  void _drawSadFace(Canvas canvas, Paint paint, double centerX, double centerY) {
    // Sad eyes (droopy)
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    
    // Left eye (droopy)
    canvas.drawArc(
      Rect.fromCenter(center: Offset(centerX - 15, centerY - 22), width: 16, height: 12),
      Math.pi, Math.pi, false, paint
    );
    
    // Right eye (droopy)
    canvas.drawArc(
      Rect.fromCenter(center: Offset(centerX + 15, centerY - 22), width: 16, height: 12),
      Math.pi, Math.pi, false, paint
    );

    // Sad mouth (frown)
    canvas.drawArc(
      Rect.fromCenter(center: Offset(centerX, centerY - 5), width: 25, height: 20),
      Math.pi, Math.pi, false, paint
    );

    // Eye pupils
    paint.style = PaintingStyle.fill;
    paint.color = Colors.black;
    canvas.drawCircle(Offset(centerX - 15, centerY - 25), 4, paint);
    canvas.drawCircle(Offset(centerX + 15, centerY - 25), 4, paint);

    // Eye glow effect
    paint.color = robotColor.withOpacity(0.3);
    canvas.drawCircle(Offset(centerX - 15, centerY - 25), 8, paint);
    canvas.drawCircle(Offset(centerX + 15, centerY - 25), 8, paint);
  }

  void _drawBackgroundShapes(Canvas canvas, Size size, double centerX, double centerY) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    // Draw one large background shape behind the robot (static position, only rotates)
    paint.color = robotColor.withOpacity(0.15);
    
    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(rotationValue); // Only rotates when button is clicked, doesn't move position
    
    switch (currentShape) {
      case 'circle':
        _drawCircle(canvas, paint, 120);
        break;
      case 'square':
        _drawSquare(canvas, paint, 120);
        break;
      case 'triangle':
        _drawTriangle(canvas, paint, 120);
        break;
    }
    canvas.restore();

    // Draw 3 small sub-shapes outside the main background shape (static positions)
    paint.strokeWidth = 3;
    paint.color = robotColor.withOpacity(0.2);
    
    // Left side sub-shape
    canvas.save();
    canvas.translate(centerX - 180, centerY);
    switch (currentShape) {
      case 'circle':
        _drawCircle(canvas, paint, 12);
        break;
      case 'square':
        _drawSquare(canvas, paint, 12);
        break;
      case 'triangle':
        _drawTriangle(canvas, paint, 12);
        break;
    }
    canvas.restore();
    
    // Right side top sub-shape
    canvas.save();
    canvas.translate(centerX + 180, centerY - 40);
    switch (currentShape) {
      case 'circle':
        _drawCircle(canvas, paint, 10);
        break;
      case 'square':
        _drawSquare(canvas, paint, 10);
        break;
      case 'triangle':
        _drawTriangle(canvas, paint, 10);
        break;
    }
    canvas.restore();
    
    // Right side bottom sub-shape
    canvas.save();
    canvas.translate(centerX + 180, centerY + 40);
    switch (currentShape) {
      case 'circle':
        _drawCircle(canvas, paint, 8);
        break;
      case 'square':
        _drawSquare(canvas, paint, 8);
        break;
      case 'triangle':
        _drawTriangle(canvas, paint, 8);
        break;
    }
    canvas.restore();
  }

  void _drawCircle(Canvas canvas, Paint paint, double size) {
    canvas.drawCircle(Offset.zero, size, paint);
    
    // Inner circle for more detail
    double originalWidth = paint.strokeWidth;
    paint.strokeWidth = Math.max(1, originalWidth * 0.5);
    canvas.drawCircle(Offset.zero, size * 0.6, paint);
    paint.strokeWidth = originalWidth;
  }

  void _drawSquare(Canvas canvas, Paint paint, double size) {
    Rect rect = Rect.fromCenter(center: Offset.zero, width: size * 2, height: size * 2);
    canvas.drawRect(rect, paint);
    
    // Inner square for more detail
    double originalWidth = paint.strokeWidth;
    paint.strokeWidth = Math.max(1, originalWidth * 0.5);
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
    
    // Inner triangle for more detail
    double originalWidth = paint.strokeWidth;
    paint.strokeWidth = Math.max(1, originalWidth * 0.5);
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