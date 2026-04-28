import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet_model.dart';
import '../providers/pet_provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class PetDetailScreen extends StatelessWidget {
  final PetModel petModel;

  const PetDetailScreen({super.key, required this.petModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(petModel.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, petModel),
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
                child: petModel.localModelPath != null
                    ? ModelViewer(
                        src: petModel.localModelPath!,
                        alt: '3D model of ${petModel.name}',
                        ar: true,
                        autoRotate: true,
                        cameraControls: true,
                      )
                    : Center(
                        child: Icon(
                          petModel.species == 'dog' ? Icons.pets : Icons.catching_pokemon,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
            ),

            // 基本信息卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildInfoCard(context, petModel),
            ),

            const SizedBox(height: 24),

            // 操作按钮
            _buildActionButtons(context, petModel),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, PetModel pet) {
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
                      Text(
                        pet.species == 'dog' ? 'Dog' : pet.species == 'cat' ? 'Cat' : 'Pet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Created: ${_formatDate(pet.createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PetModel pet) {
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
            label: Text('Call ${pet.name}'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _showSoundCloneDialog(context, pet),
            icon: const Icon(Icons.music_note),
            label: const Text('Clone Sound'),
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

  void _showDeleteDialog(BuildContext context, PetModel pet) {
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

  void _showSoundCloneDialog(BuildContext context, PetModel pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clone Sound'),
        content: const Text(
          'Sound cloning feature coming soon!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sound cloning coming soon!')),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}