import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/pet_data.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pet = Provider.of<PetProvider>(context, listen: false).currentPet;

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pet Detail')),
        body: const Center(child: Text('No pet selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, pet),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, pet),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3D模型展示
            Container(
              height: 300,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: pet.modelPath != null
                    ? ModelViewer(
                        src: pet.modelPath!,
                        alt: '3D model of ${pet.name}',
                        ar: true,
                        autoRotate: true,
                        cameraControls: true,
                      )
                    : Center(
                        child: Icon(
                          pet.species == 'dog' ? Icons.pets : Icons.catching_pokemon,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
            ),

            // 基本信息卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildInfoCard(context, pet),
            ),

            const SizedBox(height: 16),

            // 照片画廊
            if (pet.photoPaths.isNotEmpty)
              _buildPhotoGallery(pet),

            const SizedBox(height: 24),

            // 操作按钮
            _buildActionButtons(context, pet),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, PetData pet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  pet.species == 'dog' ? Icons.pets : Icons.catching_pokemon,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (pet.breed.isNotEmpty)
                        Text(
                          pet.breed,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // 日期信息
            if (pet.birthDate != null || pet.deathDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    if (pet.birthDate != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Born', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            Text(_formatDate(pet.birthDate!)),
                          ],
                        ),
                      ),
                    if (pet.deathDate != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Passed', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            Text(_formatDate(pet.deathDate!)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

            // 纪念文字
            if (pet.memoryText != null && pet.memoryText!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pet.memoryText!,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGallery(PetData pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Photos (${pet.photoPaths.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: pet.photoPaths.length,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    pet.photoPaths[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.photo, size: 40),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, PetData pet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${pet.name}...')),
              );
            },
            icon: const Icon(Icons.campaign),
            label: const Text('Call ${pet.name}'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showSoundCloneDialog(context, pet),
            icon: const Icon(Icons.music_note),
            label: const Text('Clone Sound from Video'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showEditDialog(BuildContext context, PetData pet) {
    final nameController = TextEditingController(text: pet.name);
    final breedController = TextEditingController(text: pet.breed);
    final memoryController = TextEditingController(text: pet.memoryText ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pet'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: breedController,
                decoration: const InputDecoration(labelText: 'Breed'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: memoryController,
                decoration: const InputDecoration(labelText: 'Memory Note'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedPet = pet.copyWith(
                name: nameController.text,
                breed: breedController.text,
                memoryText: memoryController.text,
              );
              Provider.of<PetProvider>(context, listen: false).updatePet(updatedPet);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PetData pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet?'),
        content: Text('Are you sure you want to delete ${pet.name}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<PetProvider>(context, listen: false).deletePet(pet.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSoundCloneDialog(BuildContext context, PetData pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clone Sound'),
        content: const Text(
          'To clone your pet\'s voice, you need to upload a video that contains their sound. '
          'The sound will be extracted and used to create a unique voice for your digital companion.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现视频选择和声音克隆
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sound cloning coming soon!')),
              );
            },
            child: const Text('Upload Video'),
          ),
        ],
      ),
    );
  }
}