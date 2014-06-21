//
//  HeadlineViewController.swift
//  03Homework-beta
//
//  Created by albertoc on 6/20/14.
//  Copyright (c) 2014 AC. All rights reserved.
//

import UIKit

class HeadlineViewController: UIViewController {

  // Once the view is loaded, calculate the increment value that
  // the opacity should be changed in order to go from 0->1, or 1->0 based
  // on the height of self.view
  var opacityIncrement: CGFloat!
  
  // Keep state of the headlineView starting position.
  // These two variables should be updated in sync.
  var startHeadlineImageViewFrame:CGRect! // only top or bottom
  var startHeadlineTopPosition: Bool = true

  // Keep state of which direction the drag is happening to handle the
  // following use cases:
  // 1. If start from the top, and last know drag was up, restore
  // 2. If start from the bottom, and last known drag was down, restore
  var lastKnownVelocity:CGPoint = CGPointMake(0, 0)
  // TODO why init with false ?
  var draggingDown: Bool!

  @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer
  @IBOutlet var headlineImageView: UIImageView

  @IBAction func onPan(sender: UIPanGestureRecognizer) {
    // NSLog("Panning ...")

    // restore to original position
    func restoreWithOptions(options: UIViewAnimationOptions) {
      UIView.animateWithDuration(0.35, delay: 0.0, options: options, animations: {
        self.headlineImageView.frame = self.startHeadlineImageViewFrame
        }, completion: { (Bool) -> Void in
          // NSLog("done restoring view")
          // self.startHeadlineImageViewFrame did not change, so no need to
          // udpate
          if self.startHeadlineTopPosition {
            // NSLog("Restored to top position")
          } else {
            // NSLog("Restored to bottom position")
          }
        })
    }


    var frame:CGRect = self.headlineImageView.frame
    var newFrame: CGRect!

    // Need to move it down (y) as we keep panning


    let location = sender.locationInView(self.view)
    let translation = sender.translationInView(self.view)
    let velocity = sender.velocityInView(self.view)

    // NSLog("%@", NSStringFromCGPoint(location))
    // NSLog("%@", NSStringFromCGPoint(translation))

    // detect if user is dragging outside of the headlineImageView and ignore
    let inView = sender.locationInView(self.headlineImageView)
    // NSLog("inView = %@", NSStringFromCGPoint(inView))
    // Not sure why < 0.0 does not work, seems there is a buffer
    if inView.y < -10.0 {
      NSLog("User dragging outside of the headlineView")
      return
    }

    switch (sender.state) {
    case .Began:
      // NSLog(".Began")

      self.startHeadlineImageViewFrame = frame
      
      // figure out which direction we are moving initially
      NSLog("[begin] translation.y = %f, velocity.y = %f", translation.y, velocity.y)
      // if translation.y > 0.0 {
      if velocity.y > 0.0 {
        self.draggingDown = true
      } else {
        self.draggingDown = false
      }
      if self.draggingDown == true {
        NSLog("[begin] dragging DOWN")
      } else {
        NSLog("[begin] dragging UP")
      }

      // Need to store our current velocity so that we can make the correct
      // decision in .Changed as to which direction we are moving
      self.lastKnownVelocity = velocity

    case .Changed:
      // NSLog(".Changed")

      // Track which direction user is dragging
      if self.startHeadlineTopPosition == true && self.lastKnownVelocity.x == 0 && self.lastKnownVelocity.y == 0 {
        // keep the current self.draggingDown
      } else {
        if velocity.x * lastKnownVelocity.x + velocity.y * lastKnownVelocity.y > 0.0 {
          // NSLog("Same direction")
        } else {
          // NSLog("Reverse direction")
          self.draggingDown = !self.draggingDown
        }
        lastKnownVelocity = velocity;
      }
      if self.draggingDown == true {
        NSLog("[changed] dragging DOWN")
      } else {
        NSLog("[changed] dragging UP")
      }


      // Should the friction be increased ?
      if (frame.origin.y < 0.0) {
        // increase friction
        // newFrame = frame
        newFrame = CGRectMake(frame.origin.x,
          (self.startHeadlineImageViewFrame.origin.y + translation.y) / 10.0,
          frame.size.width,
          frame.size.height)
        
      } else {
        // Move the headlines with the same distance as the finger is dragging
        newFrame = CGRectMake(frame.origin.x,
          self.startHeadlineImageViewFrame.origin.y + translation.y,
          frame.size.width,
          frame.size.height)
      }
      self.headlineImageView.frame = newFrame;
      
      // As the view is being dragged, change the self.view opacity
      /*
      if self.draggingDown {
        self.view.layer.opacity -= self.opacityIncrement;
      } else {
        self.view.layer.opacity += self.opacityIncrement;
      }
      */

    case .Ended:
      // NSLog(".Ended")

      // Depending on the starting position, and the last known dragging
      // direction, decide if headlineView should be restored ?
      if self.startHeadlineTopPosition && !self.draggingDown {
        // NSLog("restore top position")
        restoreWithOptions(UIViewAnimationOptions.CurveEaseOut)
        return
      }
      if !self.startHeadlineTopPosition && self.draggingDown {
        // NSLog("restore bottom position")
        restoreWithOptions(UIViewAnimationOptions.CurveEaseOut)
        return
      }

      // How much vertical movement before we start animation
      let y_offset:CGFloat = 5.0 // TODO adjust this dependening
      // How much gap to leave after the animation complete when dragging down
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
            newFrame = CGRectMake(frame.origin.x, self.view.frame.size.height - y_visible, frame.size.width, frame.size.height)
            self.headlineImageView.frame = newFrame
            }, completion: { (Bool) -> Void in
              // NSLog("done")
              self.startHeadlineImageViewFrame = newFrame
              self.startHeadlineTopPosition = false
            })
        } else {
          restoreWithOptions(options)
        }
      } else if translation.y < 0 {
        // moving up
        // User would have to move up a bit more to start the animation up
        if y_delta >= (y_offset / 2.0) {
          UIView.animateWithDuration(0.35, delay: 0.0, options: options, animations: {
            newFrame = CGRectMake(frame.origin.x, 0.0, frame.size.width, frame.size.height)
            self.headlineImageView.frame = newFrame
            }, completion: { (Bool) -> Void in
              // NSLog("done")
              self.startHeadlineImageViewFrame = newFrame
              self.startHeadlineTopPosition = true
            })
        } else {
          restoreWithOptions(options)
        }
      } else {
        NSLog("NO OP")
      }

    case .Cancelled:
      NSLog("NO OP - .Cancelled")

    default:
      NSLog("unhandled state")
    }

  }

  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    // Custom initialization
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.clearColor()
    // self.view.layer.opacity = 1.0
    // self.view.backgroundColor = UIColor.blackColor()
    self.view.layer.cornerRadius = 5.0
    self.headlineImageView.backgroundColor = UIColor.clearColor()
    
    self.opacityIncrement = (1.0 / self.view.frame.height)
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
