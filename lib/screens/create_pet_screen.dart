import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pet_model.dart';
import '../providers/pet_provider.dart';
import '../services/model_gen_service.dart';

class CreatePetScreen extends StatefulWidget {
  const CreatePetScreen({super.key});

  @override
  State<CreatePetScreen> createState() => _CreatePetScreenState();
}

class _CreatePetScreenState extends State<CreatePetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedSpecies = 'dog';

  final List<XFile> _selectedImages = [];
  bool _isGenerating = false;
  String _generationStatus = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Digital Companion'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 照片上传区域
              _buildPhotoSection(),
              const SizedBox(height: 24),

              // 基本信息
              _buildBasicInfoSection(),
              const SizedBox(height: 24),

              // 生成按钮
              _buildGenerateButton(),
              const SizedBox(height: 16),

              // 进度显示
              if (_isGenerating) _buildProgress(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Upload 5-20 photos of your pet from different angles',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 12),

        // 已选照片网格
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[300],
                      ),
                      child: const Icon(Icons.photo, size: 40),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImages.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

        const SizedBox(height: 12),

        // 上传按钮
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImages(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _pickImages(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Basic Info', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),

        // 名字
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Pet Name *',
            hintText: "e.g., Buddy, Max, Luna",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your pet\'s name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // 物种选择
        DropdownButtonFormField<String>(
          value: _selectedSpecies,
          decoration: const InputDecoration(
            labelText: 'Species *',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'dog', child: Text('Dog')),
            DropdownMenuItem(value: 'cat', child: Text('Cat')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedSpecies = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedImages.isEmpty ? null : _generatePet,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isGenerating
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Create Digital Companion'),
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _generationStatus.contains('Completed') ? 1.0 : null,
        ),
        const SizedBox(height: 8),
        Text(
          _generationStatus,
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _pickImages(ImageSource source) async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
        if (_selectedImages.length > 20) {
          _selectedImages.removeRange(20, _selectedImages.length);
        }
      });
    }
  }

  Future<void> _generatePet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _generationStatus = 'Preparing photos...';
    });

    try {
      // 1. 保存照片到本地
      _generationStatus = 'Saving photos...';
      await Future.delayed(const Duration(seconds: 1));

      // 2. 调用3D生成服务
      _generationStatus = 'Generating 3D model...\nThis may take a few minutes';
      await Future.delayed(const Duration(seconds: 2));

      final imagePaths = _selectedImages.map((x) => x.path).toList();
      final result = await ModelGenService.generateFromImages(imagePaths);

      if (result.success) {
        _generationStatus = 'Model generated! Creating your companion...';

        // 3. 创建宠物数据
        final pet = PetModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          species: _selectedSpecies,
          localModelPath: result.modelPath,
          createdAt: DateTime.now(),
        );

        // 4. 保存到存储
        final provider = Provider.of<PetProvider>(context, listen: false);
        provider.addPet(pet);

        _generationStatus = 'Completed! ${pet.name} is ready!';

        // 5. 返回首页
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${pet.name} has been created!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(result.errorMessage ?? 'Generation failed');
      }
    } catch (e) {
      setState(() {
        _generationStatus = 'Error: $e';
        _isGenerating = false;
      });
    }
  }
}