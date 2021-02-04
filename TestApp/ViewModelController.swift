//
//  ViewModelController.swift
//  TestApp
//
//  Created by Андрей Гедзюра on 03.02.2021.
//

import Foundation
import Moya

/// Adapter class that requests for data via Network, transform and store the results in suitable form.
class ViewModelController {
    private var storage = ThreadSafeArray<Post>()
    private var nextPage = 1
    private var provider = MoyaProvider<Flickr>()
    
    
    /// Requests items from the server, transforms them into Model and stores them.
    /// - Parameters:
    ///   - dispatchQueue: DispatchQueue for executing success: and failure: closures.
    ///   - success: The closure that is executed in case of successful retrieving and transforming data.
    ///   - failure: The closure that executes in case of any Error.
    func getItems(dispatchQueue: DispatchQueue = DispatchQueue.main, success: @escaping([IndexPath]) -> Void, failure: @escaping(Error) -> Void) {
        provider.request(Flickr.recents(page: nextPage), completion: {result in
            switch result {
            case .success(let response):
                do {
                    let newContent = try response.mapWithNestedKeyPath("photos:photo", [Post].self, failsOnEmptyData: false)
                    var indices: [IndexPath] = []
                    for i in 0..<newContent.endIndex {
                        indices.append(IndexPath(item: i + self.storage.endIndex, section: 0))
                    }
                    self.storage.append(contentsOf: newContent)
                    self.nextPage += 1
                    dispatchQueue.async {success(indices)}
                } catch {
                    dispatchQueue.async {failure(error)}
                }
            case .failure(let error):
                dispatchQueue.async {failure(error)}
            }
        })
    }
    
    /// Retrieves the item from the storage.
    /// - Parameter index: Index of the item in the storage.
    /// - Returns: If the index is in range of storage indices then returns the item otherwise returns nil.
    func itemAtIndex(_ index: Int) -> Post? {
        guard index < storage.count else {
            return nil
        }
        return storage[index]
    }
    
    /// The number of items in the storage.
    var itemsCount: Int {
        return storage.count
    }
}
