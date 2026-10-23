// scripts/export-video.swift
// What: re-encode one video to an mp4 that fits a size preset, using AVFoundation.
// Why: simulator recordings are large; the machine may have no ffmpeg.
// Related: compress-videos.sh (builds and runs this for a folder).
//   export-video <in.mp4> <out.mp4> [preset]    default AVAssetExportPreset1920x1080
import AVFoundation

let args = CommandLine.arguments
guard args.count >= 3 else { print("usage: export-video <in> <out> [preset]"); exit(2) }
let src = URL(fileURLWithPath: args[1])
let dst = URL(fileURLWithPath: args[2])
try? FileManager.default.removeItem(at: dst)
let preset = args.count > 3 ? args[3] : AVAssetExportPreset1920x1080
guard let session = AVAssetExportSession(asset: AVURLAsset(url: src), presetName: preset) else {
    print("no export session for preset \(preset)"); exit(1)
}
session.outputURL = dst
session.outputFileType = .mp4
session.shouldOptimizeForNetworkUse = true
let done = DispatchSemaphore(value: 0)
session.exportAsynchronously { done.signal() }
done.wait()
print(session.status == .completed ? "ok" : "failed: \(session.error?.localizedDescription ?? "unknown")")
exit(session.status == .completed ? 0 : 1)
