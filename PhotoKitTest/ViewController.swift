//
//  Created by Pete Callaway on 18/07/2014.
//  Copyright (c) 2014 Dative Studios. All rights reserved.
//

import UIKit
import Photos

extension Array {
    func componentsJoinedByString(joiner: String) -> String {
        var result = ""

        for object in self {
            if result.isEmpty {
                result = "\(object)"
            }
            else {
                result += "\(joiner)\(object)"
            }
        }

        return result
    }
}



class ViewController: UICollectionViewController {

    var dataSource :CollectionViewAssetCollectionDataSource?
    var imageManager :PHImageManager?
                            
    override func viewDidLoad() {
        super.viewDidLoad()

        imageManager = PHImageManager()

        dataSource = CollectionViewAssetCollectionDataSource(fetchResult: PHAssetCollection.fetchMomentsWithOptions(nil),
            dequeueCellForAsset: dequeueCellForAsset,
            dequeuePlaceholderCell: dequeuePlaceholderCell
        )

        collectionView.dataSource = dataSource
//
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "EEEE"
//
//        let momentsFetchResult = PHAssetCollection.fetchMomentsWithOptions(nil)
//
//        for index in 0 ..< momentsFetchResult.count {
//            let moment = momentsFetchResult[index] as PHAssetCollection
//            let assets = PHAsset.fetchAssetsInAssetCollection(moment, options: nil)
//
//            var descriptionElements: [String] = []
//
//            if let title = moment.localizedTitle as String? {
//                descriptionElements += title
//            }
//
//            if let locationNames = moment.localizedLocationNames as [String]? {
//                descriptionElements += locationNames.componentsJoinedByString(", ")
//            }
//
//            if descriptionElements.count == 0 {
//                var startDate = moment.startDate
//                if startDate != nil {
//                    descriptionElements += dateFormatter.stringFromDate(startDate)
//                }
//            }
//
//            let description = descriptionElements.componentsJoinedByString(" - ")
//
//            println("\(description) contains \(assets.count) assets")
//        }
    }

    func dequeueCellForAsset(asset: PHAsset, atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ViewControllerCell.reuseIdentifier(), forIndexPath: indexPath) as ViewControllerCell

        let scale = self.view.window.screen.scale
        let targetSize = CGSize(width: cell.assetImageView.bounds.size.width * scale, height: cell.assetImageView.bounds.size.height * scale)

        imageManager?.requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: nil) {(image, info) in
            cell.assetImageView.image = image
        }

        return cell
    }

    func dequeuePlaceholderCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ViewControllerCell.reuseIdentifier(), forIndexPath: indexPath) as ViewControllerCell
        cell.assetImageView.image = nil
        return cell
    }
}

