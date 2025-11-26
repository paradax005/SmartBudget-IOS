import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    TextField("Full Name", text: $fullName)
                        .padding()
                        .background(Color.surfaceDark)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    
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
                    
                    SecureField("Confirm Password", text: $confirmPassword)
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
                    if password == confirmPassword {
                        Task {
                            await viewModel.register(fullName: fullName, email: email, password: password)
                        }
                    } else {
                        viewModel.errorMessage = "Passwords do not match"
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Register")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.purplePrimary)
                .foregroundColor(.white)
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.errorMessage = nil
        }
    }
}
