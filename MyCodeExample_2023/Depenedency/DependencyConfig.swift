//
//  DependencyConfig.swift
//  MyCodeExample_2023
//
//  Created by Алексей Чигарских on 05.07.2023.
//

import Foundation
import Container

//MARK: This is my example of dependecy config
extension Container {
    static let services = Container(DependenciesConfigurator.services)
    static let providers = Container(DependenciesConfigurator.providers)
}

struct DependenciesConfigurator {
    static var services: DependencyResolver {
        let container = DependencyContainer()
        
        container.apply(FileService() as FileServiceProtocol)
        return container
    }
    
    static var providers: DependencyResolver {
        let container = DependencyContainer()
        container.apply(PaywallProvider() as PaywallProviderProtocol)
        container.apply(PhotoLibraryProvider() as PhotoLibraryProviderProtocol)
        container.apply(CustomImagesProvider() as CustomImagesProviderProtocol)
        container.apply(MainScreenProvider() as MainScreenProviderProtocol)
        
        
        return container
    }
}
