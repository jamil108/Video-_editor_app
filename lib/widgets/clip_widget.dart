import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clip_model.dart';
import '../models/project_state.dart';

class ClipWidget extends StatelessWidget {
  final VideoClip clip;
  final double pixelsPerSecond;

  const ClipWidget({super.key, required this.clip, required this.pixelsPerSecond});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectState>();
    final isSelected = project.selectedClipId == clip.id;
    final width = (clip.duration.inMilliseconds / 1000.0) * pixelsPerSecond;

    return Positioned(
      left: (clip.timelineStart.inMilliseconds / 1000.0) * pixelsPerSecond,
      child: GestureDetector(
        onTap: () => context.read<ProjectState>().selectClip(clip.id),
        onHorizontalDragUpdate: (details) {
          final deltaSec = details.delta.dx / pixelsPerSecond;
          final newStartMs =
              (clip.timelineStart.inMilliseconds + deltaSec * 1000).clamp(0, double.infinity).toInt();
          context.read<ProjectState>().updateClip(
                clip.id,
                (c) => c.copyWith(timelineStart: Duration(milliseconds: newStartMs)),
              );
        },
        child: Container(
          width: width.clamp(24, double.infinity),
          height: 64,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D3A),
            border: Border.all(
              color: isSelected ? const Color(0xFF6C5CE7) : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(6),
            image: clip.thumbnailPath != null
                ? DecorationImage(
                    image: FileImage(File(clip.thumbnailPath!)),
                    fit: BoxFit.cover,
                    opacity: 0.6,
                  )
                : null,
          ),
          child: Stack(
            children: [
              if (clip.transitionIn != TransitionType.none)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.black54, Colors.transparent]),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  '${clip.duration.inSeconds}s',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
              if (clip.effect != EffectType.none)
                const Positioned(
                  right: 4,
                  bottom: 4,
                  child: Icon(Icons.auto_awesome, size: 14, color: Colors.amberAccent),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
