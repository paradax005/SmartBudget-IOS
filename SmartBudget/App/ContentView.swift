import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            authViewModel.checkAuthStatus()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Overview", systemImage: "house.fill")
                }
            
            TransactionsListView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }
            
            BudgetsListView()
                .tabItem {
                    Label("Budgets", systemImage: "chart.pie.fill")
                }
            
            AccountsListView()
                .tabItem {
                    Label("Accounts", systemImage: "creditcard.fill")
                }
            
            CategoriesListView()
                .tabItem {
                    Label("Categories", systemImage: "folder.fill")
                }
                
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.xaxis")
                }
        }
        .accentColor(.purplePrimary)
    }
}
