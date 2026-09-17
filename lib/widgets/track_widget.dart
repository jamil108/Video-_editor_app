import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/track_model.dart';
import '../models/project_state.dart';
import 'clip_widget.dart';

class TrackWidget extends StatelessWidget {
  final Track track;

  const TrackWidget({super.key, required this.track});

  IconData get _icon {
    switch (track.type) {
      case TrackType.video:
        return Icons.videocam;
      case TrackType.overlay:
        return Icons.layers;
      case TrackType.audio:
        return Icons.audiotrack;
      case TrackType.text:
        return Icons.text_fields;
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectState>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Track header
        Container(
          width: 90,
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            color: Color(0xFF1E2130),
            border: Border(right: BorderSide(color: Color(0xFF33374A))),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_icon, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(track.name,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(track.visible ? Icons.visibility : Icons.visibility_off,
                        size: 14, color: Colors.white54),
                    onPressed: () {
                      track.visible = !track.visible;
                      context.read<ProjectState>().notifyListeners();
                    },
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.delete_outline, size: 14, color: Colors.white54),
                    onPressed: () => context.read<ProjectState>().removeTrack(track.id),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Track lane
        Container(
          height: 72,
          width: 4000, // scrollable wide lane; parent wraps in horizontal ScrollView
          decoration: const BoxDecoration(
            color: Color(0xFF15171F),
            border: Border(bottom: BorderSide(color: Color(0xFF272B3A))),
          ),
          child: Stack(
            children: [
              for (final clip in track.clips)
                ClipWidget(clip: clip, pixelsPerSecond: project.pixelsPerSecond),
            ],
          ),
        ),
      ],
    );
  }
}
