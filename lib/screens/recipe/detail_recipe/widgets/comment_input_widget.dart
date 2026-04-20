import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/services/comment_service.dart';
import 'package:orsocook/utils/responsive_utils.dart';

@immutable
class CommentInputWidget extends StatelessWidget {
  final String recipeId;
  final TextEditingController commentController;
  final bool isSubmitting;
  final Function(CommentService) onSubmit;
  final FocusNode? focusNode;

  const CommentInputWidget({
    super.key,
    required this.recipeId,
    required this.commentController,
    required this.isSubmitting,
    required this.onSubmit,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<AuthService, CommentService>(
      builder: (context, authService, commentService, child) {
        if (!authService.isLoggedIn) {
          return _buildLoginPrompt(context, theme);
        }

        return _buildCommentInput(context, theme, commentService);
      },
    );
  }

  Widget _buildCommentInput(
    BuildContext context,
    ThemeData theme,
    CommentService commentService,
  ) {
    final hasFocus = focusNode?.hasFocus ?? false;

    return Container(
      margin:
          EdgeInsets.symmetric(vertical: ResponsiveValues.gapSmall(context)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: ResponsiveValues.screenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Lascia un commento',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveValues.gapMedium(context)),
              _buildCommentTextField(context, theme, hasFocus),
              SizedBox(height: ResponsiveValues.gapMedium(context)),
              _buildFooter(context, theme, commentService),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentTextField(
    BuildContext context,
    ThemeData theme,
    bool hasFocus,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFocus
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withAlpha((0.3 * 255).round()),
          width: hasFocus ? 2.0 : 1.5,
        ),
      ),
      child: TextField(
        controller: commentController,
        focusNode: focusNode,
        maxLines: 4,
        minLines: 2,
        maxLength: 1000,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          contentPadding: ResponsiveValues.screenPadding(context),
          border: InputBorder.none,
          hintText: 'Condividi il tuo pensiero sulla ricetta...',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withAlpha((0.5 * 255).round()),
            fontSize: ResponsiveValues.bodySize(context),
          ),
          suffixIcon: commentController.text.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 20,
                      color: theme.colorScheme.onSurface
                          .withAlpha((0.5 * 255).round()),
                    ),
                    onPressed: () {
                      commentController.clear();
                      (context as Element).markNeedsBuild();
                    },
                    splashRadius: 18,
                    tooltip: 'Cancella testo',
                  ),
                )
              : null,
          counterStyle: const TextStyle(fontSize: 0),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: ResponsiveValues.bodySize(context),
          height: 1.5,
        ),
        onChanged: (value) {
          (context as Element).markNeedsBuild();
        },
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    ThemeData theme,
    CommentService commentService,
  ) {
    final textLength = commentController.text.length;
    final isValid = textLength > 0 && textLength <= 1000;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$textLength/1000 caratteri',
          style: theme.textTheme.bodySmall?.copyWith(
            color: _getCounterColor(theme, textLength),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: 'Pubblica commento',
          preferBelow: false,
          child: FloatingActionButton(
            onPressed: (!isValid || isSubmitting || textLength == 0)
                ? null
                : () => onSubmit(commentService),
            backgroundColor: _getButtonColor(theme, isValid, isSubmitting),
            foregroundColor: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            mini: true,
            child: isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
          ),
        ),
      ],
    );
  }

  Color _getCounterColor(ThemeData theme, int length) {
    if (length == 0) {
      return theme.colorScheme.onSurface.withAlpha((0.5 * 255).round());
    } else if (length <= 800) {
      return Colors.green.shade600;
    } else if (length <= 950) {
      return Colors.orange.shade600;
    } else {
      return theme.colorScheme.error;
    }
  }

  Color _getButtonColor(ThemeData theme, bool isValid, bool isSubmitting) {
    if (!isValid || isSubmitting) {
      return theme.colorScheme.onSurface.withAlpha((0.2 * 255).round());
    }
    return theme.colorScheme.primary;
  }

  Widget _buildLoginPrompt(
    BuildContext context,
    ThemeData theme,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => _navigateToLogin(context),
        borderRadius: BorderRadius.circular(16),
        splashColor: theme.colorScheme.primary.withAlpha(64),
        highlightColor: theme.colorScheme.primary.withAlpha(32),
        child: Container(
          margin: EdgeInsets.symmetric(
              vertical: ResponsiveValues.gapSmall(context)),
          padding: ResponsiveValues.screenPadding(context),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.secondaryContainer,
            border: Border.all(
              color: theme.colorScheme.outline.withAlpha((0.2 * 255).round()),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.login_rounded,
                size: 40,
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: ResponsiveValues.gapMedium(context)),
              Text(
                'Accedi per commentare',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveValues.gapSmall(context)),
              Text(
                'Partecipa alla conversazione con la community',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withAlpha((0.7 * 255).round()),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveValues.gapMedium(context)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Accedi ora',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    context.go('/login');
  }
}
