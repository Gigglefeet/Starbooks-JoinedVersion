import SwiftUI

struct StatsView: View {
    @ObservedObject var statsManager: StatsManager
    @State private var showingGoalSetter = false
    @State private var newGoal = ""
    
    var body: some View {
        NavigationView {
            List {
                // Reading Streak Section
                Section(header: Text("Reading Streak")) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(statsManager.streakDescription)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            if statsManager.stats.longestStreak > 0 {
                                Text("Longest streak: \(statsManager.stats.longestStreak) days")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                // Yearly Goal Section
                Section(header: Text("Reading Goal")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text(statsManager.yearlyGoalDescription)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                if statsManager.stats.yearlyGoal > 0 {
                                    Text("\(Int(statsManager.yearlyGoalProgress * 100))% complete")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button("Set Goal") {
                                newGoal = "\(statsManager.stats.yearlyGoal)"
                                showingGoalSetter = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        if statsManager.stats.yearlyGoal > 0 {
                            ProgressView(value: statsManager.yearlyGoalProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                
                // Rating Insights Section
                Section(header: Text("Rating Insights")) {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text(statsManager.averageRatingDescription)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("\(statsManager.stats.totalRatedBooks) books rated")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        // Rating distribution
                        if !statsManager.stats.ratingDistribution.isEmpty {
                            RatingDistributionView(distribution: statsManager.stats.ratingDistribution)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                
                // Reading Speed Section
                Section(header: Text("Reading Speed")) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(statsManager.hangarTimeDescription)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Time books spend currently reading")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                // Monthly Stats Section
                Section(header: Text("This Year")) {
                    MonthlyStatsView(monthlyData: statsManager.stats.booksCompletedByMonth)
                        .listRowBackground(Color.clear)
                }
                
                // Achievements Section
                Section(header: Text("Achievements")) {
                    if statsManager.stats.achievements.isEmpty {
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: "trophy")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("Complete your first book to earn achievements!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(Array(statsManager.stats.achievements), id: \.self) { achievementName in
                            if let achievement = ReadingAchievement.allCases.first(where: { $0.rawValue == achievementName }) {
                                AchievementRowView(achievement: achievement)
                                    .listRowBackground(Color.clear)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Reading Stats")
            .background(
                StarfieldView(starCount: 100)
                    .edgesIgnoringSafeArea(.all)
            )
            .alert("Set Reading Goal", isPresented: $showingGoalSetter) {
                TextField("Books per year", text: $newGoal)
                    .keyboardType(.numberPad)
                Button("Set Goal") {
                    if let goal = Int(newGoal), goal > 0 {
                        statsManager.setYearlyGoal(goal)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("How many books would you like to read this year?")
            }
        }
        .environment(\.colorScheme, .dark)
    }
}

struct RatingDistributionView: View {
    let distribution: [Int: Int]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { rating in
                VStack(spacing: 2) {
                    Text("\(distribution[rating, default: 0])")
                        .font(.caption2)
                        .foregroundColor(.white)
                    
                    LightsaberView(
                        isLit: true,
                        color: LightsaberView.colorForIndex(rating),
                        size: .caption
                    )
                    
                    Text("\(rating)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct MonthlyStatsView: View {
    let monthlyData: [String: Int]
    
    private var currentYearMonths: [(String, Int)] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (1...12).compactMap { month in
            let monthKey = String(format: "%d-%02d", currentYear, month)
            let count = monthlyData[monthKey, default: 0]
            return (monthKey, count)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Books completed per month")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach(Array(currentYearMonths.enumerated()), id: \.offset) { index, monthData in
                    let monthName = Calendar.current.monthSymbols[index].prefix(3)
                    
                    VStack(spacing: 2) {
                        Text("\(monthData.1)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(String(monthName))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(monthData.1 > 0 ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                    )
                }
            }
        }
    }
}

struct AchievementRowView: View {
    let achievement: ReadingAchievement
    
    var body: some View {
        HStack {
            Image(systemName: achievement.icon)
                .foregroundColor(.yellow)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(achievement.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    struct StatsPreviewWrapper: View {
        @StateObject private var statsManager = StatsManager()
        
        var body: some View {
            StatsView(statsManager: statsManager)
                .onAppear {
                    // Add some sample data for preview
                    statsManager.stats.currentStreak = 7
                    statsManager.stats.longestStreak = 15
                    statsManager.stats.yearlyGoal = 24
                    statsManager.stats.currentYearBooksRead = 8
                    statsManager.stats.totalRatedBooks = 12
                    statsManager.stats.averageRating = 4.2
                    statsManager.stats.ratingDistribution = [1: 1, 2: 2, 3: 3, 4: 4, 5: 2]
                    statsManager.stats.achievements.insert("First Book Completed")
                    statsManager.stats.achievements.insert("7-Day Reading Streak")
                }
        }
    }
    
    return StatsPreviewWrapper()
} 