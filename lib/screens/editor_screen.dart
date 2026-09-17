import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import '../models/clip_model.dart';
import '../models/project_state.dart';
import '../services/video_service.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/inspector_panel.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final VideoService _videoService = VideoService();
  VideoPlayerController? _previewController;
  bool _exporting = false;
  double _exportProgress = 0;

  Future<void> _importVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;
    final project = context.read<ProjectState>();

    Duration duration = const Duration(seconds: 5);
    try {
      final vc = VideoPlayerController.file(File(path));
      await vc.initialize();
      duration = vc.value.duration;
      await vc.dispose();
    } catch (_) {
      // fall back to default duration if probing fails
    }

    final thumb = await _videoService.generateThumbnail(path);

    final track = project.tracks.first;
    final clip = VideoClip(
      id: const Uuid().v4(),
      filePath: path,
      sourceStart: Duration.zero,
      sourceEnd: duration,
      timelineStart: track.totalDuration,
      thumbnailPath: thumb,
    );
    project.addClipToTrack(track.id, clip);
  }

  Future<void> _exportVideo() async {
    final project = context.read<ProjectState>();
    setState(() => _exporting = true);
    try {
      final outputPath = await _videoService.exportProject(project.tracks);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export complete: $outputPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  void dispose() {
    _previewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14161F),
        title: const Text('Editor'),
        actions: [
          IconButton(icon: const Icon(Icons.file_upload_outlined), onPressed: _importVideo),
          IconButton(
            icon: _exporting
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.ios_share),
            onPressed: _exporting ? null : _exportVideo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: _previewController != null && _previewController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _previewController!.value.aspectRatio,
                      child: VideoPlayer(_previewController!),
                    )
                  : const Center(
                      child: Text('Preview', style: TextStyle(color: Colors.white24)),
                    ),
            ),
          ),
          const InspectorPanel(),
          const Expanded(flex: 3, child: TimelineWidget()),
        ],
      ),
    );
  }
}
