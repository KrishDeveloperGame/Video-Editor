//
//  AnimatableTextLayer.swift
//  Video Editor
//
//  Created by Krish Shah on 20/05/21.
//

import UIKit

func animateText(subtitles:String,duration:Double,animationSpacing:Double,textLayer:CATextLayer){
    var currentTime : Double = 0
    for x in subtitles {
        textLayer.string = "\(x)"
        let anim = getSubtitlesAnimation(duration: duration, startTime: currentTime)
        textLayer.add(anim, forKey: "opacityLayer\(x)")
        currentTime += duration + animationSpacing
    }
}

func getSubtitlesAnimation(duration: CFTimeInterval,startTime:Double)->CAKeyframeAnimation {
    let animation = CAKeyframeAnimation(keyPath:"opacity")
    animation.duration = duration
    animation.calculationMode = .discrete
    animation.values = [0,1,1,0,0]
    animation.keyTimes = [0,0.00000001,0.999,0.999995,1]
    animation.isRemovedOnCompletion = false
    animation.fillMode = .both
    animation.beginTime = AVCoreAnimationBeginTimeAtZero + startTime // CACurrentMediaTime() <- NO AV Foundation
    return animation
}

//let steps = 0.25
//let duration = 8.0
//let textFrame = CGRect( x: (videoSize.width / 2) - (90 / 2) , y: videoSize.height * 0.2, width: 90, height: 50)
//
//var subtitles:[String] = []
//func a(){
//for i in 0...Int(duration / steps) {
//    let time = i > 0 ? steps * Double(i) : Double(i)
//    subtitles.append(String(format: "%0.1f", time) )
//}
//}

//animateText(subtitles: subtitles, duration: steps, animationSpacing: 0, frame: textFrame, targetLayer: layer)

