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

            // Check if we've already queued a closure to get the PHFetchResult
            if identifiersForPendingFetchResults[assetCollection.localIdentifier] == nil {

                // Add the asset collection's identifier to the list of asset collections we're waiting for fetch results for
                identifiersForPendingFetchResults[assetCollection.localIdentifier] = assetCollection.localIdentifier

                dispatch_async(loadFetchResultsQueue) {
                    // Get the PHFetchResult for the asset collection - this is the slow part
                    let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)

                    dispatch_async(dispatch_get_main_queue()) {
                        self.cachedFetchResults[assetCollection.localIdentifier] = fetchResult
                        self.identifiersForPendingFetchResults[assetCollection.localIdentifier] = nil

                        // Reload the collection view's section
                        UIView.performWithoutAnimation() {
                            collectionView.reloadSections(NSIndexSet(index: indexPath.section))
                        }
                    }
                }
            }

            return dequeuePlaceholderCell(indexPath: indexPath)
        }
    }
}