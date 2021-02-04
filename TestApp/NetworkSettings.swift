//
//  NetworkSettings.swift
//  TestApp
//
//  Created by Андрей Гедзюра on 03.02.2021.
//

import Foundation
import Moya

enum Flickr: TargetType {
    case recents(page: Int)
    
    var baseURL: URL {
        guard let url = URL(string: "https://www.flickr.com/services/rest") else {
            fatalError("Invalid base URL. Cannot create URL from String.")
        }
        return url
    }
    var path: String {
        return ""
    }
    var method: Moya.Method {
        switch self {
        case .recents(_):
            return .get
        }
    }
    var task: Task {
        switch self {
        case .recents(let page):
            return .requestParameters(parameters: [
                "api_key": "c9a7b8ee063f37008571b52fb74ab265",
                "format": "json",
                "nojsoncallback": 1,
                "method": "flickr.photos.getRecent",
                "extras": "description,url_c,url_t",
                "page": page,
                "per_page": 15
            ], encoding: URLEncoding.queryString)
        }
    }
    var sampleData: Data {
        switch self {
        case .recents(let page):
            return "{\"photos\":{\"page\":\(page),\"pages\":10,\"perpage\":100,\"total\":1000,\"photo\":[{\"id\":\"50903517703\",\"owner\":\"29954808@N00\",\"secret\":\"356f6f5455\",\"server\":\"65535\",\"farm\":66,\"title\":\"Milvus migrans - Black Kite\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0,\"description\":{\"_content\":\"\"},\"url_c\":\"https:\\/\\/live.staticflickr.com\\/65535\\/50903517703_356f6f5455_c.jpg\",\"height_c\":534,\"width_c\":800,\"url_t\":\"https:\\/\\/live.staticflickr.com\\/65535\\/50903517703_356f6f5455_t.jpg\",\"height_t\":67,\"width_t\":100}]}".utf8Encoded
        }
    }
    var headers: [String : String]? {
        switch self {
        case .recents(_):
            return nil
        }
    }
}
    
