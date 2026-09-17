import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'clip_model.dart';
import 'track_model.dart';

class ProjectState extends ChangeNotifier {
  final List<Track> tracks = [
    Track(id: const Uuid().v4(), type: TrackType.video, name: 'Video 1'),
  ];

  double pixelsPerSecond = 60.0; // timeline zoom level
  Duration playhead = Duration.zero;
  String? selectedClipId;

  Duration get projectDuration {
    Duration max = Duration.zero;
    for (final t in tracks) {
      if (t.totalDuration > max) max = t.totalDuration;
    }
    return max;
  }

  void addTrack(TrackType type) {
    tracks.add(Track(
      id: const Uuid().v4(),
      type: type,
      name: '${type.name[0].toUpperCase()}${type.name.substring(1)} ${tracks.where((t) => t.type == type).length + 1}',
    ));
    notifyListeners();
  }

  void removeTrack(String trackId) {
    tracks.removeWhere((t) => t.id == trackId);
    notifyListeners();
  }

  void addClipToTrack(String trackId, VideoClip clip) {
    final track = tracks.firstWhere((t) => t.id == trackId);
    track.clips.add(clip);
    notifyListeners();
  }

  void removeClip(String clipId) {
    for (final t in tracks) {
      t.clips.removeWhere((c) => c.id == clipId);
    }
    if (selectedClipId == clipId) selectedClipId = null;
    notifyListeners();
  }

  void selectClip(String? clipId) {
    selectedClipId = clipId;
    notifyListeners();
  }

  void updateClip(String clipId, VideoClip Function(VideoClip) update) {
    for (final t in tracks) {
      final idx = t.clips.indexWhere((c) => c.id == clipId);
      if (idx != -1) {
        t.clips[idx] = update(t.clips[idx]);
        notifyListeners();
        return;
      }
    }
  }

  void setPlayhead(Duration d) {
    playhead = d;
    notifyListeners();
  }

  void setZoom(double pxPerSec) {
    pixelsPerSecond = pxPerSec.clamp(10.0, 300.0);
    notifyListeners();
  }

  VideoClip? get selectedClip {
    if (selectedClipId == null) return null;
    for (final t in tracks) {
      for (final c in t.clips) {
        if (c.id == selectedClipId) return c;
      }
    }
    return null;
  }
}
