import Foundation
import Combine

class StatsManager: ObservableObject {
    @Published var stats = ReadingStats()
    @Published var newAchievements: [ReadingAchievement] = []
    
    private let statsKey = "readingStats"
    
    init() {
        loadStats()
    }
    
    // MARK: - Persistence
    func saveStats() {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(stats)
            UserDefaults.standard.set(encoded, forKey: statsKey)
        } catch {
            print("Failed to save stats: \(error)")
        }
    }
    
    func loadStats() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: statsKey) {
            do {
                stats = try decoder.decode(ReadingStats.self, from: data)
            } catch {
                print("Failed to load stats: \(error)")
                stats = ReadingStats()
            }
        }
    }
    
    // MARK: - Stats Updates
    
    func bookMovedToHangar(_ book: Book) {
        stats.hangarEntryDates[book.id.uuidString] = Date()
        stats.totalBooksMovedToHangar += 1
        saveStats()
    }
    
    func bookCompletedFromHangar(_ book: Book) {
        // Update completion stats
        let currentYear = stats.currentYear
        let currentMonth = stats.currentMonth
        
        stats.booksCompletedByYear[currentYear, default: 0] += 1
        stats.booksCompletedByMonth[currentMonth, default: 0] += 1
        stats.currentYearBooksRead = stats.booksCompletedByYear[currentYear] ?? 0
        
        // Update reading streak
        updateReadingStreak()
        
        // Update hangar time tracking
        stats.updateAverageDaysInHangar(completedBookId: book.id.uuidString)
        
        // Check for achievements
        checkForNewAchievements()
        
        saveStats()
    }
    
    func bookRated(_ book: Book, rating: Int) {
        // Remove old rating if it existed
        if book.rating > 0 {
            stats.ratingDistribution[book.rating, default: 0] -= 1
            if stats.ratingDistribution[book.rating] == 0 {
                stats.ratingDistribution.removeValue(forKey: book.rating)
            }
        } else {
            stats.totalRatedBooks += 1
        }
        
        // Add new rating
        stats.ratingDistribution[rating, default: 0] += 1
        
        // Recalculate average rating
        updateAverageRating()
        
        // Check for achievements
        checkForNewAchievements()
        
        saveStats()
    }
    
    func setYearlyGoal(_ goal: Int) {
        stats.yearlyGoal = goal
        checkForNewAchievements()
        saveStats()
    }
    
    private func updateReadingStreak() {
        let today = Date()
        
        if stats.shouldContinueStreak() {
            // Don't increment if we already read today
            if let lastDate = stats.lastReadingDate,
               !Calendar.current.isDate(lastDate, inSameDayAs: today) {
                stats.currentStreak += 1
            }
        } else {
            // Reset streak
            stats.currentStreak = 1
        }
        
        stats.lastReadingDate = today
        stats.longestStreak = max(stats.longestStreak, stats.currentStreak)
    }
    
    private func updateAverageRating() {
        let totalRatings = stats.ratingDistribution.values.reduce(0, +)
        let totalPoints = stats.ratingDistribution.reduce(0) { total, entry in
            total + (entry.key * entry.value)
        }
        
        stats.averageRating = totalRatings > 0 ? Double(totalPoints) / Double(totalRatings) : 0.0
    }
    
    // MARK: - Achievement Checking
    private func checkForNewAchievements() {
        var newlyEarned: [ReadingAchievement] = []
        
        // Check each achievement
        for achievement in ReadingAchievement.allCases {
            if !stats.achievements.contains(achievement.rawValue) && isAchievementEarned(achievement) {
                stats.achievements.insert(achievement.rawValue)
                newlyEarned.append(achievement)
            }
        }
        
        if !newlyEarned.isEmpty {
            newAchievements.append(contentsOf: newlyEarned)
        }
    }
    
    private func isAchievementEarned(_ achievement: ReadingAchievement) -> Bool {
        switch achievement {
        case .firstBook:
            return stats.currentYearBooksRead >= 1 || stats.booksCompletedByYear.values.reduce(0, +) >= 1
        case .streak7:
            return stats.currentStreak >= 7
        case .streak30:
            return stats.currentStreak >= 30
        case .streak100:
            return stats.currentStreak >= 100
        case .books10:
            return stats.booksCompletedByYear.values.reduce(0, +) >= 10
        case .books50:
            return stats.booksCompletedByYear.values.reduce(0, +) >= 50
        case .books100:
            return stats.booksCompletedByYear.values.reduce(0, +) >= 100
        case .perfectRater:
            return stats.totalRatedBooks >= 10
        case .criticRater:
            return stats.totalRatedBooks >= 50
        case .yearlyGoalMet:
            return stats.yearlyGoal > 0 && stats.currentYearBooksRead >= stats.yearlyGoal
        case .fiveStarFan:
            return stats.ratingDistribution[5, default: 0] >= 10
        case .speedReader:
            // This would need additional tracking for completion time
            return false // Placeholder
        case .slowAndSteady:
            // Check if any book has been in hangar for 30+ days
            return stats.hangarEntryDates.values.contains { entryDate in
                let daysInHangar = Calendar.current.dateComponents([.day], from: entryDate, to: Date()).day ?? 0
                return daysInHangar >= 30
            }
        }
    }
    
    // MARK: - Computed Stats for UI
    var streakDescription: String {
        if stats.currentStreak == 0 {
            return "Start your reading streak!"
        } else if stats.currentStreak == 1 {
            return "🔥 1 day streak"
        } else {
            return "🔥 \(stats.currentStreak) day streak"
        }
    }
    
    var yearlyGoalProgress: Double {
        guard stats.yearlyGoal > 0 else { return 0.0 }
        return Double(stats.currentYearBooksRead) / Double(stats.yearlyGoal)
    }
    
    var yearlyGoalDescription: String {
        if stats.yearlyGoal == 0 {
            return "Set a yearly goal"
        } else {
            return "\(stats.currentYearBooksRead)/\(stats.yearlyGoal) books this year"
        }
    }
    
    var averageRatingDescription: String {
        if stats.averageRating == 0 {
            return "Start rating books"
        } else {
            return String(format: "%.1f ⭐ average", stats.averageRating)
        }
    }
    
    var hangarTimeDescription: String {
        if stats.averageDaysInHangar == 0 {
            return "No completed books yet"
        } else {
            return String(format: "%.1f days average reading time", stats.averageDaysInHangar)
        }
    }
    
    // Clear new achievements after they've been shown
    func clearNewAchievements() {
        newAchievements.removeAll()
    }
} 