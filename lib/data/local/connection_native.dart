import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

QueryExecutor openDatabase(String owner) => LazyDatabase(() async {
  final directory = await getApplicationSupportDirectory();
  return NativeDatabase.createInBackground(File(p.join(directory.path, 'rolevia_$owner.sqlite')));
});
