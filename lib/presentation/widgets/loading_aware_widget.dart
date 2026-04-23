import 'package:flutter/material.dart';

/// A widget that helps pages communicate their loading state to the parent
class LoadingAwareWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onLoad;

  const LoadingAwareWidget({
    super.key,
    required this.child,
    required this.onLoad,
  });

  @override
  State<LoadingAwareWidget> createState() => _LoadingAwareWidgetState();
}

class _LoadingAwareWidgetState extends State<LoadingAwareWidget> {
  @override
  void initState() {
    super.initState();
    widget.onLoad();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
