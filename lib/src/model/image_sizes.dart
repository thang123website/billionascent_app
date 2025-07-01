class ImageSizes {
  final List<String> origin;
  final List<String> thumb;
  final List<String> medium;
  final List<String> small;

  ImageSizes({
    required this.origin,
    required this.thumb,
    required this.medium,
    required this.small,
  });

  // Empty constructor for null safety
  factory ImageSizes.empty() {
    return ImageSizes(
      origin: [],
      thumb: [],
      medium: [],
      small: [],
    );
  }

  factory ImageSizes.fromJson(Map<String, dynamic> json) {
    return ImageSizes(
      origin: List<String>.from(json['origin'] as List? ?? []),
      thumb: List<String>.from(json['thumb'] ?? json['origin'] as List? ?? []),
      medium: List<String>.from(json['medium'] ?? json['origin'] as List? ?? []),
      small: List<String>.from(json['small'] ?? json['origin'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'origin': origin, 'thumb': thumb, 'medium': medium, 'small': small};
  }
}
