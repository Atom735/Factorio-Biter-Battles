import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

const _root = false;
final file = File(p.join(_root ? 'locale_generator.dart' : '.', 'l10n.yaml'));
final dir_locale = Directory(p.join(_root ? '.' : '..', 'locale'));
void main(List<String> args) {
  // if (args.isNotEmpty) {
  Directory(_root ? 'locale_generator.dart' : '.').watch().listen((event) {
    if (p.equals(event.path, file.path)) {
      regenerate();
    }
  });
  // } else {
  //   regenerate();
  // }
}

void regenerate() {
  final yaml = loadYaml(file.readAsStringSync()) as Map;
  final l10n = <String, Map<String, Map<String, String>>>{};
  final locale_base = 'en';
  final locales = <String>{locale_base};

  /// Generate struct in memory
  for (final yaml_category in yaml.entries) {
    final category = l10n[yaml_category.key] ??= {};
    for (final yaml_item in (yaml_category.value as Map).entries) {
      final item = category[yaml_item.key] ??= {};
      final value = yaml_item.value;
      if (value is String) {
        item[locale_base] = value;
      } else if (value is Map) {
        for (final locale in value.entries) {
          item[locale.key as String] = locale.value as String;
          locales.add(locale.key as String);
        }
      }
    }
  }

  /// Write data to files
  for (final locale in locales) {
    final dir = Directory(p.join(dir_locale.path, locale))
      ..createSync(recursive: true);
    final file = File(p.join(dir.path, 'generated.cfg'));
    final sink = file.openWrite(mode: FileMode.writeOnly);
    for (final category in l10n.entries) {
      sink.write('[${category.key}]\n');
      for (final item in category.value.entries) {
        sink.write('${item.key}=');
        final value = item.value[locale] ?? item.value[locale_base];
        sink.write('$value\n');
      }
      sink.write('\n');
    }
    sink.close();
  }
}
