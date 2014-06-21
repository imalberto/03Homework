//
//  HeadlineViewController.swift
//  03Homework-beta
//
//  Created by albertoc on 6/20/14.
//  Copyright (c) 2014 AC. All rights reserved.
//

import UIKit

class HeadlineViewController: UIViewController {

  var startHeadlineImageViewFrame:CGRect!

  @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer
  @IBOutlet var headlineImageView: UIImageView
  
  @IBAction func onPan(sender: UIPanGestureRecognizer) {
//    NSLog("Panning ...")
    
    
    
    
    var frame:CGRect = self.headlineImageView.frame
    var newFrame: CGRect!
    
    // Need to move it down (y) as we keep panning
    

    let location = sender.locationInView(self.view)
    let translation = sender.translationInView(self.view)

    // let's detect if user is dragging outside of the headlineImageView
    let inView = sender.locationInView(self.headlineImageView)
    NSLog("inView = %@", NSStringFromCGPoint(inView))
    // Not sure why < 0.0 does not work, seems there is a buffer
    if inView.y < -10.0 {
      // then we outside the headlineImageView
      return
    }
    
    switch (sender.state) {
    case .Began:
//      NSLog(".Began")
      self.startHeadlineImageViewFrame = frame

    case .Ended:
//      NSLog(".Ended")
      let y_offset:CGFloat = 20.0
      let y_visible:CGFloat = 44.0

      var y_delta:CGFloat = translation.y
      // var options:UIViewAnimationOptions = UIViewAnimationOptions.fromRaw(animCurve.toRaw().asUnsigned())!
      var options:UIViewAnimationOptions = UIViewAnimationOptions.CurveEaseOut

      if y_delta < 0 {
        y_delta *= -1
      }
      // First, let's determine if we were dragging up or down
      if (translation.y > 0) {
        // moving down

        if y_delta >= y_offset {
          UIView.animateWithDuration(0.35, delay: 0.0, options: options, animations: {
            newFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height - y_visible, self.view.frame.size.width, self.view.frame.size.height)
            self.headlineImageView.frame = newFrame
            }, completion: { (Bool) -> Void in
              NSLog("done")
              // the final position should be where we start next
              self.startHeadlineImageViewFrame = self.headlineImageView.frame
            })
        } else {
          UIView.animateWithDuration(0.35, delay: 0.0, options: options, animations: {
            
            self.headlineImageView.frame = self.startHeadlineImageViewFrame
            }, completion: { (Bool) -> Void in
              NSLog("done")
              // the final position should be where we start next
              self.startHeadlineImageViewFrame = self.headlineImageView.frame
            })

        }
        
      } else if translation.y < 0 {
        // moving up
        // User would have to move up a bit more to start the animation up
        if y_delta >= (y_offset / 2.0) {
          UIView.animateWithDuration(0.35, delay: 0.0, options: options, animations: {
            newFrame = CGRectMake(self.view.frame.origin.x, 0.0, self.view.frame.size.width, self.view.frame.size.height)
            self.headlineImageView.frame = newFrame
            }, completion: { (Bool) -> Void in
              NSLog("done")
              // the final position should be where we start next
              self.startHeadlineImageViewFrame = self.headlineImageView.frame
            })
        } else {
          UIView.animateWithDuration(0.35, delay: 0.0, options: options, animations: {
            
            self.headlineImageView.frame = self.startHeadlineImageViewFrame
            }, completion: { (Bool) -> Void in
              NSLog("done")
              // the final position should be where we start next
              self.startHeadlineImageViewFrame = self.headlineImageView.frame
            })
        }

      } else {
        NSLog("NO OP")
        
      }



      
    case .Changed:
//      NSLog(".Changed")
      // Move the headlines with the same distance as the finger is dragging
      newFrame = CGRectMake(frame.origin.x,
        self.startHeadlineImageViewFrame.origin.y + translation.y,
        frame.size.width,
        frame.size.height)
      
      self.headlineImageView.frame = newFrame;
    default:
      NSLog("unhandled state")
    }
    

    
//    NSLog("%@", NSStringFromCGPoint(location))
//    NSLog("%@", NSStringFromCGPoint(translation))
  }
  

  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    // Custom initialization
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.clearColor()
    self.view.layer.cornerRadius = 5.0
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  /*
  // #pragma mark - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
  }
  */

}
