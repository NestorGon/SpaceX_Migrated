import 'package:big_tip/big_tip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_request_bloc/flutter_request_bloc.dart';

import '../../utils/index.dart';

/// Widget that tells the user that there's been an error in a network process.
/// It allows the user to perform a reload action.
class ErrorView<C extends RequestCubit> extends StatelessWidget {
  const ErrorView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BigTip(
      subtitle: Text(
        context.translate('spacex.other.loading_error.message'),
        style: Theme.of(context).textTheme.subtitle1,
      ),
      action: TextButton(
        child: Text(context.translate('spacex.other.loading_error.reload')),
        onPressed: () => context.read<C>().loadData(),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(
            Theme.of(context).accentColor,
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(
            TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      child: Icon(Icons.cloud_off),
    );
  }
}

/// Presents the `ErrorView` widget inside a slivered widget.
///
/// Tells the user that there's been an error in a network process.
/// It allows the user to perform a reload action.
class ErrorSliverView<C extends RequestCubit> extends StatelessWidget {
  const ErrorSliverView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: ErrorView<C>(),
    );
  }
}
