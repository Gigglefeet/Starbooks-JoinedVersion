import Foundation

enum FilterOption: String, CaseIterable {
    case all = "All Books"
    case rated = "Rated (1-5 ⭐)"
    case unrated = "Unrated"
    case highRated = "4-5 ⭐ Only"
    case lowRated = "1-3 ⭐ Only"
}

extension Array where Element == Book {
    func filtered(by option: FilterOption) -> [Book] {
        switch option {
        case .all:
            return self
        case .rated:
            return self.filter { $0.rating > 0 }
        case .unrated:
            return self.filter { $0.rating == 0 }
        case .highRated:
            return self.filter { $0.rating >= 4 }
        case .lowRated:
            return self.filter { $0.rating > 0 && $0.rating <= 3 }
        }
    }
} 