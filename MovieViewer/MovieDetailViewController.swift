//
//  MovieDetailViewController.swift
//  MovieViewer
//
//  Created by ZengJintao on 1/16/16.
//  Copyright © 2016 ZengJintao. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var movieOverview: UITextView!
    
    @IBOutlet weak var testtext: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var votePeopleNumber: UILabel!
    
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    
    var overview = "empty"
    var votePoepleCount = "Voted by unknown people"
    var score = "-"
    var posterImg:UIImage?
    var releaseDate = "Release date: Unknown"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        movieOverview.text = overview
        movieOverview.textColor = UIColor.whiteColor()
        
        posterImage.image = posterImg
        
        scoreLabel.text = score
        
        votePeopleNumber.text = votePoepleCount
        
        releaseDateLabel.text = releaseDate
        
        self.view.backgroundColor = UIColor.blackColor()
        
        var attributesForTitle = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(15)
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attributesForTitle
        self.navigationController!.navigationBar.barTintColor = UIColor.blackColor()
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
