//
//  FeedTableViewCell.swift
//  Video Editor
//
//  Created by Krish Shah on 22/05/21.
//

import UIKit
import AVKit

class FeedTableViewCell: UITableViewCell {
    
    var url: String = ""
    
    var playerView = UIView()
    lazy var player = AVPlayer()
    let playerLayer = AVPlayerLayer()
    
    let playButton = UIButton()
    var infoView = UIStackView()
    
    var playing = false

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func didMoveToSuperview() {
        addInfo()
        addPlayerView()
    }
    
    func addPlayerView() {
        self.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
        playerView.bottomAnchor.constraint(equalTo: self.infoView.topAnchor, constant: -16).isActive = true
        playerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        playerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        
        let url = URL(fileURLWithPath: url)
        player = AVPlayer(url: url)
        playerLayer.player = player
        playerLayer.frame = playerView.frame
        playerLayer.videoGravity = .resizeAspect
        playerView.layer.addSublayer(playerLayer)
        
        playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        self.playerView.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.centerXAnchor.constraint(equalTo: self.playerView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: self.playerView.centerYAnchor).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 50).isActive = true 
        playButton.addTarget(self, action: #selector(play), for: .touchDown)
    }
    
    func addInfo() {
        let likeButton = UIButton()
        likeButton.setImage(UIImage(systemName: "suit.heart"), for: .normal)
        likeButton.setImage(UIImage(systemName: "suit.heart.fill"), for: .selected)
        likeButton.tintColor = .systemPink
        
        let authorLabel = UILabel()
        authorLabel.text = "By Krish Shah"
        self.addSubview(infoView)
        self.infoView.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addArrangedSubview(authorLabel)
        self.infoView.addArrangedSubview(likeButton)
        self.infoView.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.infoView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.infoView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        self.infoView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
    }
    
    func resizePlayLayer() {
        playerLayer.frame = playerView.bounds
    }
    
    @objc func play() {
        resizePlayLayer()
        if !playing {
            playButton.setImage(UIImage(systemName:"pause.circle.fill"), for: .normal)
            player.play()
            playing = true
        }else {
            playButton.setImage(UIImage(systemName:"play.circle.fill"), for: .normal)
            player.pause()
            playing = false
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }

}
