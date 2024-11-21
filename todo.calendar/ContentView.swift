import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var selectedDate = Date()
    @State var selectedTab = 0
    @State private var isAddTaskModalPresented = false // State to track modal visibility

    var body: some View {
        ZStack {
            // Main TabView
            TabView(selection: $selectedTab) {
                TaskListView(viewModel: viewModel, selectedDate: selectedDate)
                    .background(Color(.systemGroupedBackground))
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .tabItem {
                        Image(systemName: "pencil")
                        Text("Today")
                    }
                    .tag(0)
                    .onAppear {
                        viewModel.fetchTasks()
                    }

                CalendarListView(viewModel: viewModel)
                    .background(Color(.systemGroupedBackground))
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Calendar")
                    }
                    .tag(1)
                    .onAppear {
                        viewModel.fetchTasks()
                    }
            }

            // Floating Add Task Button
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    Button(action: {
                        isAddTaskModalPresented = true // Show modal
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.blue))
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 85)
                }
            }
        }
        .sheet(isPresented: $isAddTaskModalPresented) {
            AddTaskModalView(viewModel: viewModel, selectedDate: $selectedDate)
        }
    }
}
