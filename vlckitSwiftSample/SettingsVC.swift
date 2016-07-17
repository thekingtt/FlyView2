//
//  SettingsVC.swift
//  vlckitSwiftSample
//
//  Created by Janis Theuer on 4.6.16.
//

import UIKit

class SettingsVC: UIViewController, UITextFieldDelegate {
   
    //Outlets
    @IBOutlet var streamingTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        streamingTextfield.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Lade StreamingUrl aus persistentem Speicher
        let defaults = NSUserDefaults.standardUserDefaults()
        let myUrl = defaults.objectForKey("streamingUrl") as? String
        if myUrl != nil {
            URL = myUrl!
            streamingTextfield.text = URL
        }else {
            print("Url nicht vorhanden!")
        }
    }

    //ZurückButton wurde gedrückt
    @IBAction func backButtonPressed(sender: UIBarButtonItem) {
        print(#function)
        
        //Blende Tastatur aus
        self.view.endEditing(true)
        
        //Speichere URL Persistent
        if (streamingTextfield.text != nil && streamingTextfield.text != ""){
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(streamingTextfield.text, forKey: "streamingUrl")
            defaults.synchronize()
            print("Url gespeichert")
        }
        
        //Verlasse SettingsVC
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Text wurde in Textfeld eingegeben
    @IBAction func streamingUrlTextfield(sender: UITextField) {
        if sender.text != nil {
            URL = sender.text!
        }
    }
    
    //Lupus-Button wurde geklickt
    @IBAction func lupusButtonPressed(sender: UIButton) {
        streamingTextfield.text = "rtsp://lupus:lupus@192.168.0.25:88/videoMain"
    }
    
    @IBAction func goProButtonPressed(sender: UIButton) {
        
        streamingTextfield.text = "http://10.5.5.9:8080/live/amba.m3u8"
    }
    
    @IBAction func qumoxButtonPressed(sender: UIButton) {
        
        streamingTextfield.text = "rtsp://192.168.1.254:554/sjcam.mov"
    }
    
    @IBAction func testVideoButtonPressed(sender: UIButton) {
        
        streamingTextfield.text = "https://archive.org/download/ksnn_compilation_master_the_internet/ksnn_compilation_master_the_internet_512kb.mp4"
    }
    
    
    //Zoomfaktor wurde verändert
    @IBAction func setZoomFactor(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            print ("1x")
            ZOOM = "16:9"
        case 1:
            print ("2x")
            ZOOM = "4:3"
        case 2:
            print ("3x")
            ZOOM = "1:1"
        default:
            print ("No valid choise")
        }
    }
    
    
    //Bei Enter verschwindet Tastatur
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //User tappt auf Bildschirm --> Tastatur verschwindet
    @IBAction func viewTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

}
