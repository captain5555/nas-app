import Foundation
import CoreData

class MaterialRepository {
    private let context = CoreDataStack.shared.viewContext

    func fetchMaterials(for folderID: UUID) -> [Material] {
        let request: NSFetchRequest<Material> = Material.fetchRequest()
        request.predicate = NSPredicate(format: "folder.id == %@", folderID as CVarArg)
        do {
            let cdMaterials = try context.fetch(request)
            return cdMaterials.map { $0.toDomain() }
        } catch {
            print("Failed to fetch materials: \(error)")
            return []
        }
    }

    func fetchMaterial(by id: UUID) -> Material? {
        let request: NSFetchRequest<Material> = Material.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            if let cdMaterial = try context.fetch(request).first {
                return cdMaterial.toDomain()
            }
        } catch {
            print("Failed to fetch material: \(error)")
        }
        return nil
    }

    func saveMaterial(_ material: Material) {
        let cdMaterial = Material(context: context)
        cdMaterial.id = material.id
        cdMaterial.filename = material.filename
        cdMaterial.path = material.path
        cdMaterial.title = material.title
        cdMaterial.descriptionText = material.description
        cdMaterial.usageTag = material.tags.usage.rawValue
        cdMaterial.viralTag = material.tags.viral.rawValue
        if let fileSize = material.fileSize {
            cdMaterial.fileSize = fileSize
        }
        cdMaterial.fileModifiedAt = material.fileModifiedAt
        cdMaterial.localUpdatedAt = material.localUpdatedAt
        CoreDataStack.shared.saveContext()
    }

    func updateMaterial(_ material: Material) {
        guard let id = material.id else { return }
        let request: NSFetchRequest<Material> = Material.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            if let cdMaterial = try context.fetch(request).first {
                cdMaterial.title = material.title
                cdMaterial.descriptionText = material.description
                cdMaterial.usageTag = material.tags.usage.rawValue
                cdMaterial.viralTag = material.tags.viral.rawValue
                cdMaterial.localUpdatedAt = Date()
                CoreDataStack.shared.saveContext()
            }
        } catch {
            print("Failed to update material: \(error)")
        }
    }
}

extension Material {
    func toDomain() -> Material {
        let usage = UsageTag(rawValue: usageTag ?? "unused") ?? .unused
        let viral = ViralTag(rawValue: viralTag ?? "not_viral") ?? .notViral
        return Material(
            id: id ?? UUID(),
            filename: filename ?? "",
            path: path ?? "",
            title: title,
            description: descriptionText,
            tags: MaterialTags(usage: usage, viral: viral),
            fileSize: fileSize != 0 ? fileSize : nil,
            fileModifiedAt: fileModifiedAt,
            localUpdatedAt: localUpdatedAt ?? Date(),
            folderID: folder?.id
        )
    }
}
