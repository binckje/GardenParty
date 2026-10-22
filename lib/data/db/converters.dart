import 'dart:convert';

import 'package:drift/drift.dart';

import '../../models/garden.dart';
import '../../models/plant.dart';

class LightLevelsConverter extends TypeConverter<List<LightLevel>, String> {
  const LightLevelsConverter();

  @override
  List<LightLevel> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List).map((n) => LightLevel.values.byName(n as String)).toList();

  @override
  String toSql(List<LightLevel> value) => jsonEncode(value.map((l) => l.name).toList());
}

class CareScheduleConverter extends TypeConverter<CareSchedule, String> {
  const CareScheduleConverter();

  @override
  CareSchedule fromSql(String fromDb) => CareSchedule.fromJson(jsonDecode(fromDb) as Map<String, dynamic>);

  @override
  String toSql(CareSchedule value) => jsonEncode(value.toJson());
}

class DiagnosticsConverter extends TypeConverter<List<Diagnostic>, String> {
  const DiagnosticsConverter();

  @override
  List<Diagnostic> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List).map((d) => Diagnostic.fromJson(d as Map<String, dynamic>)).toList();

  @override
  String toSql(List<Diagnostic> value) => jsonEncode(value.map((d) => d.toJson()).toList());
}

class PropagationConverter extends TypeConverter<PropagationInfo, String> {
  const PropagationConverter();

  @override
  PropagationInfo fromSql(String fromDb) => PropagationInfo.fromJson(jsonDecode(fromDb) as Map<String, dynamic>);

  @override
  String toSql(PropagationInfo value) => jsonEncode(value.toJson());
}

class RepottingConverter extends TypeConverter<RepottingInfo, String> {
  const RepottingConverter();

  @override
  RepottingInfo fromSql(String fromDb) => RepottingInfo.fromJson(jsonDecode(fromDb) as Map<String, dynamic>);

  @override
  String toSql(RepottingInfo value) => jsonEncode(value.toJson());
}
