//
//  MainScreenViewModel.swift
//  MyCodeExample_2023
//
//  Created by Алексей Чигарских on 05.07.2023.
//


import Combine
import Stinsen
import SwiftUI
import Container


//MARK: This is code example of MainScreen
class MainScreenViewModel : ObservableObject {
    
    @Published var showResolutionView: Void?
    @Published var onTapSaveNewResolution: CGSize?
    @Published var presentResolutionView: Bool = false
    @Published var onTapCompress: Void?
    @Published var presentCompressView: Bool = false
    @Published var imageQuality : Double = 1.0
    @Published var onTapExtendedCropFactors: Void?
    @Published var presentExtendedCropFactors = false
    @Published var onTapChoosePhoto: Void?
    @Published var showLoading: Bool = false
    @Published var originalChoosenImage: UIImage?
    @Published var choosenImage: UIImage?
    @Published var recalculateClipSize: Bool = false
    @Published var newImageResolution: CGSize?
    @Published var angle : Angle = Angle(degrees: 0)
    @Published var onTapChageCropFactor : CropFactorProtocol?
    @Published var cropFactor_extended : CropFactorProtocol = StandartCropFactors.original {
        didSet {
            Metrica.reportJustOneTime(originalChoosenImage.hashValue, event: .photo_crop)
            onTapChageCropFactor = cropFactor_extended
        }
    }
    @Published var fileSize : Double = 2
    @Published var cropFactor_standart: StandartCropFactors = .original //кроп фактор для стандратного View
    @Published var selectedCropCategory : CropCategory = .standart
    @Published var onTapResetImageSettings: Bool = false
    @Published var onTapAdjustImageByFrame: Bool = false
    @Published var customFrameSize: CGSize?
    
    
    
    // MARK: - Dependencies
    @Dependency(.providers) var provider: MainScreenProviderProtocol
    private var cancelable = Set<AnyCancellable>()
    @RouterObject var router: MainScreenCoordinator.Router?
    
    init() {
        setupBindings()
    }
    
    func setupBindings() {
        $onTapChoosePhoto
            .compactMap { $0 }
            .sink { [weak self] in
                self!.router?.route(to: \.chooseImage)
            }
            .store(in: &cancelable)
        
        
        $showResolutionView
            .compactMap { $0 }
            .flatMap { [unowned self] data in
                provider
                    .subscriptionStatus()
                    .map {
                        ($0, data)
                    }
            }
            .sink { [unowned self] info in
                presentResolutionView.toggle()
            }
            .store(in: &cancelable)
        
        $onTapSaveNewResolution
            .compactMap { $0 }
            .flatMap { [unowned self] data in
                provider
                    .subscriptionStatus()
                    .map {
                        ($0, data)
                    }
            }
            .sink { [unowned self] info in
                Metrica.reportJustOneTime(originalChoosenImage.hashValue, event: .photo_change_size)
                let subscriptionStatus = info.0
                if subscriptionStatus == true {
                    //go to change resolution
                    newImageResolution = info.1
                    presentResolutionView.toggle()
                } else {
                    presentResolutionView.toggle()
                    router?.route(to: \.paywall, .resolution)
                }
                
                showLoading = false
            }
            .store(in: &cancelable)
        
        $onTapCompress
            .compactMap{$0}
            .sink { [unowned self] info in
                presentCompressView = true
            }
            .store(in: &cancelable)
        
        
        $onTapExtendedCropFactors
            .compactMap{$0}
            .sink { [unowned self] info in
                presentExtendedCropFactors.toggle()
            }
            .store(in: &cancelable)
        $onTapChageCropFactor
            .compactMap{$0}
            .flatMap { [unowned self] data in
                provider
                    .subscriptionStatus()
                    .map {
                        ($0, data)
                    }
            }
            .sink { [unowned self] info in
                
                let subscriptionStatus = info.0
                if let standartCropFactors = info.1 as? StandartCropFactors {
                    recalculateClipSize.toggle()
                    
                } else {
                    Metrica.reportJustOneTime(originalChoosenImage.hashValue, event: .photo_change_size_preset)
                    //premium feature
                    if subscriptionStatus == true {
                        
                        recalculateClipSize.toggle()
                    } else {
                        router?.route(to: \.paywall, .crop)
                    }
                    showLoading = false
                }
                
            }
            .store(in: &cancelable)
        
        
        
        $imageQuality
            .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else {return}
                calculateImageFileSize()
            }
            .store(in: &cancelable)
        
        $imageQuality
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .compactMap{$0}
            .flatMap { [unowned self] data in
                provider
                    .subscriptionStatus()
                    .map {
                        ($0, data)
                    }
            }
            .sink { [weak self] info in
                
                let subscriptionStatus = info.0
                guard let self = self else {return}
                
                guard info.1 != 1.0 else {return}
                
                if subscriptionStatus == true {
                    Metrica.reportJustOneTime(self.originalChoosenImage.hashValue, event: .photo_compress)
                } else {
                    Metrica.reportJustOneTime(self.originalChoosenImage.hashValue, event: .photo_compress)
                    self.imageQuality = 1.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.router?.route(to: \.paywall, .compress)
                    }
                }
            }
            .store(in: &cancelable)
    }
    
    func getImageSize() {
        if let choosenImage = choosenImage {
        }
    }
    
    func closeCurrentImage() {
        self.onTapResetImageSettings.toggle()
        mainScreenViewModel.choosenImage = nil
    }
    
    func calculateImageFileSize() {
        if let imageData = choosenImage?.jpegData(compressionQuality: imageQuality) {
            let imageSizeKB = Double(imageData.count) / 1024
            let round = imageSizeKB.rounded()
            fileSize = round
        }
    }
    
    
}
