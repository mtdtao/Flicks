//
//  CollectionMovieViewController.swift
//  MovieViewer
//
//  Created by ZengJintao on 1/13/16.
//  Copyright © 2016 ZengJintao. All rights reserved.
//

import UIKit
import JTProgressHUD

class CollectionMovieViewController: UIViewController, UISearchBarDelegate {

    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var imgDict = [NSDictionary: UIImage]()
    var endPoint: String!

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var netWorkErrorView: UIView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var refreshControl: UIRefreshControl!
    var dismissKeyboardTap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        let backButton = UIBarButtonItem()
        backButton.title = ""
        navigationItem.backBarButtonItem = backButton
        
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        searchBar.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        netWorkErrorView.hidden = true
        
        
        let tapNetworkError = UITapGestureRecognizer(target: self, action: "networkErrorTap")
        netWorkErrorView.addGestureRecognizer(tapNetworkError)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)

        
        connectMovieWithLoading()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true

    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            filteredMovies?.removeAll()
            for movie in movies! {
                if String(movie["title"]).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    print(movie["title"])
                    filteredMovies?.append(movie)
                }
            }
        }
        
        collectionView.reloadData()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        dismissKeyboardTap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(dismissKeyboardTap)
        return true
    }
    

    
    func networkErrorTap() {
        JTProgressHUD.showWithStyle(.Gradient)
        delay(2, closure: {
            JTProgressHUD.hide()
        })
        connectMovie()
    }
    
    func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
        self.view.removeGestureRecognizer(dismissKeyboardTap)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
        connectMovie()
    }
    
    
    func connectMovie() {
        

        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.refreshControl.endRefreshing()
                            self.netWorkErrorView.hidden = true
                            self.filteredMovies = self.movies
                            self.collectionView.reloadData()
                            JTProgressHUD.hide()
                    }
                    print("network good")
                } else {
                    self.netWorkErrorView.hidden = false
                    print("network error1")

                }
                if error != nil {
                    self.netWorkErrorView.hidden = false
                    print("network error2")
                }
        });
        task.resume()
    }
    
    func connectMovieWithLoading(){
        JTProgressHUD.showWithStyle(.Gradient)
        connectMovie()
        self.delay(2, closure: {
            JTProgressHUD.hide()
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CollectionMovieViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = filteredMovies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionCell", forIndexPath: indexPath) as! MovieCollectionViewCell
        print("=============")
        if let movie = filteredMovies?[indexPath.row] {
            if let posterPath = movie["poster_path"] as? String {
                print(movie["poster_path"])
                
                let baseUrl = "http://image.tmdb.org/t/p/w500"
                let imageUrl = NSURL(string: baseUrl + posterPath)
                let imageRequest = NSURLRequest(URL: imageUrl!)
                
                
                cell.moviePoster.setImageWithURLRequest(imageRequest, placeholderImage: nil, success: { (imageRequest, imageResponse, image) -> Void in
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.moviePoster.alpha = 0.0
                        cell.moviePoster.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.moviePoster.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        cell.moviePoster.image = image
                    }
                    }, failure: { (imageRequest, imageResponse, error) -> Void in
                        print("picture load fail")
                        print(movie["title"])
                        cell.moviePoster.image = UIImage(named: "template")
                })
            } else {
                print("null pic")
                print(movie["title"])
                cell.moviePoster.image = UIImage(named: "template")
            }
        }
        
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.redColor()
        cell.selectedBackgroundView = backgroundView
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let totalwidth = collectionView.bounds.size.width;
        let numberOfCellsPerRow = 2
        let dimensions = CGFloat(Int(totalwidth) / numberOfCellsPerRow)
        return CGSizeMake(dimensions, dimensions/0.675)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*if segue.identifier == "goToDetail" {
            print("segue to detailview")
            let cell = sender as! MovieCollectionViewCell
            let index = self.collectionView.indexPathForCell(cell)
            var detailView = segue.destinationViewController as! MovieDetailViewController
            detailView.posterImg = cell.moviePoster.image
            if let title = filteredMovies![index!.row]["title"] as? String {
                detailView.title = title
            }
            if let overview = filteredMovies![index!.row]["overview"] as? String {
                detailView.overview = "Overview: \(overview)"
            }
            if let voteAvg = filteredMovies![index!.row]["vote_average"] as? NSNumber {
                detailView.score = String(format: "%.1f", Double(voteAvg))
            }
            if let voteCnt = filteredMovies![index!.row]["vote_count"] as? NSNumber {
                detailView.votePoepleCount = "Voted by \(voteCnt) people"
            }
            if let releaseDate = filteredMovies![index!.row]["release_date"] as? String {
                detailView.releaseDate = "Release date: \(releaseDate)"
            }

        }*/

        
        
        let cell = sender as! UICollectionViewCell
        let indexPath = self.collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        
    }
}

