//
//  Petition.swift
//  petitions
//
//  Created by BJ on 2019-05-08.
//  Copyright © 2019 BJ. All rights reserved.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
