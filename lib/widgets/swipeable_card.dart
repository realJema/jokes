import 'dart:math' show pi;
import 'package:flutter/material.dart';

enum SwipeDirection { left, right, none }

class SwipeableCard extends StatefulWidget {
  final Widget child;
  final Function(SwipeDirection) onSwipe;

  const SwipeableCard({
    super.key,
    required this.child,
    required this.onSwipe,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late double _dragStartX;
  Offset _position = Offset.zero;
  double _angle = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_controller);
    _animation.addListener(() {
      setState(() {
        _position = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _position += Offset(details.delta.dx, 0);
      _angle = (_position.dx / 300) * 45 * (pi / 180);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final position = _position.dx;
    SwipeDirection direction = SwipeDirection.none;

    if (position.abs() > screenWidth * 0.4 || velocity.abs() > 1000) {
      direction = position > 0 ? SwipeDirection.right : SwipeDirection.left;
      final endPosition = Offset(
        direction == SwipeDirection.right ? screenWidth : -screenWidth,
        0,
      );
      _animation = Tween<Offset>(
        begin: _position,
        end: endPosition,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      _controller.forward().then((_) {
        widget.onSwipe(direction);
      });
    } else {
      _animation = Tween<Offset>(
        begin: _position,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      _controller.forward().then((_) {
        setState(() {
          _position = Offset.zero;
          _angle = 0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Transform.translate(
        offset: _position,
        child: Transform.rotate(
          angle: _angle,
          child: widget.child,
        ),
      ),
    );
  }
}
