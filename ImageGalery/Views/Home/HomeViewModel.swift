//
//  HomeViewModel.swift
//  ImageGalery
//
//  Created by Lau Sarmiento on 6/02/24.
//

import UIKit
import SwiftUI
import Photos
import PhotosUI
import CoreTransferable
import Combine

extension HomeView {

    final class ViewModel: ObservableObject {

        private let localStorage: LocalStorage
        private var anyCancellables: Set<AnyCancellable> = []
        @Published private(set) var photos: [Photo] = []
        @Published var selectedItems: [PhotosPickerItem] = []

        init(localStorage: LocalStorage = LocalStorageImpl()) {
            self.localStorage = localStorage
            Task {
                do {
                    photos = try await localStorage.loadPhotos()
                } catch let error {
                    debugPrint("Error loading photos: \(error.localizedDescription)")
                }
            }
            $selectedItems
                .sink { [weak self] (items: [PhotosPickerItem]) in
                    Task { [weak self] in
                        await self?.trasnferToImage(items: items)
                    }
                }
                .store(in: &anyCancellables)
        }

        private func trasnferToImage(items: [PhotosPickerItem]) async {
            for item in items {
                do {
                    guard let data = try await item.loadTransferable(type: Data.self) else {
                        debugPrint("Receive nil from transferible")
                        return
                    }
                    let photo = Photo(data: data)
                    DispatchQueue.main.async {
                        self.photos.append(photo)
                    }
                    try await self.localStorage.savePhoto(photo: photo)
                } catch let failure {
                    debugPrint("Receive failure from transferible \(failure.localizedDescription)")
                }
            }
        }

        func deletePhoto(photo: Photo) {
                photos.removeAll { $0 == photo }
                Task {
                    do {
                        try await localStorage.deletePhoto(photo: photo)
                    } catch let error {
                        debugPrint("Error deleting photo: \(error.localizedDescription)")
                    }
                }
        }
    }
}

enum TransferableError: Error {
    case unableToEncode
    case unableToDecode
}
