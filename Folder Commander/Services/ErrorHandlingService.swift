//
//  ErrorHandlingService.swift
//  Folder Commander
//
//  Created by Thomas Weschke on 28/01/2026.
//

import Foundation
import Combine
import SwiftUI

/// Centralized error handling service for consistent error presentation and logging
class ErrorHandlingService: ObservableObject {
    static let shared = ErrorHandlingService()
    
    @Published var currentError: AppError?
    @Published var showingError = false
    
    private init() {}
    
    /// Handle an error with user-friendly presentation
    /// - Parameters:
    ///   - error: The error to handle
    ///   - context: Optional context about where the error occurred
    func handle(_ error: Error, context: String? = nil) {
        let appError = AppError(from: error, context: context)
        
        DispatchQueue.main.async {
            self.currentError = appError
            self.showingError = true
        }
        
        // Log error for debugging
        logError(appError)
    }
    
    /// Handle a specific app error
    func handle(_ appError: AppError) {
        DispatchQueue.main.async {
            self.currentError = appError
            self.showingError = true
        }
        
        logError(appError)
    }
    
    /// Clear the current error
    func clearError() {
        currentError = nil
        showingError = false
    }
    
    /// Log error for debugging (in production, this could send to crash reporting service)
    private func logError(_ error: AppError) {
        #if DEBUG
        print("❌ Error: \(error.title)")
        print("   Message: \(error.message)")
        if let context = error.context {
            print("   Context: \(context)")
        }
        if let recovery = error.recoverySuggestion {
            print("   Recovery: \(recovery)")
        }
        #endif
    }
}

/// Standardized app error structure
struct AppError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let context: String?
    let recoverySuggestion: String?
    let underlyingError: Error?
    
    init(title: String, message: String, context: String? = nil, recoverySuggestion: String? = nil, underlyingError: Error? = nil) {
        self.title = title
        self.message = message
        self.context = context
        self.recoverySuggestion = recoverySuggestion
        self.underlyingError = underlyingError
    }
    
    /// Create AppError from any Error type
    init(from error: Error, context: String? = nil) {
        self.underlyingError = error
        
        if let fileSystemError = error as? FileSystemError {
            self.title = "File System Error"
            self.message = fileSystemError.localizedDescription
            self.context = context
            
            // Provide recovery suggestions based on error type
            switch fileSystemError {
            case .invalidURL:
                self.recoverySuggestion = "Please select a valid folder location."
            case .permissionDenied:
                self.recoverySuggestion = "Grant access to the folder in System Settings > Privacy & Security > Files and Folders."
            case .fileAlreadyExists(let path):
                self.recoverySuggestion = "Choose a different name or delete the existing folder at: \(path)"
            case .creationFailed:
                self.recoverySuggestion = "Check that you have write permissions for the selected location."
            }
        } else if let localizedError = error as? LocalizedError {
            self.title = "Error"
            self.message = localizedError.localizedDescription
            self.context = context
            self.recoverySuggestion = localizedError.recoverySuggestion
        } else {
            self.title = "Error"
            self.message = error.localizedDescription
            self.context = context
            self.recoverySuggestion = "Please try again. If the problem persists, contact support."
        }
    }
}

// MARK: - View Modifier for Error Presentation

struct ErrorAlertModifier: ViewModifier {
    @ObservedObject var errorService = ErrorHandlingService.shared
    
    func body(content: Content) -> some View {
        content
            .alert(errorService.currentError?.title ?? "Error", isPresented: $errorService.showingError) {
                Button("OK", role: .cancel) {
                    errorService.clearError()
                }
                
                if let recovery = errorService.currentError?.recoverySuggestion, !recovery.isEmpty {
                    Button("Learn More") {
                        // Could open help documentation or show more details
                        errorService.clearError()
                    }
                }
            } message: {
                if let error = errorService.currentError {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(error.message)
                        
                        if let recovery = error.recoverySuggestion {
                            Text("\n\(recovery)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
    }
}

extension View {
    /// Add error alert handling to any view
    func errorAlert() -> some View {
        modifier(ErrorAlertModifier())
    }
}
