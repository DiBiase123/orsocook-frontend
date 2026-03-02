import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/models/comment.dart';

@immutable
class CommentItemWidget extends StatelessWidget {
  final Comment comment;
  final bool isEditing;
  final bool isSubmitting;
  final String? editCommentId;
  final TextEditingController editCommentController;
  final Function(String) onUpdateComment;
  final Function(String) onDeleteComment;
  final Function() onCancelEdit;
  final Function(Comment) onStartEdit;

  const CommentItemWidget({
    super.key,
    required this.comment,
    required this.isEditing,
    required this.isSubmitting,
    required this.editCommentId,
    required this.editCommentController,
    required this.onUpdateComment,
    required this.onDeleteComment,
    required this.onCancelEdit,
    required this.onStartEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final isOwnComment =
            authService.userId != null && comment.isOwner(authService.userId!);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER SEMPLICE
                _buildHeader(context, isOwnComment, authService),
                const SizedBox(height: 12),

                // CONTENUTO O EDIT FORM
                _buildContent(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isOwnComment, AuthService authService) {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          backgroundImage: comment.userAvatar != null
              ? NetworkImage(comment.userAvatar!)
              : null,
          child: comment.userAvatar == null
              ? Text(comment.userName[0].toUpperCase())
              : null,
        ),
        const SizedBox(width: 12),

        // Nome e data (EXPANDED per occupare spazio)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                comment.timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Menu azioni (solo se proprietario e non in editing)
        if (isOwnComment && !isEditing) _buildMenuButton(context),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'edit') {
          onStartEdit(comment);
        } else if (value == 'delete') {
          _showDeleteDialog(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Modifica'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Elimina', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina commento'),
        content: const Text('Sei sicuro di voler eliminare questo commento?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(), // <-- MODIFICATO
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () {
              context.pop(); // <-- MODIFICATO
              onDeleteComment(comment.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Se è in modalità editing
    if (isEditing && editCommentId == comment.id) {
      return Column(
        children: [
          TextField(
            controller: editCommentController,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              labelText: 'Modifica commento',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancelEdit,
                child: const Text('ANNULLA'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed:
                    isSubmitting ? null : () => onUpdateComment(comment.id),
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('SALVA'),
              ),
            ],
          ),
        ],
      );
    }

    // Contenuto normale
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          comment.content,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        if (comment.isEdited)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '(modificato)',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
