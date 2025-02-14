import 'package:flutter/material.dart';
import 'package:coffee_mapper_web/utils/text_styles.dart';

class ErrorBoundary extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorBoundary({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.dialogContent(context),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: AppTextStyles.dialogButton(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
