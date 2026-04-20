import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/comment_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/models/comment.dart';
import 'package:orsocook/screens/recipe/detail_recipe/widgets/comment_item_widget.dart';
import 'package:orsocook/utils/responsive_utils.dart';

@immutable
class CommentsListWidget extends StatelessWidget {
  final String recipeId;
  final List<Comment> comments;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;
  final bool initialLoadComplete;
  final VoidCallback onRetry;
  final VoidCallback onRefresh;
  final bool forceRefresh;
  final ValueChanged<String> onUpdateComment;
  final ValueChanged<String> onDeleteComment;
  final ValueChanged<Comment> onStartEdit;
  final bool isSubmitting;
  final String? editCommentId;
  final TextEditingController editCommentController;
  final VoidCallback onCancelEdit;

  const CommentsListWidget({
    super.key,
    required this.recipeId,
    required this.comments,
    required this.isLoading,
    required this.error,
    required this.isRefreshing,
    required this.initialLoadComplete,
    required this.onRetry,
    required this.onRefresh,
    required this.forceRefresh,
    required this.onUpdateComment,
    required this.onDeleteComment,
    required this.onStartEdit,
    required this.isSubmitting,
    required this.editCommentId,
    required this.editCommentController,
    required this.onCancelEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, CommentService>(
      builder: (context, authService, commentService, child) {
        return AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _getCrossFadeState(),
          firstChild: _buildLoadingOrEmptyState(context),
          secondChild: _buildContentState(authService, commentService, context),
        );
      },
    );
  }

  CrossFadeState _getCrossFadeState() {
    if (!initialLoadComplete && comments.isEmpty) {
      return CrossFadeState.showFirst;
    }
    if (isLoading && error == null) {
      return CrossFadeState.showFirst;
    }
    if (error != null && comments.isEmpty) {
      return CrossFadeState.showFirst;
    }
    if (comments.isEmpty) {
      return CrossFadeState.showFirst;
    }
    return CrossFadeState.showSecond;
  }

  Widget _buildLoadingOrEmptyState(BuildContext context) {
    if (!initialLoadComplete && comments.isEmpty) {
      return _buildLoadingState(context);
    }
    if (isLoading && error == null) {
      return _buildLoadingState(context);
    }
    if (error != null) {
      return _buildErrorState(context);
    }
    return _buildEmptyState(context);
  }

  Widget _buildContentState(AuthService authService,
      CommentService commentService, BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1.0,
            child: child,
          ),
        );
      },
      child: _buildCommentsList(context),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: ResponsiveValues.gapExtraLarge(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: const AlwaysStoppedAnimation(0.5),
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(
                    Colors.grey.withAlpha(179),
                  ),
                ),
              ),
            ),
            SizedBox(height: ResponsiveValues.gapMedium(context)),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: 1.0,
              child: const Text(
                'Caricamento commenti...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: ResponsiveValues.gapExtraLarge(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(
                parent: const AlwaysStoppedAnimation(1.0),
                curve: Curves.elasticOut,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.withAlpha(204),
              ),
            ),
            SizedBox(height: ResponsiveValues.gapMedium(context)),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: 1.0,
              child: const Text(
                'Errore caricamento commenti',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: ResponsiveValues.gapMedium(context)),
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isRefreshing ? 0.95 : 1.0,
              child: ElevatedButton(
                onPressed: isRefreshing ? null : onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withAlpha(26),
                  foregroundColor: Colors.red,
                  minimumSize:
                      Size(100, ResponsiveValues.buttonHeight(context)),
                ),
                child: isRefreshing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, size: 16),
                          SizedBox(width: 8),
                          Text('RIPROVA'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: ResponsiveValues.gapExtraLarge(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              child: Icon(
                Icons.comment_outlined,
                size: 56,
                color: Colors.grey.withAlpha(153),
              ),
            ),
            SizedBox(height: ResponsiveValues.gapLarge(context)),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: 1.0,
              child: Column(
                children: [
                  const Text(
                    'Nessun commento ancora',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: ResponsiveValues.gapSmall(context)),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 800),
                    opacity: 1.0,
                    child: const Text(
                      'Sii il primo a commentare!',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: ListView.builder(
        key: ValueKey('comments_list_${comments.length}'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: comments.length,
        itemBuilder: (context, index) {
          final comment = comments[index];

          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeOut,
            margin: EdgeInsets.only(
              top: index == 0 ? 0 : ResponsiveValues.gapSmall(context),
              bottom: index == comments.length - 1
                  ? 0
                  : ResponsiveValues.gapSmall(context),
            ),
            child: CommentItemWidget(
              key: ValueKey('comment_${comment.id}'),
              comment: comment,
              isEditing: editCommentId == comment.id,
              isSubmitting: isSubmitting,
              editCommentId: editCommentId,
              editCommentController: editCommentController,
              onUpdateComment: onUpdateComment,
              onDeleteComment: onDeleteComment,
              onCancelEdit: onCancelEdit,
              onStartEdit: onStartEdit,
            ),
          );
        },
      ),
    );
  }
}
