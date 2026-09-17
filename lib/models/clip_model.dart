enum TransitionType { none, fade, crossDissolve, wipe, slide }

enum EffectType { none, grayscale, sepia, brightness, contrast, blur, speed }

class VideoClip {
  final String id;
  String filePath;
  Duration sourceStart; // trim start within original file
  Duration sourceEnd;   // trim end within original file
  Duration timelineStart; // position on the track timeline
  TransitionType transitionIn;
  EffectType effect;
  double effectIntensity; // 0.0 - 1.0
  String? thumbnailPath;

  VideoClip({
    required this.id,
    required this.filePath,
    required this.sourceStart,
    required this.sourceEnd,
    required this.timelineStart,
    this.transitionIn = TransitionType.none,
    this.effect = EffectType.none,
    this.effectIntensity = 0.5,
    this.thumbnailPath,
  });

  Duration get duration => sourceEnd - sourceStart;

  VideoClip copyWith({
    Duration? sourceStart,
    Duration? sourceEnd,
    Duration? timelineStart,
    TransitionType? transitionIn,
    EffectType? effect,
    double? effectIntensity,
  }) {
    return VideoClip(
      id: id,
      filePath: filePath,
      sourceStart: sourceStart ?? this.sourceStart,
      sourceEnd: sourceEnd ?? this.sourceEnd,
      timelineStart: timelineStart ?? this.timelineStart,
      transitionIn: transitionIn ?? this.transitionIn,
      effect: effect ?? this.effect,
      effectIntensity: effectIntensity ?? this.effectIntensity,
      thumbnailPath: thumbnailPath,
    );
  }
}
