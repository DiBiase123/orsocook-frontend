import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/comment_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/utils/responsive_utils.dart';
import 'comment_input_widget.dart';
import 'comments_list_widget.dart';
import 'utils/comment_state_manager.dart';

@immutable
class DetailCommentsSection extends StatefulWidget {
  final String recipeId;

  const DetailCommentsSection({
    super.key,
    required this.recipeId,
  });

  @override
  State<DetailCommentsSection> createState() => _DetailCommentsSectionState();
}

class _DetailCommentsSectionState extends State<DetailCommentsSection>
    with CommentStateManager<DetailCommentsSection> {
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    AppLogger.debug('💬 DetailCommentsSection per: ${widget.recipeId}');
    _loadInitialComments();
  }

  void _loadInitialComments() {
    AppLogger.debug('📥 _loadInitialComments chiamato');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final commentService =
          Provider.of<CommentService>(context, listen: false);

      try {
        await commentService.getComments(widget.recipeId, forceRefresh: false);
        setInitialLoadComplete();
        AppLogger.debug('✅ Caricamento iniziale commenti completato');
      } catch (e) {
        AppLogger.error('❌ Errore caricamento iniziale commenti', e);
        setInitialLoadComplete();
      }
    });
  }

  Future<void> _loadComments({bool forceRefresh = false}) async {
    if (isRefreshing) {
      AppLogger.debug('⚠️ _loadComments già in corso, skippo');
      return;
    }

    AppLogger.debug('📥 _loadComments chiamato, forceRefresh: $forceRefresh');
    startRefresh();

    try {
      final commentService =
          Provider.of<CommentService>(context, listen: false);
      await commentService.getComments(widget.recipeId,
          forceRefresh: forceRefresh);
    } catch (e) {
      AppLogger.error('Errore caricamento commenti', e);
    } finally {
      endRefresh();
    }
  }

  Future<void> _submitComment(CommentService commentService) async {
    final content = commentController.text.trim();
    if (content.isEmpty) return;

    await safeAsyncOperation(
      operation: () async {
        await commentService.createComment(widget.recipeId, content);
        commentController.clear();
        _commentFocusNode.unfocus();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      onStart: startSubmit,
      onSuccess: () {
        AppLogger.success('✅ Commento inviato');
        _showSuccessSnackbar('Commento pubblicato con successo!');
      },
      onError: (e) {
        AppLogger.error('❌ Errore invio commento', e);
        _showErrorSnackbar('Errore: ${e.toString()}');
      },
      onFinally: endSubmit,
    );
  }

  Future<void> _updateComment(
      String commentId, CommentService commentService) async {
    final content = editCommentController.text.trim();
    if (content.isEmpty) return;

    await safeAsyncOperation(
      operation: () async {
        await commentService.updateComment(commentId, content);
        cancelEdit();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      onStart: startSubmit,
      onSuccess: () {
        AppLogger.success('✅ Commento aggiornato');
        _showSuccessSnackbar('Commento modificato con successo!');
      },
      onError: (e) {
        AppLogger.error('❌ Errore aggiornamento commento', e);
        _showErrorSnackbar('Errore: ${e.toString()}');
      },
      onFinally: endSubmit,
    );
  }

  Future<void> _deleteComment(
      String commentId, CommentService commentService) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina commento'),
        content: const Text('Sei sicuro di voler eliminare questo commento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    await safeAsyncOperation(
      operation: () async {
        await commentService.deleteComment(commentId, widget.recipeId);
        await Future.delayed(const Duration(milliseconds: 500));
        setForceRefresh(true);
      },
      onStart: startSubmit,
      onSuccess: () {
        AppLogger.success('✅ Commento eliminato');
        _showSuccessSnackbar('Commento eliminato con successo!');
      },
      onError: (e) {
        AppLogger.error('❌ Errore eliminazione commento', e);
        _showErrorSnackbar('Errore: ${e.toString()}');
      },
      onFinally: endSubmit,
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentsHeader(context),
        SizedBox(height: ResponsiveValues.gapLarge(context)),
        Consumer<CommentService>(
          builder: (context, commentService, child) {
            AppLogger.debug(
                '🔄 Consumer rebuilding, forceRefresh: $forceRefresh, initialLoadComplete: $initialLoadComplete, isRefreshing: $isRefreshing');

            final comments = commentService.getCachedComments(widget.recipeId);
            AppLogger.debug('📊 Commenti in cache: ${comments.length}');

            if (forceRefresh && !isRefreshing) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AppLogger.debug('🔄 Forzando refresh dei commenti');
                _loadComments(forceRefresh: true);
                setForceRefresh(false);
              });
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommentInputWidget(
                  recipeId: widget.recipeId,
                  commentController: commentController,
                  isSubmitting: isSubmitting,
                  onSubmit: _submitComment,
                  focusNode: _commentFocusNode,
                ),
                SizedBox(height: ResponsiveValues.gapLarge(context)),
                CommentsListWidget(
                  key: ValueKey(
                      'comments_${widget.recipeId}_${comments.length}'),
                  recipeId: widget.recipeId,
                  comments: comments,
                  isLoading: commentService.isLoading,
                  error: commentService.error,
                  isRefreshing: isRefreshing,
                  initialLoadComplete: initialLoadComplete,
                  onRetry: () => _loadComments(forceRefresh: true),
                  onRefresh: () => _loadComments(forceRefresh: true),
                  forceRefresh: forceRefresh,
                  onUpdateComment: (commentId) =>
                      _updateComment(commentId, commentService),
                  onDeleteComment: (commentId) =>
                      _deleteComment(commentId, commentService),
                  onStartEdit: startEditComment,
                  isSubmitting: isSubmitting,
                  editCommentId: editCommentId,
                  editCommentController: editCommentController,
                  onCancelEdit: cancelEdit,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentsHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveValues.gapMedium(context)),
      child: Row(
        children: [
          const Icon(Icons.comment, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Commenti',
            style: TextStyle(
              fontSize: ResponsiveValues.titleSize(context),
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(width: 8),
          Consumer<CommentService>(
            builder: (context, commentService, child) {
              final comments =
                  commentService.getCachedComments(widget.recipeId);
              return Text(
                '(${comments.length})',
                style: TextStyle(
                  fontSize: ResponsiveValues.bodySize(context),
                  color: Colors.grey,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentFocusNode.dispose();
    disposeStateManager();
    super.dispose();
  }
}
