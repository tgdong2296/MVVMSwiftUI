//
//  AppViewModel.swift
//  MVVMSwiftUI
//
//  Created by Giang Dong Trinh on 23/6/26.
//

import Foundation
import FamilyControls
import FactoryKit

@Observable
@MainActor
final class AppViewModel {
    
    @Injected(\.appStateStore)
    @ObservationIgnored var appStateStore
    
    @Injected(\.appConfigUseCase)
    @ObservationIgnored var appConfigUseCase

    var appFlow: AppFlow {
        appStateStore.appFlow
    }
    
    var viewState: ViewState {
        return combine([loadappFlowState])
    }
    
    var loadappFlowState: ViewState = .indie

    func loadAppFlow() async {
        loadappFlowState = .loading
        do {
            let flow = try await appConfigUseCase.getAppFlow()
            appStateStore.update(flow)
            loadappFlowState = .success
        } catch {
            loadappFlowState = .error([error.localizedDescription])
        }
    }

    func loadData() async {
        // Load other data when app start at background
    }
}

// MARK: - Factory Registration
extension Container {
    var appViewModel: Factory<AppViewModel> {
        Factory(self) {
            MainActor.assumeIsolated {
                return AppViewModel()
            }
        }
    }
}
