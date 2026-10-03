import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor openDatabase(String owner) => DatabaseConnection.delayed(
  WasmDatabase.open(databaseName: 'rolevia_$owner',
    sqlite3Uri: Uri.parse('sqlite3.wasm'), driftWorkerUri: Uri.parse('drift_worker.dart.js'))
    .then((result) => result.resolvedExecutor));
