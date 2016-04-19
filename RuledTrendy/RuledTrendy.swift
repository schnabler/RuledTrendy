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
    
    private enum Error: String {
        case URLError = "Invalid URL."
        case TaskError = "Data task failed."
        case DataError = "Could not get data."
        case ImageError = "Could not get image."
    }
    
    private var retryCount = 0
    
    private lazy var timer = NSTimer()
    private var content: UIImage? {
        didSet {
            debugMessage("Image set, starting timer")
            startTimer()
        }
    }
    public var duration: Double = 0.005
    
    //This sets up the class with a String. The key represents a base64 encoded URL that points to your ressource.
    public convenience init(key: String, frequency: Frequency) {
        self.init()
        self.key = key.decodeBase64()
        self.frequency = frequency
        downloadContent()
        debugMessage("Class initiated")
    }
    
    //The image is assigned here and the timer is started in the didSet observer of the content property.
    private func setContent(image: UIImage){
        self.content = image
    }
    
    //This initiates the donwload of the image. If it fails, it will try again 9 more times and fail silently in case we could not get an image after 10 attempts. In case of an URL error, we fail immediately.
    private func downloadContent() {
        debugMessage("Trying download")
        guard retryCount <= 10 else {
            debugMessage("Failed 10 times, aborting.")
            return
        }
        retryCount = retryCount + 1
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.startDonwload({ (error) in
                guard let error = error else {
                    return
                }
                self.downloadContent()
                self.debugMessage(error.rawValue)
            })
        }
    }
    
    private func debugMessage(message: String) {
        if self.frequency == .Debug {
            print("\(message)")
        }
    }
    
    //Download the image using NSURLSession with a default configuration
    private func startDonwload(completion: (error: Error?)->()){
        debugMessage("Starting Download")
        guard let url = NSURL(string: self.key) else {
            completion(error: .URLError)
            return
        }
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil else {
                completion(error: .TaskError)
                return
            }
            guard let data = data else {
                completion(error: .DataError)
                return
            }
            
            guard let contentImage = UIImage(data: data) else {
                completion(error: .ImageError)
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.setContent(contentImage)
                completion(error: nil)
            }
        }
        task.resume()
    }
    
    //Once the image has downloaded, the timer starts running with a (repeating) interval of 1.0
    private func startTimer(){
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(RuledTrendy.showImage), userInfo: nil, repeats: true)
    }
    
    //Each second, we generate a random number from 0 to the specified frequency (-1). If this number is 1, we show the image for 0.01 seconds.
    @objc private func showImage(){
        if arc4random_uniform(frequency.rawValue) == 1 {
            let window = UIApplication.sharedApplication().keyWindow
            
            let width = UIScreen.mainScreen().bounds.width
            let height = UIScreen.mainScreen().bounds.height
            
            let contentView = UIImageView(frame: CGRectMake(0, 0, width, height))
            contentView.image = content
            contentView.contentMode = .ScaleAspectFill
            window?.addSubview(contentView)
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC))
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
