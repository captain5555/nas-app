import Foundation
import CoreData

class FolderRepository {
    private let context = CoreDataStack.shared.viewContext

    func fetchAllFolders() -> [Folder] {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        do {
            let cdFolders = try context.fetch(request)
            return cdFolders.map { $0.toDomain() }
        } catch {
            print("Failed to fetch folders: \(error)")
            return []
        }
    }

    func fetchFolder(by id: UUID) -> Folder? {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            if let cdFolder = try context.fetch(request).first {
                return cdFolder.toDomain()
            }
        } catch {
            print("Failed to fetch folder: \(error)")
        }
        return nil
    }

    func saveFolder(_ folder: Folder) {
        let cdFolder = Folder(context: context)
        cdFolder.id = folder.id
        cdFolder.path = folder.path
        cdFolder.name = folder.name
        cdFolder.parentFolderID = folder.parentFolderID
        CoreDataStack.shared.saveContext()
    }
}

extension Folder {
    func toDomain() -> Folder {
        return Folder(
            id: id ?? UUID(),
            path: path ?? "",
            name: name ?? "",
            parentFolderID: parentFolderID
        )
    }
}
