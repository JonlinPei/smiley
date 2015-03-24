//
//  ViewController.swift
//  smiley
//
//  Created by Joseph Anderson on 2/17/15.
//  Copyright (c) 2015 ifd. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var trayArrow: UIImageView!
    @IBOutlet weak var tray: UIView!
    var trayStartingY: CGFloat!
    var trayStartingYPanBegan: CGFloat!
    var finalTrayPositionY: CGFloat!
    var trayRotation: CGFloat! //Tray arrow
    var temporarySmiley: UIImageView!
    var nonTraySmileyCenter: CGPoint!
    var originalSmileyCenter: CGPoint!
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var pinchGestureRecognizer: UIPinchGestureRecognizer!
    var rotateGestureRecognizer: UIRotationGestureRecognizer!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        trayStartingY = tray.frame.origin.y
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didPanNonTraySmiley:")
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "didPinchNonTraySmiley:")
        rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: "didRotateNonTraySmiley:")
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTap:")
        
        panGestureRecognizer.delegate = self
        pinchGestureRecognizer.delegate = self
        rotateGestureRecognizer.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didPanTray(sender: UIPanGestureRecognizer) {
        var location = sender.locationInView(view)
        var translation = sender.translationInView(view)
        var velocity = sender.velocityInView(view)

        if (sender.state == UIGestureRecognizerState.Began){
            trayStartingYPanBegan = tray.frame.origin.y
        } else if (sender.state == UIGestureRecognizerState.Changed){
            finalTrayPositionY = trayStartingYPanBegan + translation.y
            if (finalTrayPositionY < trayStartingY){
                finalTrayPositionY = trayStartingYPanBegan + translation.y/10
            }
            tray.frame.origin.y = finalTrayPositionY
        } else if sender.state == UIGestureRecognizerState.Ended {
            if (velocity.y > 0){
                finalTrayPositionY = 530
                trayRotation = CGFloat(-180.0 * M_PI/180)
            } else {
                finalTrayPositionY = trayStartingY
                trayRotation = CGFloat(0 * M_PI/180)
            }
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 30, options: nil, animations: { () -> Void in
                self.tray.frame.origin.y = self.finalTrayPositionY
                self.trayArrow.transform = CGAffineTransformMakeRotation(self.trayRotation)
            }, completion: nil)
            
        }
    }
    
    
    @IBAction func didPanSmiley(sender: UIPanGestureRecognizer) {
        var location = sender.locationInView(view)
        
        
        if (sender.state == UIGestureRecognizerState.Began){
            // Check if we are in the tray zone
            var imageView = sender.view as UIImageView
            originalSmileyCenter = CGPoint(x: imageView.center.x, y: imageView.center.y + trayStartingY)
            //creating an imageview programatically
            var frame = CGRectMake(0, 0, 50, 50)
            temporarySmiley = UIImageView(frame: frame)
            temporarySmiley.image = imageView.image
            temporarySmiley.center = originalSmileyCenter
            view.addSubview(temporarySmiley)
            temporarySmiley.userInteractionEnabled = true
            
            temporarySmiley.addGestureRecognizer(panGestureRecognizer)
            temporarySmiley.addGestureRecognizer(pinchGestureRecognizer)
            temporarySmiley.addGestureRecognizer(rotateGestureRecognizer)
            
            println("tapped temporary smiley")

            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.temporarySmiley.transform = CGAffineTransformMakeScale(2, 2)
            })
        } else if (sender.state == UIGestureRecognizerState.Changed){
            temporarySmiley.center = location
        } else if sender.state == UIGestureRecognizerState.Ended {
            // If temporary Smiley is still in tray location animate it back to originalSmileyCenter
            if (temporarySmiley.center.y > trayStartingY){
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    //Move back to initial
                    self.temporarySmiley.center = self.originalSmileyCenter
                    }, completion: { (finished: Bool) -> Void in
                    self.temporarySmiley.removeFromSuperview()
                })
            }
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.temporarySmiley.transform = CGAffineTransformMakeScale(1, 1)
            })
        }
    }
    
    func didPanNonTraySmiley(sender: UIPanGestureRecognizer) {
        var location = sender.locationInView(view)
        var translation = sender.translationInView(view)
        if (sender.state == UIGestureRecognizerState.Began){
            nonTraySmileyCenter = sender.view!.center
        } else if (sender.state == UIGestureRecognizerState.Changed){
            sender.view!.center = CGPoint(x: nonTraySmileyCenter.x + translation.x, y: nonTraySmileyCenter.y + translation.y)
        } else if sender.state == UIGestureRecognizerState.Ended {
            
        }
    }
    
    func didPinchNonTraySmiley(sender: UIPinchGestureRecognizer){
        var scale = sender.scale * 0.8
        var smiley = sender.view!
        smiley.transform = CGAffineTransformScale(smiley.transform, scale, scale)
    }
    
    func didRotateNonTraySmiley(sender: UIRotationGestureRecognizer){
        var rotation = sender.rotation
        var smiley = sender.view!
        smiley.transform = CGAffineTransformRotate(smiley.transform, rotation)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

