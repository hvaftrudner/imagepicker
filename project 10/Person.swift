//
//  Person.swift
//  project 10
//
//  Created by Kristoffer Eriksson on 2020-09-26.
//

import UIKit

class Person: NSObject, Codable {
    var name : String
    var image: String
    
    init(name: String, image: String){
        self.name = name
        self.image = image
    }
}
