import 'package:project/models/tag.dart';

/// Represents a filtering option for a filter.
class FilterOption {
  /// [String] the displayed name of the filter option.
  final String description;

  ///[bool] whether the filter option is selected or not.
  bool filterBy;

  final Tag? tag;

  /// Creates an instance of [FilterOption] with the given filter option description
  FilterOption({required this.description, required this.filterBy, this.tag});
}
