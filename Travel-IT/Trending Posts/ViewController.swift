//
//  ViewController.swift
//  Travel-IT
//
//  Created by Ankit Singh on 17/03/18.
//  Copyright © 2018 Ankit Singh. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var travelpostsTableView: UITableView!
    var allPosts = [[String: AnyObject]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Trending Travel Posts"
        self.travelpostsTableView.delegate = self
        self.travelpostsTableView.dataSource = self
        self.getTredingTravelPosts()
    }
    
    func getTredingTravelPosts() {
        let url = URL(string: "https://api.steemjs.com/get_discussions_by_trending?query=%7B%22tag%22%3A%22travel%22%2C%20%22limit%22%3A%20%2210%22%7D")!
        URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    var json = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String: AnyObject]]
                    for post in json {
                        self.allPosts.append(post)
                    }
                    DispatchQueue.main.async(execute: {
                    self.travelpostsTableView.reloadData()
                    })
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "PostsTableCell", for: indexPath) as? PostsTableCell
        let cellData = self.allPosts[indexPath.row]
        cell?.updateCellData(data: cellData)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 265
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postData = self.allPosts[indexPath.row]
        let metadata = postData["json_metadata"]! as! String
        var mainImage: String?
        let data = metadata.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:AnyObject]
            {
                let images = jsonArray["image"] as! [String]
                mainImage = images[0]
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PostShowVC") as! PostShowVC
        vc.postData = postData
        vc.postMainImage = mainImage
        navigationController?.pushViewController(vc,animated: true)
    }
}

