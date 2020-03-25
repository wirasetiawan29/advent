//
//  BookCategoryModel.swift
//  Granth
//
//  Created by wira on 2/16/20.
//  Copyright © 2020 Goldenmace-ios. All rights reserved.
//

import Foundation

class BookCategoryModel:NSObject {
    var bookId: Int = 0
    var imageBackground: String = ""
    var name: String = ""

    init(bookId:Int!, imageBackground: String!, name: String!) {
        super.init()
        self.bookId = bookId
        self.imageBackground = imageBackground
        self.name = name
    }
}




