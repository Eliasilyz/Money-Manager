import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:money_manager/domain/entities/note.dart';
import 'package:money_manager/features/notes/application/note_provider.dart';
import 'package:money_manager/theme/app_colors.dart';
import 'package:money_manager/theme/app_theme.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final notesAsync = ref.watch(notesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Tambah Catatan',
            icon: const Icon(Icons.add),
            onPressed: () => _showEditor(context, ref),
          ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) return _buildEmpty(context, ref);
          final sorted = [...notes]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final note = sorted[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            note.title.isEmpty ? 'Tanpa judul' : note.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: note.title.isEmpty ? colors.textSecondary : colors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Hapus',
                          icon: Icon(Icons.delete_outline, size: 18, color: colors.textSecondary),
                          onPressed: () => _confirmDelete(context, ref, note),
                        ),
                      ],
                    ),
                    if (note.body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        note.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 13, color: colors.textSecondary, height: 1.4),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(note.updatedAt),
                      style: GoogleFonts.inter(fontSize: 11, color: colors.textSecondary),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: AppColors.rose))),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: const Icon(Icons.sticky_note_2_outlined, size: 32, color: AppColors.gold),
          ),
          const SizedBox(height: 16),
          Text('Belum ada catatan', style: GoogleFonts.inter(color: colors.textSecondary, fontSize: 14)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showEditor(context, ref),
            child: Text('Buat catatan pertama', style: GoogleFonts.inter(color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showEditor(BuildContext context, WidgetRef ref) {
    final colors = AppColorsT.of(context);
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Catatan Baru', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary)),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              style: GoogleFonts.inter(color: colors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Judul',
                hintText: 'Opsional',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              style: GoogleFonts.inter(color: colors.textPrimary),
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Isi catatan',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: () {
                  final now = DateTime.now();
                  final note = Note(
                    id: const Uuid().v4(),
                    title: titleCtrl.text.trim(),
                    body: bodyCtrl.text.trim(),
                    createdAt: now,
                    updatedAt: now,
                  );
                  ref.read(notesNotifierProvider.notifier).save(note);
                  Navigator.pop(ctx);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.bg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Simpan', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Note note) {
    final colors = AppColorsT.of(context);
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text('Hapus Catatan?', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        content: Text('Catatan akan dihapus permanen.', style: GoogleFonts.inter(fontSize: 14, color: colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.inter(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: GoogleFonts.inter(color: AppColors.rose)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        ref.read(notesNotifierProvider.notifier).delete(note.id);
      }
    });
  }
}