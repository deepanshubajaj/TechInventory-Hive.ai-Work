//
//  ImageService.swift
//  Hive
//
//  Created by Deepanshu Bajaj on 01/10/25.
//

import Foundation
import UIKit

class ImageService {
    static func fetchImages(page: Int, completion: @escaping (Result<[ImageModel], Error>) -> Void) {
        let urlString = "https://picsum.photos/v2/list?page=\(page)&limit=10"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let images = try JSONDecoder().decode([ImageModel].self, from: data)
                completion(.success(images))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
