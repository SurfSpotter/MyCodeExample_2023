//
//  MainScreenCoordinator.swift
//  MyCodeExample_2023
//
//  Created by Алексей Чигарских on 05.07.2023.
//

import Foundation
import SwiftUI
import Stinsen
import Container


//MARK: This is main screen coordinator example
final class MainScreenCoordinator: NavigationCoordinatable {
    var stack: STNavigationStack<MainScreenCoordinator> = .init(initial: \.root)
    
    @Root var root = rootScreen
    @Route(.modal) var chooseImage = chooseImageScreen
    @Route(.modal) var share = shareScreen
    @Route(.fullScreen) var paywall = paywallScreen
    
    // MARK: - Dependencies
    @Dependency(.providers) var provider: MainScreenProviderProtocol

    init() {
    }
}

extension MainScreenCoordinator {
    func rootScreen() -> some View {
        MainScreen(viewModel: mainScreenViewModel)
    }
    
    func chooseImageScreen() -> some View {
        ChooseImageScreen(viewModel: PhotoLibViewModel(onTapChoosen: { _ in
        }))
        
        
    }
    
    func paywallScreen(touchPoint: PaywallTouchPoint) -> some View {
        NewOnboardingPaywallScreen(viewModel: NewOnboardingPaywallViewModel(completion: {_success in
            if _success {
                
            } else {
                
            }
                self.popToRoot()
        }, paywallType: rootCoordinator.paywallType, xcrossType: rootCoordinator.paywallXCrossType, touchPoint: touchPoint))
    }
    
    func shareScreen(data: Data) -> some View {
        let image = UIImage(data: data)!
        return ActivityViewController(activityItems: [image]) {}
    }

}
