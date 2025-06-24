import Foundation

struct ReadingStats: Codable {
    // Reading streak tracking
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastReadingDate: Date?
    
    // Books completed by year/month
    var booksCompletedByYear: [String: Int] = [:]
    var booksCompletedByMonth: [String: Int] = [:] // Format: "2025-01", "2025-02", etc.
    
    // Reading goals
    var yearlyGoal: Int = 0
    var currentYearBooksRead: Int = 0
    
    // Hangar tracking (time spent currently reading)
    var hangarEntryDates: [String: Date] = [:] // BookID -> Date entered hangar
    var totalBooksMovedToHangar: Int = 0
    var averageDaysInHangar: Double = 0.0
    
    // Rating insights
    var totalRatedBooks: Int = 0
    var averageRating: Double = 0.0
    var ratingDistribution: [Int: Int] = [:] // Rating -> Count
    
    // Achievement tracking
    var achievements: Set<String> = []
    
    // Helper computed properties
    var currentYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
    
    var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
    
    // Check if reading streak should continue
    func shouldContinueStreak() -> Bool {
        guard let lastDate = lastReadingDate else { return false }
        let calendar = Calendar.current
        let today = Date()
        
        // Same day or yesterday = continue streak
        if calendar.isDate(lastDate, inSameDayAs: today) {
            return true
        }
        
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today) {
            return calendar.isDate(lastDate, inSameDayAs: yesterday)
        }
        
        return false
    }
    
    // Calculate average days books spend in hangar
    mutating func updateAverageDaysInHangar(completedBookId: String) {
        guard let entryDate = hangarEntryDates[completedBookId] else { return }
        
        let daysInHangar = Calendar.current.dateComponents([.day], from: entryDate, to: Date()).day ?? 0
        
        // Update running average
        let totalDays = averageDaysInHangar * Double(totalBooksMovedToHangar - 1) + Double(daysInHangar)
        averageDaysInHangar = totalDays / Double(totalBooksMovedToHangar)
        
        // Clean up completed book from tracking
        hangarEntryDates.removeValue(forKey: completedBookId)
    }
}

// MARK: - Achievement Types
enum ReadingAchievement: String, CaseIterable {
    case firstBook = "First Book Completed"
    case streak7 = "7-Day Reading Streak"
    case streak30 = "30-Day Reading Streak"
    case streak100 = "100-Day Reading Streak"
    case books10 = "10 Books Read"
    case books50 = "50 Books Read"
    case books100 = "100 Books Read"
    case perfectRater = "Rated 10 Books"
    case criticRater = "Rated 50 Books"
    case yearlyGoalMet = "Yearly Goal Achieved"
    case fiveStarFan = "10 Five-Star Books"
    case speedReader = "Completed Book in 1 Day"
    case slowAndSteady = "Book in Hangar for 30+ Days"
    
    var icon: String {
        switch self {
        case .firstBook: return "book.fill"
        case .streak7, .streak30, .streak100: return "flame.fill"
        case .books10, .books50, .books100: return "books.vertical.fill"
        case .perfectRater, .criticRater: return "star.fill"
        case .yearlyGoalMet: return "target"
        case .fiveStarFan: return "heart.fill"
        case .speedReader: return "bolt.fill"
        case .slowAndSteady: return "tortoise.fill"
        }
    }
    
    var description: String {
        switch self {
        case .firstBook: return "Completed your first book!"
        case .streak7: return "Read for 7 days in a row!"
        case .streak30: return "Read for 30 days in a row!"
        case .streak100: return "Read for 100 days in a row!"
        case .books10: return "Completed 10 books!"
        case .books50: return "Completed 50 books!"
        case .books100: return "Completed 100 books!"
        case .perfectRater: return "Rated 10 books!"
        case .criticRater: return "Rated 50 books!"
        case .yearlyGoalMet: return "Met your yearly reading goal!"
        case .fiveStarFan: return "Gave 5 stars to 10 books!"
        case .speedReader: return "Finished a book in one day!"
        case .slowAndSteady: return "Kept a book in hangar for 30+ days!"
        }
    }
} 