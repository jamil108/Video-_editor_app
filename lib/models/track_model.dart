import 'clip_model.dart';

enum TrackType { video, overlay, audio, text }

class Track {
  final String id;
  final TrackType type;
  String name;
  List<VideoClip> clips;
  bool muted;
  bool visible;

  Track({
    required this.id,
    required this.type,
    required this.name,
    List<VideoClip>? clips,
    this.muted = false,
    this.visible = true,
  }) : clips = clips ?? [];

  Duration get totalDuration {
    if (clips.isEmpty) return Duration.zero;
    final last = clips.reduce(
      (a, b) => (a.timelineStart + a.duration) > (b.timelineStart + b.duration) ? a : b,
    );
    return last.timelineStart + last.duration;
  }
}
