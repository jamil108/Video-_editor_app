import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clip_model.dart';
import '../models/project_state.dart';

class InspectorPanel extends StatelessWidget {
  const InspectorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectState>();
    final clip = project.selectedClip;

    if (clip == null) {
      return const SizedBox(
        height: 56,
        child: Center(
          child: Text('Clip select karein edit karne ke liye', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ),
      );
    }

    return Container(
      color: const Color(0xFF1A1D29),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.movie_filter, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              const Text('Transition', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              DropdownButton<TransitionType>(
                value: clip.transitionIn,
                dropdownColor: const Color(0xFF2A2D3A),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                underline: const SizedBox(),
                items: TransitionType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    context.read<ProjectState>().updateClip(clip.id, (c) => c.copyWith(transitionIn: v));
                  }
                },
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              const Text('Effect', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              DropdownButton<EffectType>(
                value: clip.effect,
                dropdownColor: const Color(0xFF2A2D3A),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                underline: const SizedBox(),
                items: EffectType.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    context.read<ProjectState>().updateClip(clip.id, (c) => c.copyWith(effect: v));
                  }
                },
              ),
            ],
          ),
          if (clip.effect != EffectType.none)
            Row(
              children: [
                const Text('Intensity', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: clip.effectIntensity,
                    onChanged: (v) => context
                        .read<ProjectState>()
                        .updateClip(clip.id, (c) => c.copyWith(effectIntensity: v)),
                    activeColor: const Color(0xFF6C5CE7),
                  ),
                ),
              ],
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.read<ProjectState>().removeClip(clip.id),
              icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
              label: const Text('Remove clip', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
