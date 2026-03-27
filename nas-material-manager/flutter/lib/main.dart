import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/hive/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final hiveService = HiveService();
  await HiveService.init();
  runApp(
    Provider.value(
      value: hiveService,
      child: const NASMaterialManagerApp(),
    ),
  );
}
