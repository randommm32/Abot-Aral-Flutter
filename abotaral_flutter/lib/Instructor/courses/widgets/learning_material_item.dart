import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/learning_material_model.dart';


class LearningMaterialItem extends StatefulWidget {
  final LearningMaterial material;
  final VoidCallback? onUpdate;

  const LearningMaterialItem({
    super.key,
    required this.material,
    this.onUpdate,
  });

  @override
  State<LearningMaterialItem> createState() => _LearningMaterialItemState();
}

class _LearningMaterialItemState extends State<LearningMaterialItem> {
  bool _isLoading = false;

  Future<void> _launchDownloadUrl() async {
    final uri = Uri.parse(widget.material.fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch file URL')),
        );
      }
    }
  }

  Future<void> _deleteMaterial() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text('Are you sure you want to delete "${widget.material.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      // 1. Delete from Storage
      // Extract path from URL. Usually it's after /public/learning_materials/
      // Example: https://.../storage/v1/object/public/learning_materials/folder/file.pdf
      // We need 'folder/file.pdf'
      
      final fileUrl = widget.material.fileUrl;
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      // pathSegments might look like ['storage', 'v1', 'object', 'public', 'learning_materials', 'user_id', 'filename']
      // We need to find 'learning_materials' and get everything after it.
      
      int bucketIndex = pathSegments.indexOf('learning_materials');
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
         final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
         await Supabase.instance.client.storage
          .from('learning_materials')
          .remove([filePath]);
      }

      // 2. Delete from Database
      await Supabase.instance.client
          .from('learning_materials')
          .delete()
          .eq('id', widget.material.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material deleted successfully')),
        );
        widget.onUpdate?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting material: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editMaterial() async {
    final titleController = TextEditingController(text: widget.material.title);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Material'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final newTitle = titleController.text.trim();
    if (newTitle.isEmpty || newTitle == widget.material.title) return;

     setState(() => _isLoading = true);

    try {
      await Supabase.instance.client
          .from('learning_materials')
          .update({'title': newTitle})
          .eq('id', widget.material.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material updated successfully')),
        );
         widget.onUpdate?.call();
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating material: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchDownloadUrl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
           Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent1,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: _isLoading 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : SvgPicture.asset(
                  'assets/icons/file-text.svg',
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.material.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                   if (widget.material.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(widget.material.createdAt!),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                   ],
                ],
              ),
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/instructor_icons/edit.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
              ),
              onPressed: _editMaterial,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: SvgPicture.asset(
                'assets/instructor_icons/delete.svg',
                width: 20,
                height: 20,
                 colorFilter: const ColorFilter.mode(Color(0xFFEF4444), BlendMode.srcIn),
              ),
              onPressed: _deleteMaterial,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Simple date formatting
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
