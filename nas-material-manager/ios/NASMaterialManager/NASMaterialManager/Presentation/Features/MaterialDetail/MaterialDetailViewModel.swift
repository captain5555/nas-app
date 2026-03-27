import Foundation
import Combine

@MainActor
class MaterialDetailViewModel: ObservableObject {
    @Published var material: Material
    @Published var titleText: String
    @Published var descriptionText: String
    @Published var usageTag: UsageTag
    @Published var viralTag: ViralTag
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let materialRepo = MaterialRepository()

    init(material: Material) {
        self.material = material
        self.titleText = material.title ?? ""
        self.descriptionText = material.description ?? ""
        self.usageTag = material.tags.usage
        self.viralTag = material.tags.viral
    }

    func save() async {
        isSaving = true
        defer { isSaving = false }

        var updated = material
        updated.title = titleText.isEmpty ? nil : titleText
        updated.description = descriptionText.isEmpty ? nil : descriptionText
        updated.tags.usage = usageTag
        updated.tags.viral = viralTag
        updated.localUpdatedAt = Date()

        materialRepo.updateMaterial(updated)
        material = updated
    }
}
