import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/ai_service.dart';
import '../../constants/theme_constants.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  final AiService _aiService = AiService();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  int _currentTab = 0;

  final _apiUrlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _modelController = TextEditingController();
  final _titlePromptController = TextEditingController();
  final _descriptionPromptController = TextEditingController();
  final _safetyRulesController = TextEditingController();
  final _replacementWordsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final settings = await _aiService.getAiSettings();
      _apiUrlController.text = settings['api_url'] ?? '';
      _apiKeyController.text = settings['api_key'] ?? '';
      _modelController.text = settings['model'] ?? '';
      _titlePromptController.text = settings['title_prompt'] ?? '';
      _descriptionPromptController.text = settings['description_prompt'] ?? '';
      _safetyRulesController.text = settings['safety_rules'] ?? '';
      _replacementWordsController.text = settings['replacement_words'] ?? '';
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.role != 'admin') {
      if (mounted) {
        _showError('Only admins can modify AI settings');
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _aiService.updateAiSettingsRaw(
        apiUrl: _apiUrlController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
        model: _modelController.text.trim(),
        titlePrompt: _titlePromptController.text.trim(),
        descriptionPrompt: _descriptionPromptController.text.trim(),
        safetyRules: _safetyRulesController.text.trim(),
        replacementWords: _replacementWordsController.text.trim(),
      );

      if (mounted) {
        _showSuccess('Saved successfully');
      }
    } catch (e) {
      if (mounted) {
        _showError('Save failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSuccess(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _titlePromptController.dispose();
    _descriptionPromptController.dispose();
    _safetyRulesController.dispose();
    _replacementWordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('AI Settings'),
        trailing: _isSaving
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveSettings,
                child: const Text('Save'),
              ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load',
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CupertinoButton.filled(
                          onPressed: _loadSettings,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Tab selector
                      Padding(
                        padding: const EdgeInsets.all(ThemeConstants.spacingMd),
                        child: CupertinoSegmentedControl<int>(
                          groupValue: _currentTab,
                          onValueChanged: (value) {
                            setState(() {
                              _currentTab = value;
                            });
                          },
                          children: const {
                            0: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: Text('API Config'),
                            ),
                            1: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: Text('Prompts'),
                            ),
                            2: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: Text('Safety Rules'),
                            ),
                            3: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: Text('Replacements'),
                            ),
                          },
                        ),
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: _currentTab,
                          children: [
                            _buildApiConfigTab(),
                            _buildPromptsTab(),
                            _buildSafetyRulesTab(),
                            _buildReplacementWordsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildApiConfigTab() {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      children: [
        _buildSection(
          title: 'API Configuration',
          children: [
            _buildTextField(
              controller: _apiUrlController,
              placeholder: 'API URL',
              prefix: CupertinoIcons.link,
            ),
            const SizedBox(height: ThemeConstants.spacingMd),
            _buildTextField(
              controller: _apiKeyController,
              placeholder: 'API Key',
              prefix: CupertinoIcons.lock,
              obscureText: true,
            ),
            const SizedBox(height: ThemeConstants.spacingMd),
            _buildTextField(
              controller: _modelController,
              placeholder: 'Model Name',
              prefix: CupertinoIcons.circle_grid_3x3,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPromptsTab() {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      children: [
        _buildSection(
          title: 'Prompt Configuration',
          children: [
            _buildTextField(
              controller: _titlePromptController,
              placeholder: 'Title Generation Prompt',
              prefix: CupertinoIcons.doc_text,
              minLines: 5,
              maxLines: 10,
            ),
            const SizedBox(height: ThemeConstants.spacingMd),
            _buildTextField(
              controller: _descriptionPromptController,
              placeholder: 'Description Generation Prompt',
              prefix: CupertinoIcons.doc_text_fill,
              minLines: 5,
              maxLines: 10,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSafetyRulesTab() {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      children: [
        _buildSection(
          title: 'Safety Rules',
          children: [
            _buildTextField(
              controller: _safetyRulesController,
              placeholder: 'Safety Rules',
              prefix: CupertinoIcons.shield_fill,
              minLines: 8,
              maxLines: 15,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReplacementWordsTab() {
    return ListView(
      padding: const EdgeInsets.all(ThemeConstants.spacingMd),
      children: [
        _buildSection(
          title: 'Replacement Words',
          children: [
            _buildTextField(
              controller: _replacementWordsController,
              placeholder: 'Replacement Words (JSON format)',
              prefix: CupertinoIcons.arrow_right_arrow_left,
              minLines: 8,
              maxLines: 15,
            ),
            const SizedBox(height: ThemeConstants.spacingSm),
            const Text(
              'Format: JSON array, e.g. [{"original":"sensitive1","replacement":"replace1"},{"original":"sensitive2","replacement":"replace2"}]',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        const SizedBox(height: ThemeConstants.spacingSm),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData prefix,
    bool obscureText = false,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacingMd,
        vertical: ThemeConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusMd),
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        obscureText: obscureText,
        minLines: minLines,
        maxLines: maxLines,
        decoration: null,
        style: const TextStyle(fontSize: 16),
        prefix: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(prefix, size: 20),
        ),
      ),
    );
  }
}
