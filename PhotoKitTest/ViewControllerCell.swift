//
//  Created by Pete Callaway on 20/07/2014.
//  Copyright (c) 2014 Dative Studios. All rights reserved.
//

import UIKit

class ViewControllerCell: UICollectionViewCell {

    @IBOutlet var assetImageView: UIImageView

    class func reuseIdentifier() -> String {
        return "ViewControllerCell"
    }
}
