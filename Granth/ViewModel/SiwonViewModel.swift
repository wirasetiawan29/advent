//
//  SiwonViewModel.swift
//  Granth
//
//  Created by wira on 2/19/20.
//  Copyright © 2020 Goldenmace-ios. All rights reserved.
//

import Foundation

struct SiwonListViewModel {
    let siwons: [Siwon]
}

extension SiwonListViewModel {
    var numberOfSections: Int {
        return 1
    }

    func numberOfRowInSection(_ section:Int) -> Int {
        return self.siwons.count
    }

    func articleAtIndex(_ index:Int) -> SiwonViewModel {
        let article = self.siwons[index]
        return SiwonViewModel(article)
    }
}

struct SiwonViewModel {
    private let article: Siwon
}

extension SiwonViewModel {
    init(_ article: Siwon) {
        self.article = article
    }
}

extension SiwonViewModel {
    var title: String {
        return self.article.songTitle
    }

    var desc: String {
        return self.article.songContent
    }
}
