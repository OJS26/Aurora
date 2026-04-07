import SwiftUI
import SwiftData

struct AlarmListView: View {
    @Query var alarms: [Alarm]
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var alarmManager: AlarmManager
    @State private var showingAddAlarm = false
    @State private var stars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = []
    
    let amber = Color(red: 1.0, green: 0.75, blue: 0.3)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Deep space background
                Color(red: 0.04, green: 0.04, blue: 0.08)
                    .ignoresSafeArea()
                
                // Stars
                GeometryReader { geo in
                    ForEach(0..<stars.count, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(stars[i].opacity))
                            .frame(width: stars[i].size, height: stars[i].size)
                            .position(
                                x: stars[i].x * geo.size.width,
                                y: stars[i].y * geo.size.height
                            )
                    }
                }
                .ignoresSafeArea()
                
                VStack {
                    if alarms.isEmpty {
                        VStack(spacing: 16) {
                            Text("🌅")
                                .font(.system(size: 70))
                            Text("No alarms set")
                                .foregroundStyle(.white)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Tap + to set your first wake-up")
                                .foregroundStyle(Color(white: 0.5))
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(alarms) { alarm in
                                AlarmRowView(alarm: alarm)
                                    .listRowBackground(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(white: 0.1))
                                            .padding(.vertical, 4)
                                    )
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            }
                            .onDelete(perform: deleteAlarms)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Aurora")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddAlarm = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(amber)
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingAddAlarm) {
                AddAlarmView()
            }
            .onAppear {
                generateStars()
            }
        }
    }
    
    func generateStars() {
        stars = (0..<80).map { _ in
            (
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...2.5),
                opacity: Double.random(in: 0.2...0.7)
            )
        }
    }
    
    func deleteAlarms(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(alarms[index])
        }
    }
}
