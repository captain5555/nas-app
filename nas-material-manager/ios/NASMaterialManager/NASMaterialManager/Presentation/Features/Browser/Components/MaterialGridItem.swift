import SwiftUI

struct MaterialGridItem: View {
    let material: Material
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fill)
                    .overlay(
                        Image(systemName: material.isVideo ? "video.fill" : "photo.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
                    .clipped()
                    .cornerRadius(8)

                Text(material.title ?? material.filename)
                    .font(.caption)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    TagBadge(
                        text: material.tags.usage.displayName,
                        color: material.tags.usage == .used ? .green : .orange
                    )
                    TagBadge(
                        text: material.tags.viral.displayName,
                        color: material.tags.viral == .viral ? .red : .blue
                    )
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension Material {
    var isVideo: Bool {
        let videoExtensions = ["mp4", "mov", "avi", "mkv"]
        return videoExtensions.contains((filename as NSString).pathExtension.lowercased())
    }
}
