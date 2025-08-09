import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/lang_key.dart';

class LiquidGlassInputWidget extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(File) onFileSelected;
  final VoidCallback? onMicrophonePressed;
  final bool isLoading;

  const LiquidGlassInputWidget({
    Key? key,
    required this.onSendMessage,
    required this.onFileSelected,
    this.onMicrophonePressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<LiquidGlassInputWidget> createState() => _LiquidGlassInputWidgetState();
}

class _LiquidGlassInputWidgetState extends State<LiquidGlassInputWidget>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _pulseController.dispose();
    _rippleController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showFileOptions() {
    _rippleController.forward().then((_) => _rippleController.reset());
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFileOptionsModal(),
    );
  }

  Widget _buildFileOptionsModal() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Simple drag handle
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFileOption(
                      icon: Icons.camera_alt_rounded,
                      label: AppLocalizations.text(LangKey.cv_take_photo),
                      color: AppColors.primary,
                      onTap: _takePicture,
                    ),
                    _buildFileOption(
                      icon: Icons.photo_library_rounded,
                      label: AppLocalizations.text(LangKey.cv_from_gallery),
                      color: AppColors.secondary,
                      onTap: _pickImageFromGallery,
                    ),
                    _buildFileOption(
                      icon: Icons.folder_open_rounded,
                      label: AppLocalizations.text(LangKey.cv_from_files),
                      color: AppColors.magic,
                      onTap: _pickFile,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.3),
              color.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.6),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              color: Colors.white,
              size: 28,
              shadows: [
                Shadow(
                  color: color.withValues(alpha: 0.8),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePicture() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _showPermissionDialog(AppLocalizations.text(LangKey.camera));
        return;
      }

      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        widget.onFileSelected(File(image.path));
      }
    } catch (e) {
      _showErrorDialog('${AppLocalizations.text(LangKey.cv_camera_error)}: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        widget.onFileSelected(File(image.path));
      }
    } catch (e) {
      _showErrorDialog('${AppLocalizations.text(LangKey.cv_pick_image_error)}: $e');
    }
  }

  Future<void> _pickFile() async {
    try {
      // Request storage permission for Android
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        
        if (sdkInt < 33) {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            _showPermissionDialog(AppLocalizations.text(LangKey.storage));
            return;
          }
        }
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: true,
        withReadStream: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        File? fileToUse;

        if (pickedFile.path != null) {
          fileToUse = File(pickedFile.path!);
        } else if (pickedFile.bytes != null) {
          final tempDir = await getTemporaryDirectory();
          final tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
          final tempFile = File(tempPath);
          await tempFile.writeAsBytes(pickedFile.bytes!);
          fileToUse = tempFile;
        }

        if (fileToUse != null && await fileToUse.exists()) {
          widget.onFileSelected(fileToUse);
        }
      }
    } catch (e) {
      _showErrorDialog('${AppLocalizations.text(LangKey.cv_pick_file_error)}: $e');
    }
  }

  void _showPermissionDialog(String permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.security, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(AppLocalizations.text(LangKey.request_permissions)),
          ],
        ),
        content: Text(AppLocalizations.text(LangKey.cv_permission_needed).replaceAll('{permission}', permission)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.text(LangKey.cv_cancel)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.text(LangKey.cv_go_to_settings)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 10),
            Text(AppLocalizations.text(LangKey.error)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.text(LangKey.close), style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(text);
      _textController.clear();
      // Manually trigger text change check after clearing
      _onTextChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.1),
            Colors.blue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                // File picker button
                AnimatedBuilder(
                  animation: _rippleAnimation,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple effect
                        if (_rippleAnimation.value > 0)
                          Container(
                            width: 50 + (_rippleAnimation.value * 20),
                            height: 50 + (_rippleAnimation.value * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 
                                  (1 - _rippleAnimation.value) * 0.5,
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                        // Main button
                        // GestureDetector(
                        //   onTap: _showFileOptions,
                        //   child: Container(
                        //     width: 50,
                        //     height: 50,
                        //     decoration: BoxDecoration(
                        //       gradient: LinearGradient(
                        //         begin: Alignment.topLeft,
                        //         end: Alignment.bottomRight,
                        //         colors: [
                        //           AppColors.infoLight.withValues(alpha: 0.8),
                        //           AppColors.infoLight.withValues(alpha: 0.6),
                        //         ],
                        //       ),
                        //       shape: BoxShape.circle,
                        //       boxShadow: [
                        //         BoxShadow(
                        //           color: AppColors.infoLight.withValues(alpha: 0.3),
                        //           blurRadius: 10,
                        //           offset: const Offset(0, 3),
                        //         ),
                        //       ],
                        //     ),
                        //     child: Icon(
                        //       Icons.attach_file_rounded,
                        //       color: Colors.white,
                        //       size: 24,
                        //     ),
                        //   ),
                        // ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 12),
                // Text input
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    onChanged: (_) => _onTextChanged(),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.text(LangKey.cv_enter_message),
                      hintStyle: TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      color: AppColors.neutral900,
                      fontSize: 16,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                // Send/Microphone button
                GestureDetector(
                  onTap: widget.isLoading 
                      ? null 
                      : (_hasText ? _sendMessage : widget.onMicrophonePressed),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.isLoading
                            ? [
                                Colors.grey.withValues(alpha: 0.5),
                                Colors.grey.withValues(alpha: 0.3),
                              ]
                            : _hasText
                                ? [
                                    AppColors.primary.withValues(alpha: 0.9),
                                    AppColors.primary.withValues(alpha: 0.7),
                                  ]
                                : [
                                    AppColors.sunriseTop.withValues(alpha: 0.8),
                                    AppColors.sunriseTop.withValues(alpha: 0.6),
                                  ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isLoading 
                              ? Colors.grey 
                              : _hasText 
                                  ? AppColors.primary
                                  : AppColors.sunriseTop)
                              .withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              key: ValueKey(_hasText),
                              _hasText ? Icons.send_rounded : Icons.mic_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}