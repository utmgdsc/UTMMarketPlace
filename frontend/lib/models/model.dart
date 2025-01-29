// Template model file for creating new models
class Model {
  final String attribute1;
  final int attribute2;

  Model({required this.attribute1, required this.attribute2});

  // Convert from JSON
  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      attribute1: json['attribute1'] as String,
      attribute2: json['attribute2'] as int,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'attribute1': attribute1,
      'attribute2': attribute2,
    };
  }
}
