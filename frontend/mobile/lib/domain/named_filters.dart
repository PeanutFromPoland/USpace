import 'models.dart';

class NamedFilter {
  const NamedFilter({
    required this.name,
    required this.rules,
    required this.includeUnknown,
  });
  final String name;
  final List<FilterRule> rules;
  final bool includeUnknown;
  Map<String, dynamic> toJson() => {
    'name': name,
    'rules': rules.map((r) => r.toJson()).toList(),
    'includeUnknown': includeUnknown,
  };
  factory NamedFilter.fromJson(Map<String, dynamic> json) => NamedFilter(
    name: json['name'] as String,
    rules: (json['rules'] as List)
        .map((r) => FilterRule.fromJson(Map<String, dynamic>.from(r as Map)))
        .toList(),
    includeUnknown: json['includeUnknown'] as bool,
  );
}
