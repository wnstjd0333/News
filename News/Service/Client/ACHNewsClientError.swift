//
//  ACHNewsClientError.swift
//  News
//
//  Created by j.lee on 2020/02/17.
//  Copyright © 2020 archive-asia. All rights reserved.
//

import Foundation

enum ACHNewsClientError : Error {
    case connectionError(Error)
    case responseParseError(Error)
    case apiError(ACHNewsAPIError)
}
