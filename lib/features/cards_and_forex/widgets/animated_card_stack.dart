import 'package:flutter/material.dart';

class AnimatedCardStack extends StatefulWidget {
  final List<Widget> cards;
  final double maxCardHeight;
  final double headroom;
  final Function(int)? onCardChanged;

  const AnimatedCardStack({
    super.key,
    required this.cards,
    this.maxCardHeight = 164.0,
    this.headroom = 36.0,
    this.onCardChanged,
  });

  @override
  State<AnimatedCardStack> createState() => _AnimatedCardStackState();
}

class _AnimatedCardStackState extends State<AnimatedCardStack> with TickerProviderStateMixin {
  late final AnimationController _releaseCtrl;
  late final AnimationController _snapCtrl;
  late Animation<double> _snapAnim;

  int _topIndex = 0;
  double _dragY = 0.0;
  double _startDragY = 0.0;
  bool _isReleasing = false;

  static const double _baseOffset = -12.0;

  @override
  void initState() {
    super.initState();

    _releaseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _releaseCtrl.addListener(() => setState(() {}));
    _releaseCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _topIndex = (_topIndex + 1) % widget.cards.length;
          _dragY = 0.0;
          _isReleasing = false;
        });
        if (widget.onCardChanged != null) {
          widget.onCardChanged!(_topIndex);
        }
        _releaseCtrl.reset();
      }
    });

    _snapCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _snapCtrl.addListener(() {
      setState(() {
        _dragY = _snapAnim.value;
      });
    });
  }

  @override
  void dispose() {
    _releaseCtrl.dispose();
    _snapCtrl.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isReleasing || _snapCtrl.isAnimating) return;
    setState(() {
      double resistance = 1.0 - (_dragY / 300.0).clamp(0.0, 0.8);
      _dragY += details.delta.dy * resistance * 0.85;
      if (_dragY < 0) _dragY = 0;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isReleasing || _snapCtrl.isAnimating) return;

    if (_dragY > 60 || details.velocity.pixelsPerSecond.dy > 300) {
      _startDragY = _dragY;
      _isReleasing = true;
      _releaseCtrl.animateTo(1.0, curve: Curves.easeInCubic);
    } else {
      _snapAnim = Tween<double>(begin: _dragY, end: 0.0).animate(
          CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutBack));
      _snapCtrl.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    int cardCount = widget.cards.length;
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        color: Colors.transparent,
        height: widget.maxCardHeight + widget.headroom,
        child: Stack(
          clipBehavior: Clip.none,
          children: List.generate(cardCount, (reverseIdx) {
            int visualIdx = cardCount - 1 - reverseIdx;
            int cardIdx = (_topIndex + visualIdx) % cardCount;
            Widget card = widget.cards[cardIdx];

            double dy = 0;
            double scale = 1.0;
            double opacity = 1.0;

            if (_isReleasing) {
              double t = _releaseCtrl.value;
              if (visualIdx == 0) {
                dy = _startDragY + (400.0 - _startDragY) * t;
                opacity = (1.0 - (t * 1.5)).clamp(0.0, 1.0);
              } else if (visualIdx == 1) {
                double startDY = _baseOffset - (_startDragY * 0.08);
                dy = startDY * (1.0 - t);
                scale = 0.96 + (0.04 * t);
              } else if (visualIdx == 2) {
                double startDY = (_baseOffset * 2) - (_startDragY * 0.04);
                dy = startDY + ((_baseOffset - startDY) * t);
                scale = 0.92 + (0.04 * t);
              } else {
                dy = _baseOffset * visualIdx;
                scale = 1.0 - (visualIdx * 0.04);
              }
            } else {
              if (visualIdx == 0) {
                dy = _dragY;
              } else if (visualIdx == 1) {
                dy = _baseOffset - (_dragY * 0.08);
                scale = 0.96;
              } else if (visualIdx == 2) {
                dy = (_baseOffset * 2) - (_dragY * 0.04);
                scale = 0.92;
              } else {
                dy = _baseOffset * visualIdx;
                scale = 1.0 - (visualIdx * 0.04);
              }
            }

            return Positioned(
              top: widget.headroom,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, dy),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: card,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
