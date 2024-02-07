//
//  LocalStorage.swift
//  ImageGalery
//
//  Created by Lau Sarmiento on 7/02/24.
//

import UIKit

protocol LocalStorage {
    
    func loadPhotos() async throws -> [Photo]
    func savePhoto(photo: Photo) async throws
    func deletePhoto(photo: Photo) async throws
}

final actor LocalStorageImpl: LocalStorage {

    func loadPhotos() async throws -> [Photo] {
        var loadedImages: [Photo] = []
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if let savedImageFileNames = UserDefaults.standard.object(forKey: "savedImageFileNames") as? [String] {
            for fileName in savedImageFileNames {
                let fileURL = documentsDirectory.appendingPathComponent(fileName)
                let data = try Data(contentsOf: fileURL)
                // extract the id from the file name
                guard let id = TimeInterval(fileName.components(separatedBy: "_")
                    .last?.replacingOccurrences(of: ".png", with: "") ?? "") else { continue }
                loadedImages.append(Photo(id: id, data: data))
            }
        }
        print("savedImageFileNames: \(loadedImages)")
        return loadedImages
    }

    func savePhoto(photo: Photo) async throws {
        var savedImageFileNames = UserDefaults.standard.object(forKey: "savedImageFileNames") as? [String] ?? []
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "image_\(photo.id).png"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        try photo.data.write(to: fileURL)
        savedImageFileNames.append(fileName)
        UserDefaults.standard.set(savedImageFileNames, forKey: "savedImageFileNames")

        print("savedImageFileNames: \(savedImageFileNames) after save photo \(photo.id)")
    }

    func deletePhoto(photo: Photo) async throws {
        var savedImageFileNames = UserDefaults.standard.object(forKey: "savedImageFileNames") as? [String] ?? []
        guard let index = savedImageFileNames.firstIndex(where: { $0 == "image_\(photo.id).png" }) else {
            throw NSError(domain: "Image not found", code: 404, userInfo: nil)
        }
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "image_\(photo.id).png"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        try FileManager.default.removeItem(at: fileURL)
        savedImageFileNames.remove(at: index)
        UserDefaults.standard.set(savedImageFileNames, forKey: "savedImageFileNames")
        print("savedImageFileNames: \(savedImageFileNames) after delete photo \(photo.id)")
    }
}
