//
//  VideosService.swift
//  Filmikus
//
//  Created by Андрей Козлов on 28.05.2020.
//  Copyright © 2020 Андрей Козлов. All rights reserved.
//

import Moya

protocol VideosServiceType {
	func getMovies(of type: MovieType, with filter: FilterModel, completion: @escaping (Result<MoviesModel, Error>) -> Void)
	func searchMovies(query: String, completion: @escaping (Result<[MovieModel], Error>) -> Void)
	func detailMovie(id: Int, completion: @escaping (Result<DetailMovieModel, Error>) -> Void)
	func detailSerial(id: Int, completion: @escaping (Result<DetailMovieModel, Error>) -> Void)
	func detailFunShow(id: Int, completion: @escaping (Result<DetailFunShowModel, Error>) -> Void)
	func detailEpisode(id: Int, completion: @escaping (Result<DetailEpisodeModel, Error>) -> Void)
}

class VideosService: VideosServiceType {
	
	private let provider: MoyaProvider<VideosAPI>
	
	init(provider: MoyaProvider<VideosAPI> = MoyaProvider<VideosAPI>()) {
		self.provider = provider
	}
	
	func getMovies(of type: MovieType, with filter: FilterModel, completion: @escaping (Result<MoviesModel, Error>) -> Void) {
		provider.request(.filteredList(type: type, filter: filter)) { (result) in
			completion(
				result.mapError { $0 }.flatMap { response in
					Result { try response.map(MoviesModel.self) }
				}
			)
		}
	}
	
	func searchMovies(query: String, completion: @escaping (Result<[MovieModel], Error>) -> Void) {
		provider.request(.search(query: query)) { (result) in
			completion(
				result.mapError { $0 }.flatMap { response in
					Result { try response.map([MovieModel].self) }
				}
			)
		}
	}
	
	func detailMovie(id: Int, completion: @escaping (Result<DetailMovieModel, Error>) -> Void) {
		provider.request(.item(type: .film, id: id)) { (result) in
			completion(
				result.mapError { $0 }.flatMap { response in
					Result { try response.map(DetailMovieModel.self) }
				}
			)
		}
	}
	
	func detailSerial(id: Int, completion: @escaping (Result<DetailMovieModel, Error>) -> Void) {
		provider.request(.item(type: .serial, id: id)) { (result) in
			completion(
				result.mapError { $0 }.flatMap { response in
					Result { try response.map(DetailMovieModel.self) }
				}
			)
		}
	}
	
	func detailFunShow(id: Int, completion: @escaping (Result<DetailFunShowModel, Error>) -> Void) {
		provider.request(.item(type: .funShow, id: id)) { (result) in
			completion(
				result.mapError { $0 }.flatMap { response in
					Result { try response.map(DetailFunShowModel.self) }
				}
			)
		}
	}
	
	func detailEpisode(id: Int, completion: @escaping (Result<DetailEpisodeModel, Error>) -> Void) {
		provider.request(.episode(id: id)) { (result) in
			completion(
				result.mapError { $0 }.flatMap { response in
					Result { try response.map(DetailEpisodeModel.self) }
				}
			)
		}
	}
	
}
