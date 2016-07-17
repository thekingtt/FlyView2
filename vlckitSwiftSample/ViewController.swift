//
//  ViewController.swift
//  vlckitSwiftSample
//
//  Created by Janis Theuer
//  Copyright © 2016 Janis Theuer. All rights reserved.

//verwendete Libs
import UIKit
import CoreMotion

//Definition der Konstanten und Variablen
var URL = ""
var ZOOM = "4:3"
let MOTION_UPDATE_INTERVAL = 0.1

func getParams() -> [AnyObject]{
    print(#function)
    //let options: NSMutableArray = ["--no-color", "--no-osd", "--no-video-title-show", "--no-stats", "--no-snapshot-preview", "--avcodec-fast", "--text-renderer=freetype", "--avi-index=3", "--extraintf=ios_dialog_provider", "--network-caching=[2000]"]
    //let options : NSMutableArray = ["--network-caching=[250]"]
    let options : NSMutableArray = []
    options.addObject("--marq-x=[10]")
    print(options as [AnyObject])
    return options as [AnyObject]
}

let VLCOptions = getParams()

class ViewController: UIViewController, VLCMediaPlayerDelegate {

    //Outlets
    @IBOutlet var movieView: UIView!
    @IBOutlet var movieView2: UIView!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var motionManagerLabel: UILabel!
    
    //Initialisiere Videoplayer
    var mediaPlayer = VLCMediaPlayer() // .init(options: options as [AnyObject])
    var mediaPlayer2 = VLCMediaPlayer()
    //var test = VLCMediaPlayer(options: <#T##[AnyObject]!#>)
    
    //Initialisiere MotionManager
    let motionManager = CMMotionManager()

    //View wurde geladen
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hinzufügen von Tap-Gesture auf Screen
        let gesture = UITapGestureRecognizer(target: self, action: "canvasTapped:")
        self.view.addGestureRecognizer(gesture)
        
        //Starte MotionManager
        setupMotionManager()
        
        //Lösche Inhalt von Textlabel MotionManager
        motionManagerLabel.text = ""
    }
    
    //View erscheint
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Starte MotionManager
        //motionManager.startDeviceMotionUpdates()
        
        //Lade Streaming Url aus Speicher
        let defaults = NSUserDefaults.standardUserDefaults()
        let myUrl = defaults.objectForKey("streamingUrl") as? String
        if (myUrl != nil){
            URL = myUrl!
            
            //Laden des Videos in UIView
            playVideoStream(mediaPlayer, streamingUrl: URL, correspondingView: movieView, audio: true)
            playVideoStream(mediaPlayer2, streamingUrl: URL, correspondingView: movieView2, audio: false)
        }else{
            print("Stream kann nicht geladen werden!")
            //Gehe zu zweitem ViewController
            performSegueWithIdentifier("settingsSegue", sender: self)
        }
    }
    
    //View verschwindet
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        //Stoppe MotionManager
        //motionManager.stopDeviceMotionUpdates()
    }

    //Laden des Videos in correspondingView, audio = false --> Kein Ton
    func playVideoStream(player : VLCMediaPlayer, streamingUrl : String, correspondingView: UIView, audio : Bool){
        
        //Laden der URL für Webstream
        let url = NSURL(string: streamingUrl)
        let media = VLCMedia(URL: url)
       
        //Setze mediaPlayer-Properties und starte Video
        player.setMedia(media)
        player.setDelegate(self)
        player.drawable = correspondingView
        
        //Setze Bildschirmverhältnis (aspectRatio)
        let aspectRatio = "16:9"
        let cs = (aspectRatio as NSString).UTF8String
        let buffer = UnsafeMutablePointer<Int8>(cs)
        player.setVideoAspectRatio(buffer)
        
        //Beschneide Video für Zoom
        let cropGeometry = ZOOM
        let cs2 = (cropGeometry as NSString).UTF8String
        let buffer2 = UnsafeMutablePointer<Int8>(cs2)
        player.setVideoCropGeometry(buffer2)
        
        //Deaktivieren des AudioStreams
        if audio == false {
            player.setAudioChannel(0)
        }
        
        //Wiedergabe des Streams
        player.play()
    }


    //Bildschirm wird gedrückt
    func canvasTapped(sender: UITapGestureRecognizer) {
        print(#function)
        
        //Einblenden/Verstecken des Settings-Button
        settingsButton.hidden = !settingsButton.hidden
    }
    
    @IBAction func settingsButtonPressed(sender: UIButton) {
        print(#function)
        
        //Stoppe Videowiedergabe
        mediaPlayer.stop()
        mediaPlayer2.stop()
        
        //Gehe zu zweitem ViewController
        performSegueWithIdentifier("settingsSegue", sender: self)
    }
    
    //Actions
    //MotionManager
    func setupMotionManager(){
        //Wenn CoreMotion vorhanden ist
        if motionManager.deviceMotionAvailable{
            
            //Update Intervall
            motionManager.deviceMotionUpdateInterval = MOTION_UPDATE_INTERVAL
            
            //Start Updates
            motionManager.startDeviceMotionUpdatesToQueue(
                NSOperationQueue.currentQueue()!, withHandler: {
                    (deviceMotion, error) -> Void in
                    
                    if(error == nil) {
                        self.handleDeviceMotionUpdate(deviceMotion!)
                        
                    } else
                    {
                        //Error-Handling
                        print("MotionManager Fehler")
                    }
            })
        }
    }
    
    //HandleDeviceMotion Updates
    func handleDeviceMotionUpdate(deviceMotion:CMDeviceMotion) {
        let attitude = deviceMotion.attitude
        let roll = degrees(attitude.roll)
        let pitch = degrees(attitude.pitch)
        let yaw = degrees(attitude.yaw)
        //print("Neigen: \(roll), Kippen: \(pitch), Schwenken: \(yaw)")
        motionManagerLabel.text = "Neigen: \(roll.roundToPlaces(1)) Schwenken: \(yaw.roundToPlaces(1))"
        
        //TODO
        //Sende Winkel an Kamera
    }
    
    //Rad to Degree
    func degrees(radians:Double) -> Double {
        return 180 / M_PI * radians
    }
}

//Runde Double-Werte auf Fixe Nachkommastellen
extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}

