//
//  FeedViewController.swift
//  Video Editor
//
//  Created by Krish Shah on 22/05/21.
//

import UIKit

let cellID = "videoFeedCell"

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    
    var videoURLs = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: cellID)
        loadVideoURLs()
    }
    
    func loadVideoURLs() {
        let videoPath = URL(fileURLWithPath: NSTemporaryDirectory())
        let urls = try? FileManager.default.contentsOfDirectory(atPath: videoPath.path)
        guard let videoURLs = urls else {return}
        for url in videoURLs {
            let fileExtension = URL(fileURLWithPath: url).pathExtension
            if fileExtension == "mov" {
                self.videoURLs.append(videoPath.path  + "/" + url)
            }
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoURLs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! FeedTableViewCell
        cell.contentView.isUserInteractionEnabled = false
        cell.url = videoURLs[indexPath.row]
        return cell
    }

}
