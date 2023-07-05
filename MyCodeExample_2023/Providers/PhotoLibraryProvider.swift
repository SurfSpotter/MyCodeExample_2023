//
//  PhotoLibraryProvider.swift
//  MyCodeExample_2023
//
//  Created by Алексей Чигарских on 05.07.2023.
//

//MARK: This is example of provider
import Photos
import Combine
import SwiftUI

protocol PhotoLibraryProviderProtocol {
    func getPHAssets() -> AnyPublisher<[PHAsset], Error>
    func loadImage(asset: PHAsset) -> AnyPublisher<UIImage?, Never>
    func loadImage(asset: [PHAsset]) -> AnyPublisher<[UIImage], Never>
}

final class PhotoLibraryProvider: PhotoLibraryProviderProtocol {
    
    func getPHAssets() -> AnyPublisher<[PHAsset], Error> {
        let options = PHFetchOptions()
           options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
           options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
           let fetchResult = PHAsset.fetchAssets(with: options)
           
           return Publishers.Sequence(sequence: fetchResult.objects(at: IndexSet(0..<fetchResult.count)))
               .mapError { $0 as Error }
               .collect()
               .eraseToAnyPublisher()
    }

    func loadImage(asset: PHAsset) -> AnyPublisher<UIImage?, Never> {
        return Future<UIImage?, Never> { promise in
            let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { image, info in
                promise(.success(image))
            }
        }.eraseToAnyPublisher()
    }
    
    func loadImage(asset: [PHAsset]) -> AnyPublisher<[UIImage], Never> {
        return Future<[UIImage], Never> { promise in
            let imageManager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            
            var images = [UIImage]()
            
            for i in 0..<asset.count {
                imageManager.requestImage(for: asset[i], targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { (image, _) in
                    if let image = image {
                        images.append(image)
                    }
                    
                    if i == asset.count - 1 {
                        promise(.success(images))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
