import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project_state.dart';
import '../models/track_model.dart';
import 'track_widget.dart';

class TimelineWidget extends StatelessWidget {
  const TimelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectState>();

    return Container(
      color: const Color(0xFF0F1117),
      child: Column(
        children: [
          // Zoom + add-track controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_out, color: Colors.white54, size: 18),
                  onPressed: () => project.setZoom(project.pixelsPerSecond - 20),
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_in, color: Colors.white54, size: 18),
                  onPressed: () => project.setZoom(project.pixelsPerSecond + 20),
                ),
                const Spacer(),
                PopupMenuButton<TrackType>(
                  icon: const Icon(Icons.add_box_outlined, color: Colors.white70, size: 20),
                  onSelected: (t) => project.addTrack(t),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: TrackType.video, child: Text('+ Video track')),
                    PopupMenuItem(value: TrackType.overlay, child: Text('+ Overlay track')),
                    PopupMenuItem(value: TrackType.audio, child: Text('+ Audio track')),
                    PopupMenuItem(value: TrackType.text, child: Text('+ Text track')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final track in project.tracks) TrackWidget(track: track),
                      ],
                    ),
                    // Playhead
                    Positioned(
                      left: 90 + (project.playhead.inMilliseconds / 1000.0) * project.pixelsPerSecond,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 2, color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
