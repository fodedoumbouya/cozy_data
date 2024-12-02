library utils;

import 'package:flutter/foundation.dart';

/// Utility functions for flattening and unflattening nested JSON structures.
///
/// This file provides functions to handle complex JSON structures by converting
/// nested arrays into flattened string representations and vice versa.
///
/// Example usage:
/// ```dart
/// // Original JSON
/// var json = {
///   "users": [
///     {"id": 1, "name": "John"},
///     {"id": 2, "name": "Jane"}
///   ],
///   "simple": "value"
/// };
///
/// // Flatten the JSON
/// var flattened = flattenJson(json);
/// // Result:
/// // {
/// //   "users": "users_l_0_l_id=1*users_l_0_l_name=John*users_l_1_l_id=2*users_l_1_l_name=Jane",
/// //   "simple": "value"
/// // }
///
/// // Unflatten back to original structure
/// var unflattened = unflattenJson(flattened);
/// // Returns to original JSON structure
/// ```
///
/// The flattening process uses the following format for nested arrays:
/// - Lists are converted to strings with items separated by '*'
/// - Each list item's position is marked with '_l_index'
/// - For objects in lists, each field is represented as 'key_l_index_l_field=value'

/// Flattens a nested JSON structure by converting arrays into string representations.
///
/// [json] The input JSON map to flatten
/// Returns a new map where nested arrays are converted to string representations
///
/// This function:
/// 1. Creates a copy of the input map
/// 2. Identifies nested lists in the JSON structure
/// 3. Converts each list into a flattened string representation
/// 4. Preserves non-list values as-is

/// Reconstructs a nested JSON structure from its flattened form.
///

@protected
Map<String, dynamic> flattenJson(Map<String, dynamic> json) {
  Map<String, dynamic> result = {...json};

  void processNestedStructure(dynamic value, String key) {
    // check if the value does not contain _l_ and is a list

    if (value is List) {
      String flattenedList = value.asMap().entries.map((entry) {
        int index = entry.key;
        dynamic item = entry.value;
        if (item is Map) {
          return item.entries.map((itemEntry) {
            return '${key}_l_${index}_l_${itemEntry.key}=${itemEntry.value}';
          }).join('*');
        }

        return '${key}_l_$index=$item';
      }).join('*');

      result[key] = flattenedList;
    }
  }

  // Identify and process nested lists
  json.forEach((key, value) {
    if (value is List) {
      processNestedStructure(value, key);
    } else if (value is Map) {
      final flattened = value.entries.map((entry) {
        final index = entry.key;
        final nestedValue = entry.value;
        return 'Map_${key}_l_$index=$nestedValue';
      });
      result[key] = flattened.join('*');
    }
  });

  return result;
}

@protected
Map<String, dynamic> unflattenJson(Map<String, dynamic> flatJson) {
  Map<String, dynamic> result = {...flatJson};

  void processListField(String key) {
    if (flatJson[key] is String) {
      List<dynamic> reconstructedList = [];
      final isMap = flatJson[key].startsWith('Map_');

      final data = flatJson[key].toString().replaceAll("Map_", "");

      List<String> listParts = data.split('*');

      Map<int, Map<String, dynamic>> groupedItems = {};
      Map<String, dynamic> nestedItems = {};

      for (var part in listParts) {
        List<String> components = part.split('=');
        if (components.length == 2) {
          RegExp indexExtractor = RegExp(r'_l_(\d+)_l_');
          var match = indexExtractor.firstMatch(components[0]);

          if (match != null) {
            int index = int.parse(match.group(1)!);
            String fieldName = components[0].split('_l_').last;
            dynamic value = components[1];

            // Type conversion
            if (int.tryParse(value) != null) {
              value = int.parse(value);
            } else if (double.tryParse(value) != null) {
              value = double.parse(value);
            }
            groupedItems.putIfAbsent(index, () => {})[fieldName] = value;
          } else if (components[0].contains("_l_")) {
            // int index = groupedItems.entries.length;
            String fieldName = components[0].split('_l_').last;
            dynamic value = components[1];
            if (int.tryParse(value) != null) {
              value = int.parse(value);
            } else if (double.tryParse(value) != null) {
              value = double.parse(value);
            }
            nestedItems[fieldName] = value;
          }
        }
      }

      // Convert grouped items to list
      reconstructedList = groupedItems.values.toList();

      result[key] = isMap ? nestedItems : reconstructedList;
    }
  }

  // Find and process list fields
  List<String> listFields = flatJson.keys
      .where((key) => flatJson[key] is String && flatJson[key].contains('_l_'))
      .toList();

  for (var field in listFields) {
    processListField(field);
  }

  return result;
}
