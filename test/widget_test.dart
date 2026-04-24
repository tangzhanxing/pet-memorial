
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_memorial/main.dart';
import 'package:pet_memorial/models/pet_data.dart';

void main() {
  test('PetData serialization', () {
    final pet = PetData(
      id: '1',
      name: 'Test Pet',
      species: 'dog',
      breed: 'Test Breed',
      createdAt: DateTime.now(),
    );
    final json = pet.toJson();
    final restored = PetData.fromJson(json);
    expect(restored.name, pet.name);
    expect(restored.species, pet.species);
  });
}
