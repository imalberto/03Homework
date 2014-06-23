//
//  HeadlineViewController.swift
//  03Homework-beta
//
//  Created by albertoc on 6/20/14.
//  Copyright (c) 2014 AC. All rights reserved.
//

import UIKit

class HeadlineViewController: UIViewController, UIGestureRecognizerDelegate {

  var originalTransform: CGAffineTransform!
  
  var images:String[] = ["headline10", "headline11"]
  var imageIndex: Int = 0
  var timer: NSTimer! = nil
  var invView:UIView!

  // Once the view is loaded, calculate the increment value that
  // the opacity should be changed in order to go from 0->1, or 1->0 based
  // on the height of self.view
  var opacityIncrement: CGFloat!
  
  // Keep state of the headlineView starting position.
  // These two variables should be updated in sync.
  var startContainerViewFrame:CGRect! // only top or bottom
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
  @IBOutlet var newsFeedScrollView: UIScrollView
  @IBOutlet var containerView: UIView
  @IBOutlet var newsFeedImageView: UIImageView
  @IBOutlet var newsFeedPanGestureRecognizer: UIPanGestureRecognizer

  // Tap recognizer on the HeadlineImageView
  @IBAction func onTap(sender: UITapGestureRecognizer) {
    // NSLog("onTap")
    
    if self.timer == nil {
      timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "updateHeadlines", userInfo: nil, repeats: true)
      NSLog("timer started")
    } else {
      timer.invalidate()
      timer = nil
      NSLog("timer stopped")
    }
    // self.imageIndex = (self.imageIndex + 1) % 2
    // self.updateHeadlines()
  }

  // Pan recognizer on the HeadlineImageView
  @IBAction func onPan(sender: UIPanGestureRecognizer) {

    var frame:CGRect = self.containerView.frame
    var newFrame: CGRect!

    // Restore to original position
    func restoreWithOptions(options: UIViewAnimationOptions) {
      UIView.animateWithDuration(0.35, delay: 0.0, options: options, animations: {
            self.containerView.frame = self.startContainerViewFrame
        }, completion: { (Bool) -> Void in
            if self.startHeadlineTopPosition {
              self.invView.layer.opacity = 1.0
            } else {
              self.invView.layer.opacity = 0.0
            }
        })
    }



    let location = sender.locationInView(self.containerView)
    let translation = sender.translationInView(self.containerView)
    let velocity = sender.velocityInView(self.containerView)


    // detect if user is dragging outside of the headlineImageView and ignore
    let inView = sender.locationInView(self.containerView)

    // NSLog("location = %@", NSStringFromCGPoint(location)) // where the touch is
    // NSLog("%@", NSStringFromCGPoint(translation))
    // NSLog("inView = %@", NSStringFromCGPoint(inView))

    switch (sender.state) {
    case .Began:
      self.startContainerViewFrame = frame

      // NSLog("[begin] translation.y = %f, velocity.y = %f", translation.y, velocity.y)
      self.draggingDown = false
      if velocity.y > 0.0 {
        self.draggingDown = true
      }
      // self.draggingDown == true ? NSLog("[begin] dragging DOWN") : NSLog("[begin] dragging UP")
      
      // Store current velocity to decide if user changed the panning direction
      // in .Changed
      self.lastKnownVelocity = velocity

    case .Changed:

      NSLog("[changed] velocity = %@", NSStringFromCGPoint(velocity))
      
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
      
      // self.draggingDown == true ? NSLog("[begin] dragging DOWN") : NSLog("[begin] dragging UP")

      // Increase drag force if necessary
      if (frame.origin.y < 0.0) {
        newFrame = CGRectMake(frame.origin.x,
          (self.startContainerViewFrame.origin.y + translation.y) / 10.0,
          frame.size.width,
          frame.size.height)
        
      } else {
        // Move the headlines with the same distance as the finger is dragging
        newFrame = CGRectMake(frame.origin.x,
          self.startContainerViewFrame.origin.y + translation.y,
          frame.size.width,
          frame.size.height)
      }
      self.containerView.frame = newFrame

      // Animate alpha as user is dragging (in points)
      let incOpacity: Float = 1.0 / 60.0

      // TODO more sophistication is required here
      if velocity.y > 0 {
        if (self.invView.layer.opacity - incOpacity) > 0.0 {
          self.invView.layer.opacity -= incOpacity
        }
      } else {
        if (self.invView.layer.opacity + incOpacity) < 1.0 {
          self.invView.layer.opacity += incOpacity
        }
      }
      // NSLog("invView.layer.opacity = %f", self.invView.layer.opacity)
      
    case .Ended:

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
      let y_offset:CGFloat = 3.0
      // How much gap to leave after the animation complete when dragging down
      let y_visible:CGFloat = 54.0
      var y_delta:CGFloat = velocity.y
      var options:UIViewAnimationOptions = UIViewAnimationOptions.CurveEaseOut

      if y_delta < 0 {
        y_delta *= -1
      }
      // First, let's determine if we were dragging up or down
      if (velocity.y > 0) {
        // moving down
        if y_delta >= y_offset {
          UIView.animateWithDuration(0.35, delay: 0.0, options: options, animations: {
              newFrame = CGRectMake(frame.origin.x,
                                self.view.frame.size.height - y_visible,
                                frame.size.width,
                                frame.size.height)
              self.containerView.frame = newFrame
              self.invView.layer.opacity = 0.0
            }, completion: { (Bool) -> Void in
              // NSLog("done")
              self.startContainerViewFrame = newFrame
              self.startHeadlineTopPosition = false
            })
        } else {
          restoreWithOptions(options)
        }
      } else if velocity.y < 0 {
        // moving up
        // User would have to move up a bit more to start the animation up
        if y_delta >= (y_offset / 2.0) {
          UIView.animateWithDuration(0.35, delay: 0.0, options: options, animations: {
              newFrame = CGRectMake(frame.origin.x, 0.0, frame.size.width, frame.size.height)
              self.containerView.frame = newFrame
              self.invView.layer.opacity = 1.0
            }, completion: { (Bool) -> Void in
              // NSLog("done")
              self.startContainerViewFrame = newFrame
              self.startHeadlineTopPosition = true
            })
        } else {
          restoreWithOptions(options)
        }
      } else {
        NSLog("NO OP")
      }

    case .Cancelled:
      let xx = 1.0

    default:
      let xx = 1.0
    }

  }

  // Pan recognizer on the NewsFeedImageView
  @IBAction func onPanNewsFeed(sender: UIPanGestureRecognizer) {
    
    let translation = sender.translationInView(self.newsFeedImageView)
    let velocity = sender.velocityInView(self.newsFeedImageView)
    var baseScale = 1.0
    var transform: CGAffineTransform!
    var scale:CGFloat = 1.0
    var scalex: CGFloat!
    var scaley: CGFloat!

    if abs(translation.y) >  abs(translation.x) {
      switch (sender.state) {
      // case .Ended:
      case .Began:
        self.originalTransform = self.newsFeedScrollView.transform
        scale = self.originalTransform.tx
        NSLog("[begin] scale = %f", scale)
      case .Changed:

        // NSLog("pan newsfeed")
        
        scalex = self.newsFeedImageView.transform.tx
        scaley = self.newsFeedImageView.transform.ty
        // NSLog("scalex = %f, scaley = %f", scalex, scaley)

        // NSLog("translation = %@", NSStringFromCGPoint(translation))
        // NSLog("velocity = %@", NSStringFromCGPoint(velocity))

        if velocity.y > 0.0 {
          if scale > 1.0 {
            // reduce
            NSLog("PRE scale = %f", scale)
            scale = scale - abs(translation.y) / 160.0
            NSLog("POST scale = %f", scale)
          }
        } else {
          if scale >= 1.0 {
            // increase
            scale = 1.0 + abs(translation.y) / 160.0
            // transform = CGAffineTransformMakeScale(1.1, 1.1)
          }
        }
        NSLog("scale = %f", scale)
        // transform = CGAffineTransformScale(self.originalTransform, scale, scale)
        // self.newsFeedScrollView.transform = transform
      default:
        NSLog("-")
      }
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

    self.containerView.backgroundColor = UIColor.clearColor()
    self.headlineImageView.backgroundColor = UIColor.clearColor()
    self.headlineImageView.layer.cornerRadius = 5.0
    self.headlineImageView.layer.masksToBounds = true
    
    // Add a view behind the container view that changes alpa
    self.invView = UIView(frame: self.view.bounds)
    self.invView.backgroundColor = UIColor.blackColor()
    self.invView.layer.opacity = 1.0
    self.view.insertSubview(self.invView, belowSubview: self.containerView)
    

    // Compute the amount that opacity of the background should change
    // as the headlineView is dragged
    self.opacityIncrement = (1.0 / self.view.frame.height)
    
    // add the newsfeed image view to the scrollview
    self.newsFeedScrollView.scrollsToTop = false
    self.newsFeedScrollView.backgroundColor = UIColor.clearColor()
    self.newsFeedScrollView.directionalLockEnabled = true
    self.newsFeedScrollView.alwaysBounceVertical = false

    self.newsFeedPanGestureRecognizer.delegate = self
    self.newsFeedImageView.image = UIImage(named: "news")
    self.newsFeedImageView.sizeThatFits(self.newsFeedImageView.image.size)
    self.newsFeedImageView.frame = CGRectMake(0, 0, self.newsFeedImageView.image.size.width, self.newsFeedImageView.image.size.height)
    // NSLog("Image size: %@", NSStringFromCGSize(self.newsFeedImageView.image.size))
    // NSLog("Image frame: %@", NSStringFromCGRect(self.newsFeedImageView.frame))
    
    self.newsFeedScrollView.addSubview(self.newsFeedImageView)
    self.newsFeedScrollView.contentSize = self.newsFeedImageView.image.size
    
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
  
  func updateHeadlines() {

    self.imageIndex = (self.imageIndex + 1) % 2
    let toImage = UIImage(named:self.images[self.imageIndex])

    UIView.transitionWithView(self.headlineImageView, duration: 0.7, options: .TransitionCrossDissolve, animations: {
            self.headlineImageView.image = toImage
        }, completion: { (Bool) -> Void in
            // NSLog("transition done")
        })
  }
  
  // @optional func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool {
    var result = false
    let re: UIPanGestureRecognizer = gestureRecognizer as UIPanGestureRecognizer
    let trans = re.translationInView(self.newsFeedImageView)
    // Only recoginize both gestures when moving "horizontal"
    // Filter for only "vertical" movement in ur gestureRecognizer
    if abs(trans.x) >  abs(trans.y) {
      result = true
    }
    // result == true ? NSLog("recog") : NSLog("no recog")
    return result
    
  }
  // @optional func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool


}
