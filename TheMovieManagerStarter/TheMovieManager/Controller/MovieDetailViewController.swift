//
//  MovieDetailViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var watchlistBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem!
    
    var movie: Movie!
    
    var isWatchlist: Bool {
        return MovieModel.watchlist.contains(movie)
    }
    
    var isFavorite: Bool {
        return MovieModel.favorites.contains(movie)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = movie.title
        
        toggleBarButton(watchlistBarButtonItem, enabled: isWatchlist)
        toggleBarButton(favoriteBarButtonItem, enabled: isFavorite)
        
        guard let path = movie.posterPath else {return}
        TMDBClient.getPosterImage(path: path) { (data, error) in
            if let data = data {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
    @IBAction func watchlistButtonTapped(_ sender: UIBarButtonItem) {
        TMDBClient.markWatchList(movieId: movie.id, watchlist: !isWatchlist, completion: handleWatchListButtonTapped(success:err:))
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
        TMDBClient.markFavorites(movie: movie, favorite: !isFavorite, completion: handleFavoriteButton(success:error:))

    }
    
    func toggleBarButton(_ button: UIBarButtonItem, enabled: Bool) {
        if enabled {
            button.tintColor = UIColor.primaryDark
        } else {
            button.tintColor = UIColor.gray
        }
    }
    
    
    func handleFavoriteButton(success: Bool, error: Error? ){
        if success {
            MovieModel.favorites =  MovieModel.favorites.filter{$0 != movie}
        } else {
            MovieModel.favorites.append(movie)
        }
        toggleBarButton(favoriteBarButtonItem, enabled: !isFavorite)
    }
    
    
    
    
    
    
    func handleWatchListButtonTapped(success: Bool, err: Error?){
        if success {
            if isWatchlist {
                //if it's not currently on WatchList, this is a request by user to REMOVE
                //We check each element & reassign it back to MovieModel unless it matches self.movie
                MovieModel.watchlist = MovieModel.watchlist.filter(){ $0 != movie}
            } else {
                //if it is currently on WatchList, this is a request by user to ADD
                MovieModel.watchlist.append(movie)
            }
            toggleBarButton(watchlistBarButtonItem, enabled: isWatchlist)
        }
    }
}
