import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

const _animationDuration = 1265;

const _fadeTransitionStart = 1050.0;
const _fadeTransitionEnd = _animationDuration;

const _frontTrackProgressStart = 0.0;
const _frontTrackProgressEnd = 875.0;

const _frontTrackExpansionStart = 450.0;
const _frontTrackExpansionEnd = 990.0;

const _frontTrackHeadExpansionStart = 475.0;
const _frontTrackHeadExpansionEnd = 875.0;

const _backTrackProgressStart = 0.0;
const _backTrackProgressEnd = 435.0;

const _initialTrackWidth = 112.0;
const _initialTrackHeadDiameter = 102.0;
const _finalTrackHeadDiameter = 132.0;

class WiseSplashScreen extends StatefulWidget {
  const WiseSplashScreen({
    required this.controller,
    super.key,
  });

  final AnimationController controller;

  static AnimationController createController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: _animationDuration),
    );
  }

  @override
  State<WiseSplashScreen> createState() => _WiseSplashScreenState();
}

class _WiseSplashScreenState extends State<WiseSplashScreen> {
  late final _opacity = Tween<double>(begin: 1, end: 0)
      .chain(
        CurveTween(
          curve: const Interval(
            _fadeTransitionStart / _animationDuration,
            _fadeTransitionEnd / _animationDuration,
            curve: Curves.easeOut,
          ),
        ),
      )
      .animate(widget.controller);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _opacity,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            const Positioned.fill(
              child: RepaintBoundary(
                child: _Background(),
              ),
            ),
            Positioned.fill(
              child: _Foreground(controller: widget.controller),
            ),
          ],
        ),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF9FE870),
      child: Center(
        child: VectorGraphic(
          loader: AssetBytesLoader('assets/images/logo.svg'),
          height: 90,
          width: 90,
        ),
      ),
    );
  }
}

class _Foreground extends StatefulWidget {
  const _Foreground({required this.controller});

  final AnimationController controller;

  @override
  State<_Foreground> createState() => _ForegroundState();
}

class _ForegroundState extends State<_Foreground> {
  late final _frontTrackProgress = Tween<double>(begin: 0, end: 1)
      .chain(
        CurveTween(
          curve: const Interval(
            _frontTrackProgressStart / _animationDuration,
            _frontTrackProgressEnd / _animationDuration,
            curve: Curves.easeIn,
          ),
        ),
      )
      .animate(widget.controller);

  late final _frontTrackExpansion = Tween<double>(begin: 0, end: 1.15)
      .chain(
        CurveTween(
          curve: const Interval(
            _frontTrackExpansionStart / _animationDuration,
            _frontTrackExpansionEnd / _animationDuration,
            curve: Curves.easeInCirc,
          ),
        ),
      )
      .animate(widget.controller);

  late final _frontTrackHeadExpansion = Tween<double>(begin: 0, end: 1)
      .chain(
        CurveTween(
          curve: const Interval(
            _frontTrackHeadExpansionStart / _animationDuration,
            _frontTrackHeadExpansionEnd / _animationDuration,
          ),
        ),
      )
      .animate(widget.controller);

  late final _backTrackProgress = Tween<double>(begin: 0, end: 0.31)
      .chain(
        CurveTween(
          curve: const Interval(
            _backTrackProgressStart / _animationDuration,
            _backTrackProgressEnd / _animationDuration,
            curve: Cubic(0, 0, 0.63, 0.83),
          ),
        ),
      )
      .animate(widget.controller);

