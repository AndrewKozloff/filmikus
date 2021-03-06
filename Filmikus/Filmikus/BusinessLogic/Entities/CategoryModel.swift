//
//  CategoryModel.swift
//  Filmikus
//
//  Created by Андрей Козлов on 28.05.2020.
//  Copyright © 2020 Андрей Козлов. All rights reserved.
//
import Foundation

struct CategoryModel: Decodable {
	let id: Int
	let title: String
	
	enum CodingKeys: String, CodingKey {
		case id
		case title
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		// Сервер почему-то присылает айди строкой. Приходится парсить вручную.
		if let id = try? container.decode(Int.self, forKey: CodingKeys.id) {
			self.id = id
		} else {
			let strId = try container.decode(String.self, forKey: CodingKeys.id)
			guard let id = Int(strId) else {
				throw NSError()
			}
			self.id = id
		}
		title = try container.decode(String.self, forKey: CodingKeys.title)
	}
}
