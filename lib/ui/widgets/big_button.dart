import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BigElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final bool disabled;
  final bool loading;
  final Widget? child;

  const BigElevatedButton({
    Key? key,
    required this.onPressed,
    this.onLongPress,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.disabled = false,
    this.loading = false,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: key,
      onPressed: disabled || loading ? null : onPressed,
      onLongPress: disabled || loading ? null : onLongPress,
      child: SizedBox(
        height: 50.0,
        width: double.infinity,
        child: Center(
          child: loading ? const CupertinoActivityIndicator() : child,
        ),
      ),
    );
  }
}

class BigOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final Widget? child;

  const BigOutlinedButton({
    Key? key,
    required this.onPressed,
    this.onLongPress,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: key,
      onPressed: onPressed,
      onLongPress: onLongPress,
      child: SizedBox(
        height: 50.0,
        width: double.infinity,
        child: Center(
          child: child,
        ),
      ),
    );
  }
}