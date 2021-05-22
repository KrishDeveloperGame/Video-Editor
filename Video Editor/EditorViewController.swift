//
//  ViewController.swift
//  Video Editor
//
//  Created by Krish Shah on 18/05/21.
//

import UIKit
import SpriteKit
import AVFoundation
import CoreGraphics
import AVKit
import MobileCoreServices

class EditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var videoLoaded = false
    
    var overlayLayer = CALayer()
    var overlayPreviewLayer = CALayer()
    var textLayer: CATextLayer!
    
    var lastTranslation = CGPoint()
    
    var asset: AVURLAsset!
    lazy var composition = AVMutableComposition()
    var compositionTrack: AVMutableCompositionTrack!
    var assetTrack: AVAssetTrack!
    var videoSize: CGSize!
    var videoLayer: CALayer!
    var combinedLayer: CALayer!
    var videoPlayerLayer: AVPlayerLayer!
    var combinedPreviewLayer: CALayer!

    let exportButton = UIButton(type: .system)

    
    lazy var naturalSize: CGSize = {
        let videoInfo = orientation(from: assetTrack.preferredTransform)
        var vidSize: CGSize
        if videoInfo.isPortrait {
          vidSize = CGSize(
            // reversing the sizes for potrait
            width: assetTrack.naturalSize.height,
            height: assetTrack.naturalSize.width)
        }else {
            vidSize = assetTrack.naturalSize
        }
        return vidSize
    }()
    
    lazy var videoContainer = UIView(frame: view.frame)
    
    override func viewDidLoad() {
        self.view.addSubview(videoContainer)
        addTextButton()
        videoContainer.translatesAutoresizingMaskIntoConstraints = false
        videoContainer.topAnchor.constraint(equalTo: exportButton.bottomAnchor, constant: 16).isActive = true
        videoContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        videoContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        videoContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.view.sendSubviewToBack(videoContainer)
        self.view.backgroundColor = .black
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !videoLoaded {
            let pickerController = UIImagePickerController()
            pickerController.sourceType = .savedPhotosAlbum
            pickerController.mediaTypes = [kUTTypeMovie as String]
            pickerController.delegate = self
            present(pickerController, animated: true)
        }else {
            self.view.endEditing(true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[.mediaURL] as? URL {
            setupVideoLayers(url: videoURL)
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func setupVideoLayers(url: URL) {
        // setting up the asset and composition
        asset = AVURLAsset(url: url)
        guard let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {return}
        guard let assetTrack = asset.tracks(withMediaType: .video).first else {return}
        self.compositionTrack = compositionTrack
        self.assetTrack = assetTrack
        do {
        // Setup the video time range
          let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
          try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
          
        // Add audio if present.
          if let audioTrack = asset.tracks(withMediaType: .audio).first,
            let compositionAudioTrack = composition.addMutableTrack(
              withMediaType: .audio,
              preferredTrackID: kCMPersistentTrackID_Invalid) {
            try compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: .zero)
          }
        } catch {
            print(error.localizedDescription)
          return
        }
        // Setting up a prefered transform
        compositionTrack.preferredTransform = assetTrack.preferredTransform
        
        // calculating video size after scalling it to fit the view's frame.
        
        videoSize = CGSize(width: naturalSize.width * view.frame.width / naturalSize.width, height: naturalSize.height * view.frame.width / naturalSize.width)
        
        let frame = CGRect(origin: .zero , size: videoSize) // frame to fit the view (for a preview)
        let naturalFrame = CGRect(origin: .zero, size: naturalSize) // frame relating to the original size
        
        // Setting up the 3 layers
        videoLayer = CALayer()
        videoLayer.frame = naturalFrame // original video
        
        let player = AVPlayer(url: url)
        videoPlayerLayer = AVPlayerLayer(player: player)
        videoPlayerLayer.frame = frame // preview
        
        overlayPreviewLayer = CALayer()
        overlayPreviewLayer.frame = frame // preview of text's position
        
        overlayLayer = CALayer()
        overlayLayer.frame = naturalFrame
        
        // Combining them into one
        combinedLayer = CALayer()
        combinedLayer.frame = naturalFrame
        combinedLayer.addSublayer(videoLayer)
        combinedLayer.addSublayer(overlayLayer)
        videoLayer.contentsGravity = .resizeAspect
        
        combinedPreviewLayer = CALayer()
        combinedPreviewLayer.frame = frame
        combinedPreviewLayer.addSublayer(videoPlayerLayer)
        combinedPreviewLayer.addSublayer(overlayPreviewLayer)
        self.videoContainer.layer.addSublayer(combinedLayer)// this is a video container which is at the back of the screen
        self.videoContainer.layer.addSublayer(combinedPreviewLayer)
        videoLoaded = true
    }
    
    @objc func recordAndExportVideo() {
        //Setup the text view according the the video size
        let x = overlayLayer.frame.width / overlayPreviewLayer.frame.width
        let newTextLayer = textLayer!
        newTextLayer.fontSize = 18*x
        newTextLayer.frame.origin.y = newTextLayer.frame.origin.y - newTextLayer.frame.origin.y * x + 10
        newTextLayer.frame.origin.x *= x
        newTextLayer.frame.size.width *= x
        newTextLayer.frame.size.height *= x
        
        // add the typing animation
        let myAnimation = CAKeyframeAnimation(keyPath: "string");
        myAnimation.beginTime = 0;
        var values = [""]
        var str = ""
        for letter in newTextLayer.string as! String {
            str += "\(letter)"
            values.append(str)
        }
        let leftover = Int((composition.duration.seconds)-(Double(values.count)*0.1))
        if leftover > 1 {
            for _ in 0...leftover {
                values.append(newTextLayer.string as! String)
            }
        }
        myAnimation.duration = Double(values.count)*0.1
        myAnimation.values = values
        myAnimation.fillMode = CAMediaTimingFillMode.forwards;
        myAnimation.isRemovedOnCompletion = false;
        newTextLayer.add(myAnimation, forKey: "anim")
        overlayLayer.addSublayer(newTextLayer)
        
        // create a composition
        let videoComposition = AVMutableVideoComposition()
        createComposition(videoComposition: videoComposition, duration: myAnimation.duration)
        guard let export = AVAssetExportSession(
          asset: composition,
          presetName: AVAssetExportPresetHighestQuality)
          else {
            print("Cannot create export session.")
            return
        }
        // exporting the video
        exportVideo(export, videoComposition)
    }
    
    fileprivate func exportVideo(_ export: AVAssetExportSession, _ videoComposition: AVMutableVideoComposition) {
        let videoName = UUID().uuidString
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(videoName)
            .appendingPathExtension("mov")
        
        export.videoComposition = videoComposition
        export.outputFileType = .mov
        export.outputURL = exportURL
        
        export.exportAsynchronously {
            DispatchQueue.main.async {
                switch export.status {
                case .completed:
                    let player = AVPlayer(url: exportURL)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.present(playerViewController, animated: true) {
                      player.play()
                    }
                default:
                    print("Something went wrong during export.")
                    print(export.error ?? "unknown error")
                    return
                }
            }
        }
    }
    
    fileprivate func createComposition(videoComposition: AVMutableVideoComposition, duration: CFTimeInterval) {
        print(naturalSize, videoLayer.frame.size, videoLayer.preferredFrameSize(), assetTrack.naturalSize, videoLayer.frame.origin)
        videoComposition.renderSize = videoLayer.preferredFrameSize()
        videoComposition.frameDuration = CMTime(value: 1, timescale: 60)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayers: [videoLayer, overlayLayer], in: combinedLayer)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(
            start: .zero,
            duration: composition.duration)
        videoComposition.instructions = [instruction]
        let layerInstruction = compositionLayerInstruction(
            for: compositionTrack,
            assetTrack: assetTrack)
        instruction.layerInstructions = [layerInstruction]
    }
    
    private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let transform = assetTrack.preferredTransform
        instruction.setTransform(transform, at: .zero)
        return instruction
    }
    
    func addTextButton() {
        let addTextButton = UIButton(type: .system)
        addTextButton.setTitle("Add Text", for: .normal)
        self.view.addSubview(addTextButton)
        addTextButton.translatesAutoresizingMaskIntoConstraints = false
        addTextButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        addTextButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -150).isActive = true
        addTextButton.addTarget(self, action: #selector(addTextOverlay), for: .touchDown)
        addExportButton()
    }
    
    func addExportButton() {
        exportButton.setTitle("Export", for: .normal)
        self.view.addSubview(exportButton)
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        exportButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        exportButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        exportButton.addTarget(self, action: #selector(recordAndExportVideo), for: .touchDown)
    }
    
    @objc func addTextOverlay() {
        // Present my custom alert
        let alert = CustomAlertView(defualtAction: { [self] text in
            textLayer = CATextLayer()
            textLayer.string = text
            textLayer.fontSize = 18
            textLayer.shouldRasterize = true
            textLayer.rasterizationScale = UIScreen.main.scale
            textLayer.backgroundColor = UIColor.clear.cgColor
            textLayer.alignmentMode = .center
            print(textLayer.bounds)
            textLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
            textLayer.alignmentMode = .left
            overlayPreviewLayer.addSublayer(textLayer)
            addMoveLabel()
        }, actionTitle: "Add Overlay", title: "Overlay Text", message: "What text would you like to add as an overlay?")
        self.view.addSubview(alert)
        // centering the view
        alert.translatesAutoresizingMaskIntoConstraints = false
        alert.heightAnchor.constraint(equalToConstant: 300).isActive = true
        alert.widthAnchor.constraint(equalToConstant:  view.frame.width - 60).isActive = true
        alert.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        alert.centerYAnchor.constraint(equalTo: view.superview!.centerYAnchor).isActive = true
    }
    
    func addMoveLabel() {
        let label = UILabel(frame: textLayer.frame)
        label.text = "<-- MOVE -->"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.frame = textLayer.frame
        label.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(moveLabel)))
        label.textColor = .red
        self.view.addSubview(label)
        label.isUserInteractionEnabled = true
        label.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 150).isActive = true
        self.view.bringSubviewToFront(label)
    }
    
    @objc func moveLabel(gesture: UIPanGestureRecognizer) {
        guard gesture.state == .changed else {return}
        let translation = gesture.translation(in: self.view)
        textLayer.frame.origin.x += translation.x - lastTranslation.x
        textLayer.frame.origin.y += translation.y - lastTranslation.y
        lastTranslation = translation
    }

    
    // Code taken from the web for getting orientation of a video
    private func orientation(from transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
      var assetOrientation = UIImage.Orientation.up
      var isPortrait = false
      if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
        assetOrientation = .right
        isPortrait = true
      } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
        assetOrientation = .left
        isPortrait = true
      } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
        assetOrientation = .up
      } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
        assetOrientation = .down
      }
      
      return (assetOrientation, isPortrait)
    }
}
