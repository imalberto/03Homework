//
//  HeadlineViewController.swift
//  03Homework-beta
//
//  Created by albertoc on 6/20/14.
//  Copyright (c) 2014 AC. All rights reserved.
//

import UIKit

class HeadlineViewController: UIViewController {

  @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer
  @IBOutlet var headlineImageView: UIImageView
  
  @IBAction func onPan(sender: UIPanGestureRecognizer) {
    NSLog("Panning ...")
    
    var frame:CGRect = self.headlineImageView.frame;
    
    // Need to move it down (y) as we keep panning
    
    let location = sender.locationInView(self.view)
    let translation = sender.translationInView(self.view)
    
    var newFrame = CGRectMake(frame.origin.x,
                              translation.y,
                              frame.size.width,
                              frame.size.height)
    
    self.headlineImageView.frame = newFrame;
    
    NSLog("%@", NSStringFromCGPoint(location))
    NSLog("%@", NSStringFromCGPoint(translation))
  }
  

  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    // Custom initialization
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.clearColor()
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
