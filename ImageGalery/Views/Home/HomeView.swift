//
//  HomeView.swift
//  ImageGalery
//
//  Created by Lau Sarmiento on 6/02/24.
//

import SwiftUI
import PhotosUI

struct HomeView: View {

    @ObservedObject private var viewModel = ViewModel()
    @State private var selectedPhoto: Photo?

    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                LazyVGrid(columns: [GridItem](
                    repeating: GridItem(.flexible(minimum: (geometry.size.width / 3.0) - 6.0)),
                    count: 3
                ), spacing: 2.0) {
                    ForEach(viewModel.photos) { (photo: Photo) in
                        photo.image
                            .resizable()
                            .scaledToFill()
                            .frame(width: (geometry.size.width / 3.0), height: geometry.size.width / 3.0)
                            .clipShape(Rectangle())
                            .onTapGesture {
                                selectedPhoto = photo
                            }
                            .contextMenu {
                                Button("Open detail", systemImage: "photo") {
                                    selectedPhoto = photo
                                }
                                Divider()
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    viewModel.deletePhoto(photo: photo)
                                }
                            } preview: {
                                photo.image
                                    .resizable()
                            }
                    }
                }
            }
        }
        .padding(.top, 24.0)
        .navigationTitle("Image Galery")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                PhotosPicker(selection: $viewModel.selectedItems, matching: .images) {
                    Image(systemName: "plus.circle")
                }
            }
        }
        .sheet(item: $selectedPhoto) { (selectedPhoto: Photo) in
            ImagePreviewView(photo: $selectedPhoto)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
