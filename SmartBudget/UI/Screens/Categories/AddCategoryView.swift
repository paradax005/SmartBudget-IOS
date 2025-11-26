import SwiftUI

struct AddCategoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CategoriesViewModel
    
    @State private var name = ""
    @State private var type = "expense"
    @State private var selectedIcon = "📁"
    @State private var selectedColor = "#6366F1"
    
    let icons = ["📁", "🍔", "🚗", "🏠", "💰", "🎮", "📱", "✈️", "🏥", "🎓", "🛒", "💳", "🎬", "☕️", "👕", "⚡️"]
    let colors = ["#6366F1", "#EF4444", "#10B981", "#F59E0B", "#8B5CF6", "#EC4899", "#14B8A6", "#F97316"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Type Toggle
                        HStack(spacing: 0) {
                            Button(action: { type = "expense" }) {
                                Text("Expense")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(type == "expense" ? Color.errorRed : Color.clear)
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: { type = "income" }) {
                                Text("Income")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(type == "income" ? Color.successGreen : Color.clear)
                                    .foregroundColor(.white)
                            }
                        }
                        .background(Color.surfaceDark)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Form Fields
                        VStack(spacing: 16) {
                            // Category Name
                            TextField("Category Name", text: $name)
                                .padding()
                                .background(Color.surfaceDark)
                                .cornerRadius(12)
                                .foregroundColor(.white)
                            
                            // Icon Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Select Icon")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                                    ForEach(icons, id: \.self) { icon in
                                        Button(action: { selectedIcon = icon }) {
                                            Text(icon)
                                                .font(.system(size: 32))
                                                .frame(width: 50, height: 50)
                                                .background(selectedIcon == icon ? Color.purplePrimary.opacity(0.3) : Color.surfaceDark)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            
                            // Color Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Select Color")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                                    ForEach(colors, id: \.self) { color in
                                        Button(action: { selectedColor = color }) {
                                            Circle()
                                                .fill(Color(hex: color))
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.errorRed)
                                .font(.caption)
                        }
                        
                        Button(action: {
                            Task {
                                let success = await viewModel.createCategory(
                                    name: name,
                                    type: type,
                                    icon: selectedIcon,
                                    color: selectedColor
                                )
                                if success {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Category")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(Color.purplePrimary)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

// Extension to support hex color strings
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
