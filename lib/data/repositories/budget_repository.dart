import 'package:trackr/data/database/app_database.dart';

import '../../domain/entities/budget_entity.dart';
import '../daos/budget_dao.dart';

class BudgetRepository {
  final BudgetDao _dao;

  BudgetRepository(this._dao);

  Stream<BudgetEntity?> watchActive() =>
      _dao.watchActive().map((row) => row == null ? null : _toEntity(row));

  Future<BudgetEntity?> getActive() async {
    final row = await _dao.getActive();
    return row == null ? null : _toEntity(row);
  }

  /// Set a new active budget (deactivates the previous one).
  Future<void> setAmount(double amount) async {
    await _dao.deactivateAll();
    await _dao.insert(BudgetsCompanion.insert(
      amount: amount,
      periodStart: DateTime(DateTime.now().year, DateTime.now().month, 1),
    ));
  }

  BudgetEntity _toEntity(Budget row) => BudgetEntity(
        id: row.id,
        amount: row.amount,
        periodStart: row.periodStart,
        isActive: row.isActive,
      );
}
