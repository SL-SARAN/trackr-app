import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';
import '../daos/category_dao.dart';
import '../database/app_database.dart';

class CategoryRepository {
  final CategoryDao _dao;

  CategoryRepository(this._dao);

  Stream<List<CategoryEntity>> watchAll() =>
      _dao.watchAll().map((rows) => rows.map(_toEntity).toList());

  Future<List<CategoryEntity>> getAll() async {
    final rows = await _dao.getAll();
    return rows.map(_toEntity).toList();
  }

  Future<CategoryEntity?> getById(int id) async {
    final row = await _dao.getById(id);
    return row == null ? null : _toEntity(row);
  }

  Future<int> create({
    required String name,
    required Color color,
    double? budgetLimit,
    bool isSystem = false,
    required int sortOrder,
  }) =>
      _dao.insert(CategoriesCompanion.insert(
        name: name,
        colorValue: color.toARGB32(),
        budgetLimit: Value(budgetLimit),
        isSystem: Value(isSystem),
        sortOrder: Value(sortOrder),
      ));

  Future<bool> updateBudgetLimit(int id, double? limit) =>
      _dao.updateEntry(CategoriesCompanion(
        id: Value(id),
        budgetLimit: Value(limit),
      ));

  Future<bool> updateDetails({
    required int id,
    String? name,
    Color? color,
    double? budgetLimit,
    int? sortOrder,
  }) =>
      _dao.updateEntry(CategoriesCompanion(
        id: Value(id),
        name: name != null ? Value(name) : const Value.absent(),
        colorValue: color != null ? Value(color.toARGB32()) : const Value.absent(),
        budgetLimit: budgetLimit != null ? Value(budgetLimit) : const Value.absent(),
        sortOrder: sortOrder != null ? Value(sortOrder) : const Value.absent(),
      ));

  Future<int> delete(int id) => _dao.deleteById(id);

  Future<Map<int, double>> getSpendingPerCategory({
    required DateTime from,
    required DateTime to,
  }) =>
      _dao.getSpendingPerCategory(from: from, to: to);

  CategoryEntity _toEntity(Category row) => CategoryEntity(
        id: row.id,
        name: row.name,
        color: Color(row.colorValue),
        budgetLimit: row.budgetLimit,
        isSystem: row.isSystem,
        sortOrder: row.sortOrder,
        createdAt: row.createdAt,
      );
}
