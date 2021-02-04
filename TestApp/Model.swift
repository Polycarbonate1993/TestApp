//
//  Model.swift
//  Moya
//
//  Created by Андрей Гедзюра on 03.02.2021.
//

import Foundation

/// Class wrapper for data received from the URL requests.
class Post: Codable {
    let title: String
    let urlSmall: String
    let urlMedium: String?
    let urlBig: String?
    private let _description: Description
    var description: String {
        return _description._content
    }
    private struct Description: Codable {
        let _content: String
    }
    private enum CodingKeys: String, CodingKey {
        case title
        case urlSmall = "url_t"
        case urlBig = "url_c"
        case urlMedium = "url_w"
        case _description = "description"
    }
}
