import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String name;
  final Color color;
  final double? budgetLimit;
  final bool isSystem;
  final int sortOrder;
  final String type;
  final DateTime createdAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.color,
    this.budgetLimit,
    required this.isSystem,
    required this.sortOrder,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, color, budgetLimit, isSystem, sortOrder, type];
}
