import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../domain/entities/category_entity.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  List<CategoryEntity> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cats = await sl<CategoryRepository>().getAll();
    if (mounted) setState(() { _categories = cats; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Categories',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_category',
        onPressed: () => _showCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? Center(
                  child: Text('No categories yet.',
                      style: theme.textTheme.bodyMedium))
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _categories.length,
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: cat.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: cat.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cat.name,
                                    style: theme.textTheme.titleSmall),
                                if (cat.budgetLimit != null &&
                                    cat.budgetLimit! > 0)
                                  Text(
                                    'Limit: ${cat.budgetLimit!.toStringAsFixed(0)}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (cat.isSystem)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('System',
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(fontSize: 9)),
                            )
                          else
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  size: 20,
                                  color: theme.colorScheme.error),
                              onPressed: () => _deleteCategory(cat),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(
                        duration: 200.ms,
                        delay: Duration(milliseconds: i * 40));
                  },
                ),
    );
  }

  void _showCategoryDialog(BuildContext context, {CategoryEntity? existing}) {
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    final limitCtrl = TextEditingController(
      text: existing?.budgetLimit?.toStringAsFixed(0) ?? '',
    );
    int colorIndex = existing != null
        ? AppColors.categoryPalette.indexWhere((c) => c.toARGB32() == existing.color.toARGB32())
        : 0;
    if (colorIndex < 0) colorIndex = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing != null ? 'Edit Category' : 'New Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: limitCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Budget Limit (optional)'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                    AppColors.categoryPalette.length, (i) {
                  final c = AppColors.categoryPalette[i];
                  final isSelected = i == colorIndex;
                  return GestureDetector(
                    onTap: () => setDialogState(() => colorIndex = i),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(ctx).colorScheme.onSurface,
                                width: 2)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final limit = double.tryParse(limitCtrl.text.trim());
                final color = AppColors.categoryPalette[colorIndex];
                final repo = sl<CategoryRepository>();

                if (existing != null) {
                  await repo.updateDetails(
                    id: existing.id,
                    name: name,
                    color: color,
                    budgetLimit: limit,
                  );
                } else {
                  await repo.create(
                    name: name,
                    color: color,
                    budgetLimit: limit,
                    sortOrder: _categories.length,
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _load();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategory(CategoryEntity cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${cat.name}"? Expenses in this category will not be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await sl<CategoryRepository>().delete(cat.id);
      _load();
    }
  }
}
