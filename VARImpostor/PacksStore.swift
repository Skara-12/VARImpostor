import Foundation

// MARK: - JSON Models (v2)

struct PacksFile: Codable {
    let version: Int
    let packs: [PackJSON]
}

struct PackJSON: Codable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let categories: [CategoryJSON]
}

struct CategoryJSON: Codable {
    let id: String
    let title: String
    let items: [WordItemJSON]
}

struct WordItemJSON: Codable, Hashable {
    let text: String
    let tags: [String]
    let pop: Int?        // ✅ optional = JSON can omit it, still decodes
}

// MARK: - Store (loads packs.json from app bundle)

final class PacksStore {
    static let shared = PacksStore()

    let data: PacksFile

    private init() {
        self.data = PacksStore.loadFromBundle()
    }

    private static func loadFromBundle() -> PacksFile {
        guard let url = Bundle.main.url(forResource: "packs", withExtension: "json") else {
            fatalError("packs.json not found in app bundle. Check Target Membership.")
        }

        do {
            let raw = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(PacksFile.self, from: raw)

            guard decoded.version >= 2 else {
                fatalError("packs.json version must be >= 2 for tag-based generator.")
            }

            return decoded
        } catch {
            fatalError("Failed to decode packs.json: \(error)")
        }
    }

    func pack(id: String) -> PackJSON? {
        data.packs.first(where: { $0.id == id })
    }
}
