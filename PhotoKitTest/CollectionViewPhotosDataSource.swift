//
//  Created by Pete Callaway on 20/07/2014.
//  Copyright (c) 2014 Dative Studios. All rights reserved.
//

import Foundation
import Photos



class CollectionViewAssetCollectionDataSource: NSObject, UICollectionViewDataSource {

    let assetCollectionFetchResult: PHFetchResult
    let dequeueCellForAsset: (asset: PHAsset, indexPath: NSIndexPath) -> UICollectionViewCell
    let dequeuePlaceholderCell: (indexPath: NSIndexPath) -> UICollectionViewCell

    var cachedFetchResults = [String: PHFetchResult]()

    var identifiersForPendingFetchResults = [String: String]()
    var loadFetchResultsQueue = dispatch_queue_create("CollectionViewAssetCollectionDataSource", DISPATCH_QUEUE_SERIAL)


    init(fetchResult: PHFetchResult,
        dequeueCellForAsset: (asset: PHAsset, indexPath: NSIndexPath) -> UICollectionViewCell,
        dequeuePlaceholderCell: (indexPath: NSIndexPath) -> UICollectionViewCell) {

        self.assetCollectionFetchResult = fetchResult
        self.dequeueCellForAsset = dequeueCellForAsset
        self.dequeuePlaceholderCell = dequeuePlaceholderCell

        super.init()
    }


    // ---- UICollectionViewDataSource methods

    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return assetCollectionFetchResult.count
    }


    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {

        let assetCollection = assetCollectionFetchResult[section] as PHAssetCollection

        // Return the actual count if we know it
        if let fetchResult = cachedFetchResults[assetCollection.localIdentifier] {
            return fetchResult.count
        }
        else {
            return assetCollection.estimatedAssetCount
        }
    }


    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let assetCollection = assetCollectionFetchResult[indexPath.section] as PHAssetCollection

        if let fetchResult = cachedFetchResults[assetCollection.localIdentifier] {
            // We already have the PHFetchResult for this asset collection, so get a cell for it
            return dequeueCellForAsset(asset: fetchResult[indexPath.row] as PHAsset, indexPath: indexPath)
        }
        else {
            // We don't have the PHFetchResult for this asset collection yet

            // Queue a closure to get the fetch results for asset collection if we haven't already done so
            if identifiersForPendingFetchResults[assetCollection.localIdentifier] == nil {

                dispatch_async(loadFetchResultsQueue) {

                    // Get the PHFetchResult for the asset collection - this is the slow part
                    self.cachedFetchResults[assetCollection.localIdentifier] = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)

                    dispatch_async(dispatch_get_main_queue()) {
                        // Clear the asset collection's identifier from the queued list
                        self.identifiersForPendingFetchResults[assetCollection.localIdentifier] = nil

                        // Reload the collection view's section
                        UIView.performWithoutAnimation() {
                            collectionView.reloadSections(NSIndexSet(index: indexPath.section))
                        }
                    }
                }

                identifiersForPendingFetchResults[assetCollection.localIdentifier] = assetCollection.localIdentifier
            }

            return dequeuePlaceholderCell(indexPath: indexPath)
        }
    }
}