  late final _imageScale = Tween<double>(begin: 1, end: 1.25)
      .chain(CurveTween(curve: Curves.linear))
      .animate(widget.controller);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _TrackPainter(progress: _backTrackProgress),
          ),
        ),
        Positioned.fill(
          child: ClipPath(
            clipper: _Clipper(
              progress: _frontTrackProgress,
              expansion: _frontTrackExpansion,
            ),
            child: AnimatedBuilder(
              animation: _imageScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _imageScale.value,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Center(
          child: CustomSingleChildLayout(
            delegate: _Delegate(
              progress: _frontTrackProgress,
              expansion: _frontTrackHeadExpansion,
            ),
            child: CustomPaint(
              painter: _CirclePainter(),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackPainter extends CustomPainter {
  _TrackPainter({required this.progress}) : super(repaint: progress);

  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final track = _Track.fromScreenRect(
      screenRect: Offset.zero & size,
      progress: progress.value,
      expansion: 0,
    );

    canvas.drawPath(
      track.path,
      Paint()..color = const Color(0xFF1E330A),
    );
  }

  @override
  bool shouldRepaint(_TrackPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _Clipper extends CustomClipper<Path> {
  _Clipper({
    required this.progress,
    required this.expansion,
  }) : super(
          reclip: Listenable.merge([progress, expansion]),
        );

  final Animation<double> progress;

  final Animation<double> expansion;

  @override
  Path getClip(Size size) {
    final track = _Track.fromScreenRect(
      screenRect: Offset.zero & size,
      progress: progress.value,
      expansion: expansion.value,
    );

    return track.path;
  }

  @override
  bool shouldReclip(_Clipper oldClipper) {
    return oldClipper.progress != progress || oldClipper.expansion != expansion;
  }
}

class _Delegate extends SingleChildLayoutDelegate {
  _Delegate({
    required this.progress,
    required this.expansion,
  }) : super(
          relayout: Listenable.merge([progress, expansion]),
        );

  final Animation<double> progress;

  final Animation<double> expansion;

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final diameter = lerpDouble(
      _initialTrackHeadDiameter,
      _finalTrackHeadDiameter,
      expansion.value,
    );

    return constraints.enforce(
      BoxConstraints.tightFor(
        width: diameter,
        height: diameter,
      ),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final track = _Track.fromScreenRect(
      screenRect: Offset.zero & size,
      progress: progress.value,
      expansion: 0,
    );

    final radius = childSize.width / 2;

    return track.trackHeadCenter.translate(-radius, -radius);
  }

  @override
  bool shouldRelayout(_Delegate oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.expansion != expansion;
  }
}

class _CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;

    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF9FE870);

    canvas.drawCircle(
      Offset(side * 0.5, side * 0.5),
      side * 0.5,
      circlePaint,
    );

    final arrowPath = Path()
      ..moveTo(side * 0.7156863, side * 0.4648235)
      ..lineTo(side * 0.5, side * 0.2529510)
      ..lineTo(side * 0.2843137, side * 0.4648235)
      ..moveTo(side * 0.5, side * 0.7470392)
      ..lineTo(side * 0.5, side * 0.2745098);

    final arrowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF163300)
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = side / 15 - 2.8;

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _Track {
  const _Track._({
    required this.path,
    required this.trackHeadCenter,
  });

  factory _Track.fromScreenRect({
    required Rect screenRect,
    required double progress,
    required double expansion,
  }) {
    final screenBottomCenter = screenRect.bottomCenter;

    final startY = screenRect.height + _initialTrackWidth / 2;
    const endY = -_initialTrackWidth;

    final dy = math.max(
      lerpDouble(startY, endY, progress)!,
      endY,
    );

    final trackWidth = _initialTrackWidth +
        (screenRect.width - _initialTrackWidth) * expansion;
    final halfTrackWidth = trackWidth / 2;

    final trackTopLeft = Offset(screenBottomCenter.dx - halfTrackWidth, dy);
    final trackBottomRight = Offset(
      screenBottomCenter.dx + halfTrackWidth,
      startY,
    );

    final trackRect = Rect.fromPoints(trackTopLeft, trackBottomRight);

    final path = Path()
      ..addRect(trackRect)
      ..moveTo(trackRect.topLeft.dx, trackRect.topLeft.dy)
      ..arcToPoint(
        trackRect.topRight,
        radius: Radius.elliptical(trackWidth / 2, trackWidth / 2),
      )
      ..close();

    return _Track._(
      path: path,
      trackHeadCenter: trackRect.topCenter,
    );
  }

  final Path path;

  final Offset trackHeadCenter;
}
