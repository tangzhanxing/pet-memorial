import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../models/pet_model.dart';
import '../providers/pet_provider.dart';

class PetDetailScreen extends StatefulWidget {
  final PetModel petModel;

  const PetDetailScreen({super.key, required this.petModel});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.petModel.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, widget.petModel),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, widget.petModel),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Info'),
            Tab(icon: Icon(Icons.photo_library), text: 'Photos'),
            Tab(icon: Icon(Icons.note), text: 'Notes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(context, widget.petModel),
          _buildPhotosTab(context, widget.petModel),
          _buildNotesTab(context, widget.petModel),
        ],
      ),
    );
  }

  /// Info Tab - 基本信息
  Widget _buildInfoTab(BuildContext context, PetModel pet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3D模型展示
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: pet.localModelPath != null
                  ? ModelViewer(
                      src: pet.localModelPath!,
                      alt: '3D model of ${pet.name}',
                      ar: true,
                      autoRotate: true,
                      cameraControls: true,
                    )
                  : Center(
                      child: Icon(
                        pet.species == 'dog'
                            ? Icons.pets
                            : Icons.catching_pokemon,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // 基本信息卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.pets,
                    'Name',
                    pet.name,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    Icons.category,
                    'Species',
                    pet.species == 'dog'
                        ? 'Dog 🐕'
                        : pet.species == 'cat'
                            ? 'Cat 🐱'
                            : 'Pet 🐾',
                  ),
                  const Divider(),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Created',
                    _formatDate(pet.createdAt),
                  ),
                  if (pet.birthDate != null) ...[
                    const Divider(),
                    _buildInfoRow(
                      Icons.cake,
                      'Birthday',
                      _formatDate(pet.birthDate!),
                    ),
                  ],
                  if (pet.passedDate != null) ...[
                    const Divider(),
                    _buildInfoRow(
                      Icons.favorite_border,
                      'Passed Away',
                      _formatDate(pet.passedDate!),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _onCallPet(context, pet),
                  icon: const Icon(Icons.campaign),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSoundCloneDialog(context, pet),
                  icon: const Icon(Icons.music_note),
                  label: const Text('Voice'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Photos Tab - 纪念照片集
  Widget _buildPhotosTab(BuildContext context, PetModel pet) {
    final photos = pet.memorialPhotos;

    return Column(
      children: [
        // 添加照片按钮
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _addPhoto(context, pet, ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _addPhoto(context, pet, ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ],
          ),
        ),

        // 照片网格
        Expanded(
          child: photos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No memorial photos yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add photos to preserve memories',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _showPhotoDetail(context, pet, index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.photo, size: 40),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Notes Tab - 纪念备忘录
  Widget _buildNotesTab(BuildContext context, PetModel pet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            'Memorial Notes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Write down your thoughts and memories about ${pet.name}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 16),

          // 备忘录内容
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pet.memorialNotes == null ||
                      pet.memorialNotes!.isEmpty)
                    Text(
                      'No notes yet. Tap below to add your memories...',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Text(
                      pet.memorialNotes!,
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showNotesEditor(context, pet),
                      icon: Icon(
                        pet.memorialNotes == null
                            ? Icons.add
                            : Icons.edit,
                      ),
                      label: Text(
                        pet.memorialNotes == null ? 'Add Notes' : 'Edit Notes',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 快捷短语
          Text(
            'Quick Add',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickPhrase(
                context,
                pet,
                '❤️ Forever in my heart',
              ),
              _buildQuickPhrase(
                context,
                pet,
                '🌈 Waiting at the rainbow bridge',
              ),
              _buildQuickPhrase(
                context,
                pet,
                '🐾 My faithful companion',
              ),
              _buildQuickPhrase(
                context,
                pet,
                '💕 Miss you every day',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPhrase(
      BuildContext context, PetModel pet, String phrase) {
    return ActionChip(
      label: Text(phrase),
      onPressed: () {
        final currentNotes = pet.memorialNotes ?? '';
        final newNotes =
            currentNotes.isEmpty ? phrase : '$currentNotes\n\n$phrase';
        _updateNotes(context, pet, newNotes);
      },
    );
  }

  Future<void> _addPhoto(
      BuildContext context, PetModel pet, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null && context.mounted) {
      await Provider.of<PetProvider>(context, listen: false)
          .addMemorialPhoto(pet.id, image.path);
    }
  }

  void _showPhotoDetail(BuildContext context, PetModel pet, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Photo'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Container(
              height: 300,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.photo, size: 100, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: 删除照片功能
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotesEditor(BuildContext context, PetModel pet) {
    final controller = TextEditingController(text: pet.memorialNotes ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Memorial Notes'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Write your memories here...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateNotes(context, pet, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _updateNotes(BuildContext context, PetModel pet, String notes) {
    Provider.of<PetProvider>(context, listen: false)
        .updateMemorialNotes(pet.id, notes);
  }

  void _onCallPet(BuildContext context, PetModel pet) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${pet.name} is responding...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PetModel pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet?'),
        content: Text(
            'Are you sure you want to delete ${pet.name}? This cannot be undone.'),
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

  void _showEditDialog(BuildContext context, PetModel pet) {
    final nameController = TextEditingController(text: pet.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final updated = pet.copyWith(name: nameController.text);
                Provider.of<PetProvider>(context, listen: false)
                    .updatePet(updated);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSoundCloneDialog(BuildContext context, PetModel pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Clone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.music_note, size: 60, color: Colors.purple),
            const SizedBox(height: 16),
            const Text(
              'Clone your pet\'s voice from audio recordings',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (pet.localVoicePath != null)
              Chip(
                avatar: const Icon(Icons.check, color: Colors.green, size: 18),
                label: const Text('Voice Cloned'),
              )
            else
              const Chip(
                avatar: Icon(Icons.info_outline, size: 18),
                label: Text('Not yet cloned'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Voice cloning coming soon!')),
              );
            },
            child: const Text('Clone Now'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}