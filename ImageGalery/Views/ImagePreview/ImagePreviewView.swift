//
//  ImagePreviewView.swift
//  ImageGalery
//
//  Created by Lau Sarmiento on 6/02/24.
//

import SwiftUI
import MapKit

struct ImagePreviewView: View {

    @Binding var photo: Photo?
    @ObservedObject private var viewModel = ViewModel()
    @State private var scale: CGFloat = 1.0
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            VStack {
                GeometryReader { geometry in
                    photo?.image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaledToFit()
                        .clipShape(Rectangle())
                        .modifier(ImagePreviewModifier(contentSize: geometry.size))
                }
                Spacer()
                List {
                    Section(header: Text("Information")) {
                        if let creationDate = photo?.creationDate {
                            HStack {
                                Text("Date")
                                    .font(.system(size: 14.0))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(creationDate)
                                    .font(.system(size: 14.0))
                                    .foregroundStyle(.primary)
                            }
                        }
                        if let size = photo?.dimemsions {
                            HStack {
                                Text("Dimensions")
                                    .font(.system(size: 14.0))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(String(format: "%.0f", size.width)) x \(String(format: "%.0f", size.height))")
                                    .font(.system(size: 14.0))
                                    .foregroundStyle(.primary)
                            }
                        }
                        if let size = photo?.size {
                            HStack {
                                Text("Size")
                                    .font(.system(size: 14.0))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(String(format: "%.0f", size)) MB")
                                    .font(.system(size: 14.0))
                                    .foregroundStyle(.primary)
                            }
                        }
                        if let location = photo?.location {
                            Map(position: $position, interactionModes: []) {
                                Marker("Photo", coordinate: CLLocationCoordinate2D(
                                    latitude: location.latitude,
                                    longitude: location.longitude
                                ))
                            }
                            .frame(minHeight: 140.0)
                        }
                    }
                }
                .scrollDisabled(true)
            }
            .onAppear {
                position = .region(.init(
                    center: CLLocationCoordinate2D(
                        latitude: photo?.location?.latitude ?? 0.0,
                        longitude: photo?.location?.longitude ?? 0.0
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        photo = nil
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .navigationTitle("Image Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ImagePreviewView(photo: .constant(Photo(data: Data())))
}
