//
//  APIPostData.swift
//  JOConnor
//
//  Created by Matt Sencenbaugh on 6/16/17.
//  Copyright © 2017 mattsencenbaugh. All rights reserved.
//

import Foundation

// PostData is intended to be overriden by your own Codable models, or custom Encodable wrappers
open class PostData : Encodable {
    open func encode(to encoder: Encoder) throws {
        
    }
}
