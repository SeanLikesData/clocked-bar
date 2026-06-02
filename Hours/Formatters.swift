import Foundation

func formatDuration(_ totalSeconds: Int) -> String {
    let h = totalSeconds / 3600
    let m = (totalSeconds % 3600) / 60
    let s = totalSeconds % 60
    if h > 0 {
        return String(format: "%d:%02d:%02d", h, m, s)
    }
    return String(format: "%d:%02d", m, s)
}

func formatDurationShort(_ totalSeconds: Int) -> String {
    let h = totalSeconds / 3600
    let m = (totalSeconds % 3600) / 60
    if h > 0 {
        return String(format: "%dh %dm", h, m)
    }
    return String(format: "%dm", m)
}
