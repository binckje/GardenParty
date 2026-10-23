import 'care_planner.dart';

/// Fichier iCalendar (RFC 5545) des soins prévus, importable dans Google Agenda ou Calendrier iPhone.
String buildIcs(List<PlannedCare> items, {required String Function(String plantId) plantName, required DateTime now}) {
  final b = StringBuffer()
    ..write('BEGIN:VCALENDAR\r\n')
    ..write('VERSION:2.0\r\n')
    ..write('PRODID:-//GardenParty//Soins//FR\r\n')
    ..write('CALSCALE:GREGORIAN\r\n')
    ..write('X-WR-CALNAME:GardenParty\r\n');
  for (final c in items) {
    final title = '${careEmoji(c.type)} ${careLabel(c.type)} : ${plantName(c.plantId)}';
    b
      ..write('BEGIN:VEVENT\r\n')
      ..write('UID:${c.key}@gardenparty\r\n')
      ..write('DTSTAMP:${_utc(now)}\r\n')
      ..write('DTSTART:${_utc(c.dueAt)}\r\n')
      ..write('DTEND:${_utc(c.dueAt.add(const Duration(minutes: 15)))}\r\n')
      ..write(_fold('SUMMARY:${_escape(title)}'))
      ..write('BEGIN:VALARM\r\nACTION:DISPLAY\r\n')
      ..write(_fold('DESCRIPTION:${_escape(title)}'))
      ..write('TRIGGER:PT0M\r\nEND:VALARM\r\n')
      ..write('END:VEVENT\r\n');
  }
  b.write('END:VCALENDAR\r\n');
  return b.toString();
}

String _two(int n) => n.toString().padLeft(2, '0');

String _utc(DateTime d) {
  final u = d.toUtc();
  return '${u.year}${_two(u.month)}${_two(u.day)}T${_two(u.hour)}${_two(u.minute)}${_two(u.second)}Z';
}

String _escape(String s) =>
    s.replaceAll('\\', '\\\\').replaceAll(';', '\\;').replaceAll(',', '\\,').replaceAll('\n', '\\n');

/// Lignes de 75 octets max, suite précédée d'une espace (on coupe par caractère, sans casser l'UTF-16).
String _fold(String line) {
  final out = StringBuffer();
  var count = 0;
  for (final r in line.runes) {
    final ch = String.fromCharCode(r);
    final len = r < 0x80 ? 1 : (r < 0x800 ? 2 : (r < 0x10000 ? 3 : 4));
    if (count + len > 75) {
      out.write('\r\n ');
      count = 1;
    }
    out.write(ch);
    count += len;
  }
  out.write('\r\n');
  return out.toString();
}
