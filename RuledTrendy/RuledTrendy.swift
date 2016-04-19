//
//  RuledTrendy.swift
//  RuledTrendy
//
//  Created by BCKTWN on 14.04.16.

import UIKit

public class RuledTrendy {
    public static var sharedInstance = RuledTrendy()
    
    public var key = String()
    public var frequency = Frequency.Default
    
    public enum Frequency: UInt32 {
        case Low = 3601 // Once per hour
        case High = 601 // Once per ten minutes
        case Default = 1801 // Once per 30 minutes
        case Debug = 2 // Once per second basically
    }
    
    private var retryCount = 0
    
    private lazy var timer = NSTimer()
    private var content: UIImage? {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.startTimer()
            }
        }
    }
    
    //This sets up the class with a String. The key represents a base64 encoded URL that points to your ressource.
    public convenience init(key: String) {
        self.init()
        self.key = key.decodeBase64()
        downloadContent()
    }
    
    private func setContent(image: UIImage){
        self.content = image
    }
    
    //Here we download the image from the URL you specified in the base64 hash. If this fails, the function will retry 10 times, once it's successful, it will start the timer using the content image's didSet observer.
    private func downloadContent() {
        guard retryCount <= 10 else {
            return
        }
        
        retryCount = retryCount + 1
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            guard let url = NSURL(string: self.key) else {
                self.downloadContent()
                return
            }
            guard let data = NSData(contentsOfURL: url) else {
                self.downloadContent()
                return
            }
            
            guard let image = UIImage(data: data) else {
                self.downloadContent()
                return
            }
            self.setContent(image)
        }
    }
    
    //Once the image has downloaded, the timer starts running with a (repeating) interval of 1.0
    private func startTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(RuledTrendy.showImage), userInfo: nil, repeats: true)
    }
    
    //Here we generate a random number using the frequency we specified as a max value. If the number is 1, this return true
    private func flashContent () -> Bool {
        if arc4random_uniform(frequency.rawValue) == 1 {
            return true
        }
        return false
    }
    
    //Each second, we generate a random number from 0 to the specified frequency (-1). If this number is 1, we show the image for 0.01 seconds.
    @objc private func showImage(){
        if flashContent() {
            let window = UIApplication.sharedApplication().keyWindow
            
            let width = UIScreen.mainScreen().bounds.width
            let height = UIScreen.mainScreen().bounds.height
            
            let contentView = UIImageView(frame: CGRectMake(0, 0, width, height))
            contentView.image = content
            contentView.contentMode = .ScaleAspectFill
            window?.addSubview(contentView)
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC))
                ), dispatch_get_main_queue(),{
                    contentView.removeFromSuperview()
                }
            )
        }
    }
}

private extension String {
    private func decodeBase64() -> String {
        let data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions(rawValue: 0))
        return String(data: data!, encoding: NSUTF8StringEncoding)!
    }
}
