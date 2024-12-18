import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var selectedDate = Date()
    @State var selectedTab = 0
    @State private var isAddTaskModalPresented = false // State to track modal visibility
    @State private var showingAlert = false
    
    
    var body: some View {
        ZStack {
            // Main TabView
            TabView(selection: $selectedTab) {
                TaskListView(viewModel: viewModel, selectedDate: selectedDate, title: "Today")
                    .background(Color(.systemGroupedBackground))
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .tabItem {
                        Image(systemName: "pencil")
                        Text("Today")
                    }
                    .tag(0)
                
                CalendarListView(viewModel: viewModel)
                    .background(Color(.systemGroupedBackground))
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Calendar")
                    }
                    .tag(1)
                TaskListView(viewModel: viewModel, selectedDate: nil, title: "To Do")
                    .background(Color(.systemGroupedBackground))
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .tabItem {
                        Image(systemName: "pencil")
                        Text("To Do")
                    }
                    .tag(2)
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
                            .frame(width: 45, height: 45)
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
            AddTaskModalView(viewModel: viewModel)
                .presentationDetents([.fraction(0.1)])
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: viewModel.errorMessage) { oldValue, newValue in
            if newValue != nil {
                showingAlert = true
            }
        }
    }
}
