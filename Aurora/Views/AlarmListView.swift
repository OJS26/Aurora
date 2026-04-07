import SwiftUI
import SwiftData

struct AlarmListView: View {
    @Query var alarms: [Alarm]
    @Environment(\.modelContext) var modelContext
    @State private var showingAddAlarm = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    if alarms.isEmpty {
                        VStack(spacing: 12) {
                            Text("🌅")
                                .font(.system(size: 60))
                            Text("No alarms set")
                                .foregroundStyle(.white)
                                .font(.title3)
                            Text("Add one to get started")
                                .foregroundStyle(.gray)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(alarms) { alarm in
                                AlarmRowView(alarm: alarm)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparatorTint(Color.gray.opacity(0.3))
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
            .toolbarColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddAlarm = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.orange)
                    }
                }
            }
            .sheet(isPresented: $showingAddAlarm) {
                AddAlarmView()
            }
        }
    }
    
    func deleteAlarms(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(alarms[index])
        }
    }
}
