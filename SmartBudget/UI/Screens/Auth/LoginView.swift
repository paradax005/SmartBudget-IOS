import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundDark.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Logo/Branding
                    Image(systemName: "wallet.pass.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.purplePrimary)
                    
                    Text("SmartBudget")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Welcome Back")
                        .font(.title3)
                        .foregroundColor(.textSecondary)
                    
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.surfaceDark)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.surfaceDark)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.errorRed)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.login(email: email, password: password)
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.purplePrimary)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    NavigationLink(destination: RegisterView(), isActive: $showRegister) {
                        Button("Don't have an account? Register") {
                            showRegister = true
                        }
                        .foregroundColor(.purpleLight)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.errorMessage = nil
            }
        }
    }
}
