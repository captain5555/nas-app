import SwiftUI

struct BrowserView: View {
    @StateObject private var viewModel = BrowserViewModel()
    @State private var selectedMaterial: Material?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("加载中...")
                } else {
                    if viewModel.materials.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "folder")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("暂无素材")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.materials) { material in
                                    MaterialGridItem(material: material) {
                                        selectedMaterial = material
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle(viewModel.currentFolder?.name ?? "浏览")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.refresh()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(item: $selectedMaterial) { material in
                MaterialDetailView(material: material)
            }
        }
    }
}

struct BrowserView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserView()
    }
}
