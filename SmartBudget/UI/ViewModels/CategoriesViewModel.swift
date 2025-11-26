import SwiftUI

@MainActor
class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIService.shared.getCategories()
            categories = response.data
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Failed to load categories"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createCategory(name: String, type: String, icon: String, color: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = CreateCategoryRequest(
                name: name,
                type: type,
                icon: icon,
                color: color
            )
            _ = try await APIService.shared.createCategory(request: request)
            // Reload categories list
            await loadCategories()
            isLoading = false
            return true
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Failed to create category"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        return false
    }
    
    func deleteCategory(id: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await APIService.shared.deleteCategory(id: id)
            // Reload categories list
            await loadCategories()
            isLoading = false
            return true
        } catch let error as APIError {
            switch error {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Failed to delete category"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
        return false
    }
}
