//
//  PreviewViewModel.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import AVFoundation
import Combine

protocol PreviewViewModelProtocol {

    var composition: AnyPublisher<Composition?, Never> { get }
    var filters: AnyPublisher<[EditorCollectionCellViewModel], Never> { get }
    var selectionCallbak: SelectionCallback { get }
    var error: AnyPublisher<String?, Never> { get }
}

final class PreviewViewModel: PreviewViewModelProtocol {

    private let urls: [URL]

    lazy var filters: AnyPublisher<[EditorCollectionCellViewModel], Never> = mutableFilters.eraseToAnyPublisher()
    private var mutableFilters = CurrentValueSubject<[EditorCollectionCellViewModel], Never>([])

    lazy var composition = mutableComposition.eraseToAnyPublisher()
    private var mutableComposition = CurrentValueSubject<Composition?, Never>(nil)

    lazy var error = mutableError.eraseToAnyPublisher()
    private var mutableError = CurrentValueSubject<String?, Never>(nil)

    private var filterProvider: FilterProviderProtocol
    private let videoEditor: VideoEditorProtocol
    private var bindings = Set<AnyCancellable>()

    lazy var selectionCallbak: SelectionCallback = { [weak self] index in
        guard let strongSelf = self, strongSelf.filterProvider.filters.indices.contains(index) else { return }

        strongSelf.filterProvider.selectedFilter = strongSelf.filterProvider.filters[index]
    }

    init(urls: [URL] = TestVideoMock.defaultUrls,
         filterProvider: FilterProviderProtocol = FilterProvider.shared,
         videoEditor: VideoEditorProtocol = VideoEditor()
         ) {
        self.urls = urls
        self.filterProvider = filterProvider
        self.videoEditor = videoEditor

        self.filterProvider.selectedFilter = filterProvider.filters.first

        updateComposition()
        mutableFilters.value = filterProvider.filters
            .map { EditorCollectionCellViewModel(title: $0.name, imageName: $0.imageName) }
    }

    func updateComposition() {
        videoEditor
            .createComposition(urls: urls)
            .sink(receiveCompletion: { [weak self] (completion) in
                guard case let .failure(error) = completion else { return }
                self?.mutableError.value = error.description
            }) { [weak self] (composition) in
                self?.mutableComposition.value = composition
        }.store(in: &bindings)
    }
}
