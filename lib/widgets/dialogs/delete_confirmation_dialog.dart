import 'package:flutter/material.dart';
import 'package:coffee_mapper_web/utils/text_styles.dart';

class DeleteConfirmationDialog<T> extends StatelessWidget {
  final T data;
  final Function(T) onDelete;

  const DeleteConfirmationDialog({
    super.key,
    required this.data,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Confirm Delete',
        style: AppTextStyles.dialogTitle(context),
      ),
      content: Text(
        'Are you sure you want to delete this entry?',
        style: AppTextStyles.dialogContent(context),
      ),
      actions: [
        TextButton(
          child: Text(
            'No',
            style: AppTextStyles.dialogButton(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(
            'Yes',
            style: AppTextStyles.dialogButton(context),
          ),
          onPressed: () {
            onDelete(data);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
