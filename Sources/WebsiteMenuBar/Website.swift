import Foundation

struct Website: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var title: String
    var url: String
}
