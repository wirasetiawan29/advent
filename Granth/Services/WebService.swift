//
//  WebService.swift
//  Granth
//
//  Created by wira on 2/19/20.
//  Copyright © 2020 Goldenmace-ios. All rights reserved.
//

import Foundation

class Webservice {

    func getSiwons(url: URL, completion: @escaping ([Siwon]?) -> ()) {

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else if let data = data {
                let articles = try! JSONDecoder().decode(Article.self, from: data).data
                completion(articles)
            }

        }.resume()
    }
}
