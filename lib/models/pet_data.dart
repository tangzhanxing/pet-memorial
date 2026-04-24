class PetData {
  final String id;
  final String name;
  final String species;       // 物种：dog, cat, other
  final String breed;         // 品种
  final String? modelPath;    // 3D模型本地路径
  final String? soundPath;    // 声音文件本地路径
  final List<String> photoPaths;  // 原始照片路径列表
  final DateTime createdAt;
  final DateTime? birthDate;
  final DateTime? deathDate;
  final String? memoryText;   // 纪念文字
  final bool isAnimating;     // 是否正在播放动画

  PetData({
    required this.id,
    required this.name,
    required this.species,
    this.breed = '',
    this.modelPath,
    this.soundPath,
    this.photoPaths = const [],
    required this.createdAt,
    this.birthDate,
    this.deathDate,
    this.memoryText,
    this.isAnimating = false,
  });

  PetData copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    String? modelPath,
    String? soundPath,
    List<String>? photoPaths,
    DateTime? createdAt,
    DateTime? birthDate,
    DateTime? deathDate,
    String? memoryText,
    bool? isAnimating,
  }) {
    return PetData(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      modelPath: modelPath ?? this.modelPath,
      soundPath: soundPath ?? this.soundPath,
      photoPaths: photoPaths ?? this.photoPaths,
      createdAt: createdAt ?? this.createdAt,
      birthDate: birthDate ?? this.birthDate,
      deathDate: deathDate ?? this.deathDate,
      memoryText: memoryText ?? this.memoryText,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'species': species,
    'breed': breed,
    'modelPath': modelPath,
    'soundPath': soundPath,
    'photoPaths': photoPaths,
    'createdAt': createdAt.toIso8601String(),
    'birthDate': birthDate?.toIso8601String(),
    'deathDate': deathDate?.toIso8601String(),
    'memoryText': memoryText,
  };

  factory PetData.fromJson(Map<String, dynamic> json) => PetData(
    id: json['id'],
    name: json['name'],
    species: json['species'],
    breed: json['breed'] ?? '',
    modelPath: json['modelPath'],
    soundPath: json['soundPath'],
    photoPaths: List<String>.from(json['photoPaths'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
    birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
    deathDate: json['deathDate'] != null ? DateTime.parse(json['deathDate']) : null,
    memoryText: json['memoryText'],
  );
}