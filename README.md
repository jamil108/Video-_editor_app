# Video Editor App (Flutter)

Multi-track mobile video editor starter — import clips, arrange on multiple
tracks, apply transitions + effects, export via FFmpeg.

## Setup

```bash
flutter create --project-name video_editor_app .   # if pubspec/lib already exist, skip this
flutter pub get
flutter run
```

Requires Flutter 3.x+. Android needs `minSdkVersion 24+` (set in
`android/app/build.gradle`) for FFmpegKit.

## Architecture

- `lib/models/` — `VideoClip`, `Track`, `ProjectState` (the single source of
  truth, uses `ChangeNotifier` + `provider`)
- `lib/services/video_service.dart` — all FFmpeg work: per-clip trim/effect
  render, per-track crossfade-transition concat, final multi-track overlay
  export
- `lib/widgets/` — `TimelineWidget` (multi-track scrollable timeline),
  `TrackWidget` (one lane), `ClipWidget` (draggable clip block),
  `InspectorPanel` (transition/effect controls for selected clip)
- `lib/screens/` — `HomeScreen`, `EditorScreen` (preview + timeline + inspector)

## What works now

- Import video from device storage
- Multiple tracks (video/overlay/audio/text lanes)
- Drag clips along the timeline
- Per-clip trim (via `sourceStart`/`sourceEnd`)
- Per-clip effects: grayscale, sepia, brightness, contrast, blur, speed
- Per-clip transitions: fade, cross-dissolve, wipe, slide (ffmpeg `xfade`)
- Export: renders each clip → concatenates each track with transitions →
  overlays tracks into final MP4

## Known gaps to build next (real project, not toy)

1. **Preview playback of the *edited* timeline** — right now the preview
   player is wired but not fed a live-composited stream; typically you'd
   either re-render a low-res proxy on scrub, or use a native player that
   supports filter graphs live (e.g. a custom platform channel).
2. **Accurate transition offsets** — `renderTrack()` approximates crossfade
   offsets from nominal clip durations; for frame-accurate results, probe
   each rendered clip's actual duration with `ffprobe` before building the
   `xfade` chain.
3. **Audio track mixing** — audio tracks aren't yet mixed into the export;
   add an `amix`/`amerge` filter stage.
4. **Undo/redo** — `ProjectState` has no history stack yet.
5. **Persistence** — projects aren't saved/loaded; add JSON serialization of
   `ProjectState` to local storage.
6. **Export progress** — `FFmpegKit.executeAsync` with a statistics callback
   would let you show a real progress bar instead of a spinner.
7. **Performance** — thumbnail generation and rendering should move off the
   main isolate for anything beyond short clips.

## Next steps

This is a real, ongoing codebase — best continued in an actual dev
environment (Android Studio / VS Code with Flutter, or Claude Code) rather
than one-shot in chat, since features like #1–#7 above each involve
iterating against a real device/emulator.
