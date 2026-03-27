import SwiftUI

struct MaterialDetailView: View {
    @StateObject private var viewModel: MaterialDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(material: Material) {
        _viewModel = StateObject(wrappedValue: MaterialDetailViewModel(material: material))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(systemName: viewModel.material.isVideo ? "video.fill" : "photo.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        )
                        .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("标题")
                                .font(.headline)
                            TextField("输入标题...", text: $viewModel.titleText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("描述")
                                .font(.headline)
                            TextEditor(text: $viewModel.descriptionText)
                                .frame(minHeight: 100)
                                .border(Color.gray.opacity(0.3), cornerRadius: 8)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("使用状态")
                                .font(.headline)
                            Picker("使用状态", selection: $viewModel.usageTag) {
                                ForEach(UsageTag.allCases, id: \.self) { tag in
                                    Text(tag.displayName).tag(tag)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("爆款标签")
                                .font(.headline)
                            Picker("爆款标签", selection: $viewModel.viralTag) {
                                ForEach(ViralTag.allCases, id: \.self) { tag in
                                    Text(tag.displayName).tag(tag)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("文件名: \(viewModel.material.filename)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let size = viewModel.material.fileSize {
                                Text("大小: \(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("素材详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.save()
                            dismiss()
                        }
                    }) {
                        if viewModel.isSaving {
                            ProgressView()
                        } else {
                            Text("保存")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(viewModel.isSaving)
                }
            }
        }
    }
}

struct MaterialDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMaterial = Material(
            id: UUID(),
            filename: "海滩日落.jpg",
            path: "/海滩日落.jpg",
            title: "三亚海滩日落",
            description: "美丽的海滩日落风景，适合发朋友圈",
            tags: MaterialTags(usage: .used, viral: .viral),
            fileSize: 2150400,
            fileModifiedAt: Date().addingTimeInterval(-86400 * 7),
            localUpdatedAt: Date().addingTimeInterval(-3600),
            folderID: nil
        )
        MaterialDetailView(material: sampleMaterial)
    }
}
