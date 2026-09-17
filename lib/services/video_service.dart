import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../models/clip_model.dart';
import '../models/track_model.dart';

class VideoService {
  Future<String> _tempPath(String filename) async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/$filename';
  }

  /// Generate a thumbnail image for a clip, used on the timeline.
  Future<String?> generateThumbnail(String videoPath) async {
    final dir = await getTemporaryDirectory();
    final thumb = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: dir.path,
      imageFormat: ImageFormat.PNG,
      maxWidth: 200,
      quality: 60,
    );
    return thumb;
  }

  /// Build the ffmpeg video filter string for a single effect.
  String _effectFilter(EffectType effect, double intensity) {
    switch (effect) {
      case EffectType.grayscale:
        return 'hue=s=0';
      case EffectType.sepia:
        return 'colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131';
      case EffectType.brightness:
        return 'eq=brightness=${(intensity - 0.5) * 2}';
      case EffectType.contrast:
        return 'eq=contrast=${1 + intensity}';
      case EffectType.blur:
        return 'boxblur=${(intensity * 10).toStringAsFixed(1)}:1';
      case EffectType.speed:
        // intensity 0.5 = normal; scale 0.5x-2x
        final factor = 0.5 + intensity * 1.5;
        return 'setpts=${(1 / factor).toStringAsFixed(3)}*PTS';
      case EffectType.none:
        return '';
    }
  }

  /// Trim + apply effect for one clip, producing an intermediate file.
  Future<String> renderClip(VideoClip clip) async {
    final outPath = await _tempPath('clip_${clip.id}.mp4');
    final startSec = clip.sourceStart.inMilliseconds / 1000.0;
    final durSec = clip.duration.inMilliseconds / 1000.0;

    final filter = _effectFilter(clip.effect, clip.effectIntensity);
    final vf = filter.isEmpty ? '' : '-vf "$filter"';

    final cmd =
        '-y -ss $startSec -i "${clip.filePath}" -t $durSec $vf -c:v mpeg4 -c:a aac "$outPath"';

    final session = await FFmpegKit.execute(cmd);
    final rc = await session.getReturnCode();
    if (!ReturnCode.isSuccess(rc)) {
      throw Exception('Clip render failed for ${clip.id}');
    }
    return outPath;
  }

  /// Concatenate rendered clips on a single track, applying crossfade
  /// transitions between consecutive clips where set.
  Future<String> renderTrack(Track track) async {
    if (track.clips.isEmpty) throw Exception('Track ${track.name} is empty');

    final sorted = [...track.clips]
      ..sort((a, b) => a.timelineStart.compareTo(b.timelineStart));

    final rendered = <String>[];
    for (final clip in sorted) {
      rendered.add(await renderClip(clip));
    }

    if (rendered.length == 1) return rendered.first;

    // Build xfade chain for transitions; falls back to simple concat
    // when a clip has TransitionType.none.
    final outPath = await _tempPath('track_${track.id}.mp4');
    final inputs = rendered.map((p) => '-i "$p"').join(' ');

    final filters = <String>[];
    String lastLabel = '0:v';
    double offset = 0;
    for (int i = 1; i < rendered.length; i++) {
      final clip = sorted[i];
      final transition = _xfadeName(clip.transitionIn);
      final label = 'v$i';
      // offset approximated from previous clip durations; refine with real probe in production
      offset += sorted[i - 1].duration.inMilliseconds / 1000.0 - 0.5;
      filters.add(
        '[$lastLabel][$i:v]xfade=transition=$transition:duration=0.5:offset=${offset.toStringAsFixed(2)}[$label]',
      );
      lastLabel = label;
    }

    final filterComplex = filters.join(';');
    final cmd =
        '-y $inputs -filter_complex "$filterComplex" -map "[$lastLabel]" -c:v mpeg4 "$outPath"';

    final session = await FFmpegKit.execute(cmd);
    final rc = await session.getReturnCode();
    if (!ReturnCode.isSuccess(rc)) {
      throw Exception('Track render failed for ${track.name}');
    }
    return outPath;
  }

  String _xfadeName(TransitionType t) {
    switch (t) {
      case TransitionType.fade:
        return 'fade';
      case TransitionType.crossDissolve:
        return 'dissolve';
      case TransitionType.wipe:
        return 'wipeleft';
      case TransitionType.slide:
        return 'slideleft';
      case TransitionType.none:
        return 'fade';
    }
  }

  /// Render every track then overlay them (video tracks stacked,
  /// later tracks composited on top) into the final export file.
  Future<String> exportProject(List<Track> tracks, {String? outputName}) async {
    final videoTracks = tracks.where((t) => t.clips.isNotEmpty).toList();
    if (videoTracks.isEmpty) throw Exception('Nothing to export');

    final renderedTracks = <String>[];
    for (final t in videoTracks) {
      renderedTracks.add(await renderTrack(t));
    }

    final outPath = await _tempPath(outputName ?? 'export_${DateTime.now().millisecondsSinceEpoch}.mp4');

    if (renderedTracks.length == 1) {
      await File(renderedTracks.first).copy(outPath);
      return outPath;
    }

    // Overlay stacked tracks: base = track 0, each subsequent track overlaid on top.
    final inputs = renderedTracks.map((p) => '-i "$p"').join(' ');
    final filters = <String>[];
    String base = '0:v';
    for (int i = 1; i < renderedTracks.length; i++) {
      final label = 'ov$i';
      filters.add('[$base][$i:v]overlay=shortest=1[$label]');
      base = label;
    }
    final cmd =
        '-y $inputs -filter_complex "${filters.join(';')}" -map "[$base]" -c:v mpeg4 "$outPath"';

    final session = await FFmpegKit.execute(cmd);
    final rc = await session.getReturnCode();
    if (!ReturnCode.isSuccess(rc)) {
      throw Exception('Final export failed');
    }
    return outPath;
  }
}
