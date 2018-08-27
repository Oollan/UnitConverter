import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:unit_converter/category/category.dart';
import 'package:unit_converter/backdrop/backdrop_panel.dart';
import 'package:unit_converter/backdrop/backdrop_title.dart';

class Backdrop extends StatefulWidget {
  final Category currentCategory;
  final Widget frontPanel;
  final Widget backPanel;
  final Widget frontTitle;
  final Widget backTitle;

  Backdrop({
    @required this.currentCategory,
    @required this.frontPanel,
    @required this.backPanel,
    @required this.frontTitle,
    @required this.backTitle,
  })  : assert(currentCategory != null),
        assert(frontPanel != null),
        assert(backPanel != null),
        assert(frontTitle != null),
        assert(backTitle != null);

  @override
  State createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final double _flingVelocity = 2.0;
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      value: 1.0,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(Backdrop old) {
    super.didUpdateWidget(old);
    if (widget.currentCategory != old.currentCategory) {
      setState(() {
        _controller.fling(
          velocity: _backdropPanelVisible ? -_flingVelocity : _flingVelocity,
        );
      });
    } else if (!_backdropPanelVisible)
      setState(() {
        _controller.fling(velocity: _flingVelocity);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _backdropPanelVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBackdropPanelVisibility() {
    _controller.fling(
        velocity: _backdropPanelVisible ? -_flingVelocity : _flingVelocity);
  }

  double get _backdropHeight {
    final RenderBox renderBox = _backdropKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    _controller.value -= details.primaryDelta / _backdropHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / _backdropHeight;
    if (flingVelocity < 0.0)
      _controller.fling(velocity: math.max(_flingVelocity, -flingVelocity));
    else if (flingVelocity > 0.0)
      _controller.fling(velocity: math.min(-_flingVelocity, -flingVelocity));
    else
      _controller.fling(
          velocity: _controller.value < 0.5 ? -_flingVelocity : _flingVelocity);
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final double panelTitleHeight = 48.0;
    final Size panelSize = constraints.biggest;
    final double panelTop = panelSize.height - panelTitleHeight;

    Animation<RelativeRect> panelAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(
        0.0,
        panelTop,
        0.0,
        panelTop - panelSize.height,
      ),
      end: RelativeRect.fromLTRB(
        0.0,
        0.0,
        0.0,
        0.0,
      ),
    ).animate(_controller.view);

    return Container(
      key: _backdropKey,
      color: widget.currentCategory.color,
      child: Stack(
        children: <Widget>[
          widget.backPanel,
          PositionedTransition(
            rect: panelAnimation,
            child: BackdropPanel(
              onTap: _toggleBackdropPanelVisibility,
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              title: Text(
                widget.currentCategory.name,
              ),
              child: widget.frontPanel,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.currentCategory.color,
        elevation: 0.0,
        leading: IconButton(
          onPressed: _toggleBackdropPanelVisibility,
          icon: AnimatedIcon(
            icon: AnimatedIcons.close_menu,
            progress: _controller.view,
          ),
        ),
        title: BackdropTitle(
          listenable: _controller.view,
          frontTitle: widget.frontTitle,
          backTitle: widget.backTitle,
        ),
      ),
      body: LayoutBuilder(
        builder: _buildStack,
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}