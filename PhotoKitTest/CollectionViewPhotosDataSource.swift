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

    var cachedSectionFetchResults = [Int: PHFetchResult]()

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
            let assetCollection = assetCollectionFetchResult[section] as PHAssetCollection
            return assetCollection.estimatedAssetCount
        }
        else {
            let fetchedAssets = fetchResultForSectionAtIndex(section)
            return fetchedAssets.count
        }
    }


    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {

        // Check if we've used an estimated count for the section up to now
        if cachedSectionFetchResults[indexPath.section] == nil {

            // If the estimated count isn't the same as the actual count, return an empty cell and reload the section
            let assetCollection = assetCollectionFetchResult[indexPath.section] as PHAssetCollection
            let fetchedAssets = fetchResultForSectionAtIndex(indexPath.section)

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

    func fetchResultForSectionAtIndex(index: Int) -> PHFetchResult {
        var fetchResult = cachedSectionFetchResults[index]

        if fetchResult == nil {
            let assetCollection = assetCollectionFetchResult[index] as PHAssetCollection
            fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
            
            cachedSectionFetchResults[index] = fetchResult!
        }

        return fetchResult!
    }

    func assetAtIndexPath(indexPath: NSIndexPath) -> PHAsset {
        return fetchResultForSectionAtIndex(indexPath.section)[indexPath.row] as PHAsset
    }
}