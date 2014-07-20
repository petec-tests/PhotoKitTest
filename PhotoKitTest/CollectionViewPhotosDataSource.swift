//
//  Created by Pete Callaway on 20/07/2014.
//  Copyright (c) 2014 Dative Studios. All rights reserved.
//

import Foundation
import Photos



class CollectionViewAssetCollectionDataSource: NSObject, UICollectionViewDataSource, PHPhotoLibraryChangeObserver {
    let assetCollectionFetchResult: PHFetchResult
    let dequeueCellForAsset: (asset: PHAsset, indexPath: NSIndexPath) -> UICollectionViewCell
    let dequeuePlaceholderCell: (indexPath: NSIndexPath) -> UICollectionViewCell

    var cachedFetchResults = [String: PHFetchResult]()

    init(fetchResult: PHFetchResult,
        dequeueCellForAsset: (asset: PHAsset, indexPath: NSIndexPath) -> UICollectionViewCell,
        dequeuePlaceholderCell: (indexPath: NSIndexPath) -> UICollectionViewCell) {

        self.assetCollectionFetchResult = fetchResult
        self.dequeueCellForAsset = dequeueCellForAsset
        self.dequeuePlaceholderCell = dequeuePlaceholderCell

        super.init()

        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }


    // ---- UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return assetCollectionFetchResult.count
    }


    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {

        let assetCollection = assetCollectionFetchResult[section] as PHAssetCollection

        // Use the estimated count if the section isn't visible
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems() as [NSIndexPath]
        var useEstimatedCount = true

        for indexPath in visibleIndexPaths {
            if indexPath.section == section {
                useEstimatedCount = false
                break
            }
        }

        if useEstimatedCount {
            return assetCollection.estimatedAssetCount
        }
        else {
            let fetchedAssets = fetchResultForAssetCollection(assetCollection)
            return fetchedAssets.count
        }
    }


    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let assetCollection = assetCollectionFetchResult[indexPath.section] as PHAssetCollection

        // Check if we've used an estimated count for the section up to now
        if cachedFetchResults[assetCollection.localIdentifier] == nil {

            // If the estimated count isn't the same as the actual count, return an empty cell and reload the section
            let fetchedAssets = fetchResultForAssetCollection(assetCollection)

            if fetchedAssets.count != assetCollection.estimatedAssetCount {
                let placeholderCell = dequeuePlaceholderCell(indexPath: indexPath)
                collectionView.reloadSections(NSIndexSet(index: indexPath.section))

                return placeholderCell
            }
        }

        return dequeueCellForAsset(asset: assetAtIndexPath(indexPath), indexPath: indexPath)
    }


    // ----

    func photoLibraryDidChange(changeInstance: PHChange!) {
    }


    // ----

    func fetchResultForAssetCollection(assetCollection: PHAssetCollection) -> PHFetchResult {
        var fetchResult = cachedFetchResults[assetCollection.localIdentifier]

        if fetchResult == nil {
            fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
            cachedFetchResults[assetCollection.localIdentifier] = fetchResult!
        }

        return fetchResult!
    }

    func assetAtIndexPath(indexPath: NSIndexPath) -> PHAsset {
        let assetCollection = assetCollectionFetchResult[indexPath.section] as PHAssetCollection
        let fetchResult = fetchResultForAssetCollection(assetCollection)

        return fetchResult[indexPath.row] as PHAsset
    }
}