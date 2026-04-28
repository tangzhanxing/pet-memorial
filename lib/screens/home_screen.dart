import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/pet_model.dart';
import '../providers/pet_provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Memorial'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Consumer<PetProvider>(
        builder: (context, petProvider, child) {
          if (petProvider.pets.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildPetView(context, petProvider);
        },
      ),
      floatingActionButton: Consumer<PetProvider>(
        builder: (context, petProvider, child) {
          return FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/create'),
            icon: const Icon(Icons.add),
            label: const Text('New Pet'),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No pets yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create a digital companion for your\nbeloved departed pet',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/create'),
            icon: const Icon(Icons.add),
            label: const Text('Create Your First Pet'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetView(BuildContext context, PetProvider petProvider) {
    final pet = petProvider.currentPet;
    if (pet == null) return _buildEmptyState(context);

    return Column(
      children: [
        // 宠物选择器（横向滚动）
        _buildPetSelector(petProvider),

        // 3D模型展示区域
        Expanded(
          flex: 3,
          child: _build3DViewer(pet),
        ),

        // 互动按钮区域
        Expanded(
          flex: 2,
          child: _buildInteractionPanel(context, pet),
        ),
      ],
    );
  }

  Widget _buildPetSelector(PetProvider petProvider) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: petProvider.pets.length,
        itemBuilder: (context, index) {
          final pet = petProvider.pets[index];
          final isSelected = pet.id == petProvider.currentPet?.id;
          return GestureDetector(
            onTap: () => petProvider.selectPet(pet),
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    pet.species == 'dog' ? Icons.pets : Icons.catching_pokemon,
                    size: 32,
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

Widget _build3DViewer(PetModel pet) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: pet.localModelPath != null
        ? ModelViewer(
          src: pet.localModelPath!,
          alt: '3D model of ${pet.name}',
          ar: false,
          autoRotate: true,
          cameraControls: true,
          backgroundColor: const Color(0xF5F5F5),
        )
        : _buildPlaceholder3D(pet),
      ),
    );
  }

  Widget _buildPlaceholder3D(PetModel pet) {
    // 演示模式：显示占位符
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            pet.species == 'dog' ? Icons.pets : Icons.catching_pokemon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            pet.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '3D Model Coming Soon...',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 4),
          Text(
            '(Upload photos to generate)',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

Widget _buildInteractionPanel(BuildContext context, PetModel pet) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        // 名字和基本信息
        Text(
          pet.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          pet.species == 'dog' ? 'Dog' : pet.species == 'cat' ? 'Cat' : 'Pet',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const Spacer(),

        // 互动按钮组
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context,
              icon: Icons.campaign,
              label: 'Call',
              onTap: () => _onCallPet(context, pet),
            ),
            _buildActionButton(
              context,
              icon: Icons.pan_tool,
              label: 'Pet',
              onTap: () => _onPetPet(context, pet),
            ),
            _buildActionButton(
              context,
              icon: Icons.pets,
              label: 'Sit',
              onTap: () => _onCommandPet(context, pet, 'sit'),
            ),
            _buildActionButton(
              context,
              icon: Icons.nightlight,
              label: 'Sleep',
              onTap: () => _onCommandPet(context, pet, 'sleep'),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

void _onCallPet(BuildContext context, PetModel pet) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${pet.name} is responding...'),
      duration: const Duration(seconds: 2),
    ),
  );
}

void _onPetPet(BuildContext context, PetModel pet) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('You pet ${pet.name}'),
      duration: const Duration(seconds: 1),
    ),
  );
}

void _onCommandPet(BuildContext context, PetModel pet, String command) {
  final messages = {
    'sit': '${pet.name} is sitting down',
    'sleep': '${pet.name} is going to sleep',
    'stand': '${pet.name} is standing up',
    'shake': '${pet.name} is shaking',
  };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(messages[command] ?? '${pet.name} is doing something'),
      duration: const Duration(seconds: 2),
    ),
  );
}
}