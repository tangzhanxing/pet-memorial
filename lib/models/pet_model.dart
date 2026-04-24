/// 宠物数据模型
class PetModel {
  final String id;
  final String name;
  final String species; // 'dog' | 'cat' | 'other'
  final String? modelUrl; // 云端3D模型URL
  final String? localModelPath; // 本地模型路径
  final String? voiceUrl; // 克隆声音URL
  final String? localVoicePath; // 本地声音路径
  final DateTime createdAt;
  final String? thumbnailPath; // 缩略图

  PetModel({
    required this.id,
    required this.name,
    required this.species,
    this.modelUrl,
    this.localModelPath,
    this.voiceUrl,
    this.localVoicePath,
    required this.createdAt,
    this.thumbnailPath,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      modelUrl: json['modelUrl'] as String?,
      localModelPath: json['localModelPath'] as String?,
      voiceUrl: json['voiceUrl'] as String?,
      localVoicePath: json['localVoicePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'modelUrl': modelUrl,
      'localModelPath': localModelPath,
      'voiceUrl': voiceUrl,
      'localVoicePath': localVoicePath,
      'createdAt': createdAt.toIso8601String(),
      'thumbnailPath': thumbnailPath,
    };
  }

  PetModel copyWith({
    String? id,
    String? name,
    String? species,
    String? modelUrl,
    String? localModelPath,
    String? voiceUrl,
    String? localVoicePath,
    DateTime? createdAt,
    String? thumbnailPath,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      modelUrl: modelUrl ?? this.modelUrl,
      localModelPath: localModelPath ?? this.localModelPath,
      voiceUrl: voiceUrl ?? this.voiceUrl,
      localVoicePath: localVoicePath ?? this.localVoicePath,
      createdAt: createdAt ?? this.createdAt,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}