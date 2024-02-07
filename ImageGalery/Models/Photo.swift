//
//  Photo.swift
//  ImageGalery
//
//  Created by Lau Sarmiento on 6/02/24.
//

import UIKit
import SwiftUI

struct Photo: Identifiable, Hashable {

    let id: TimeInterval
    let data: Data
    var image: Image {
        Image(uiImage: uiimage)
    }
    var uiimage: UIImage {
        UIImage(data: data) ?? UIImage()
    }
    private var date: Date?
    private(set) var location: (latitude: Double, longitude: Double)?
    private(set) var dimemsions: CGSize?
    private(set) var size: Double?

    var creationDate: String? {
        guard let date = date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE・MMM dd, yyyy・HH:mm"
        return formatter.string(from: date)
    }

    init(id: TimeInterval = Date().timeIntervalSince1970, data: Data) {
        self.id = id
        self.data = data
        extractMetadata(from: data)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    private mutating func extractMetadata(from data: Data) {
        // Crear un CGImageSource a partir de los datos de la imagen.
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return }

        // Obtener el diccionario de propiedades del primer índice de la imagen.
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else { return }

        // Acceder a la metadata EXIF y GPS desde el diccionario de propiedades.
        if let exifDictionary = imageProperties[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            if let dateTimeOriginal = exifDictionary[kCGImagePropertyExifDateTimeOriginal as String] as? String {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                date = formatter.date(from: dateTimeOriginal)
                print("Fecha en que fue tomada: \(dateTimeOriginal)")
            }
        }

        if let gpsDictionary = imageProperties[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            if let latitude = gpsDictionary[kCGImagePropertyGPSLatitude as String] as? Double,
               let longitude = gpsDictionary[kCGImagePropertyGPSLongitude as String] as? Double {
                print("Latitud: \(latitude), Longitud: \(longitude)")
                location = (latitude, longitude)
            }
        }

        // Acceder a la información del dispositivo no es directamente disponible a través de EXIF en todas las imágenes.
        // El tamaño de la imagen se puede obtener directamente de la imagen.
        if let pixelHeight = imageProperties[kCGImagePropertyPixelHeight as String] as? CGFloat,
           let pixelWidth = imageProperties[kCGImagePropertyPixelWidth as String] as? CGFloat {
            dimemsions = CGSize(width: pixelWidth, height: pixelHeight)
            print("Tamaño: \(pixelWidth) x \(pixelHeight)")
        }

        if let image = UIImage(data: data), let imageData = image.jpegData(compressionQuality: 1.0) {
            let imageSizeMB = Double(imageData.count) / (1024.0 * 1024.0) // Convertir de bytes a MB
            size = imageSizeMB
            print("Tamaño: \(imageSizeMB) MB")
        }
    }

    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }
}
