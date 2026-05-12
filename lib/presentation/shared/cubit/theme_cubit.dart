import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AppThemeMode { light, dark }

class ThemeState extends Equatable {
  final AppThemeMode mode;
  const ThemeState(this.mode);

  ThemeMode get themeMode =>
      mode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light;

  @override
  List<Object> get props => [mode];
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({AppThemeMode initial = AppThemeMode.light})
      : super(ThemeState(initial));

  void toggle() {
    emit(ThemeState(
      state.mode == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light,
    ));
  }

  void setMode(AppThemeMode mode) => emit(ThemeState(mode));
}
