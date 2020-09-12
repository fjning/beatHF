//
//  StudyTableItem.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import Foundation
import UIKit

enum StudyTableItem: Int {
    
    // table items
    case survey
    
    static var allValues: [StudyTableItem] {
        var index = 0
        return Array (
            AnyIterator {
                let returnedElement = self.init(rawValue: index)
                index = index + 1
                return returnedElement
            }
        )
    }
    
    var title: String {
        switch self {
        case .survey:
            return "Discharge Survey"
		}

    }
    
    var subtitle: String {
        switch self {
        case .survey:
            return "A weekly survey for patients with advanced congestive heart failure."
		}

    }
    
    var image: UIImage? {
        switch self {
        case .survey:
            return UIImage(named: "SurveyIcon")
		}
    }
}
