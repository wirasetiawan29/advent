//
//  SiwonModels.swift
//  Granth
//
//  Created by wira on 2/19/20.
//  Copyright © 2020 Goldenmace-ios. All rights reserved.
//

import Foundation

// MARK: - Article
struct Article: Codable {
    let data: [Siwon]
}

// MARK: - Datum
struct Siwon: Codable {
    let songID: Int
    let songTitle, songContent: String

    enum CodingKeys: String, CodingKey {
        case songID = "song_id"
        case songTitle = "song_title"
        case songContent = "song_content"
    }
}
