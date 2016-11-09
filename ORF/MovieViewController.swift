//
//  MovieViewController.swift
//  ORF
//
//  Created by Paul McCartney on 2016/10/23.
//  Copyright © 2016年 shiba. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Alamofire

class MovieViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet var startButton: UIButton!
    let fileOutput = AVCaptureMovieFileOutput()
    var videoInput:AVCaptureDeviceInput!
    var isRecording : Bool = false
    var memoryImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        startButton.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openCamera(){
        let session = AVCaptureSession()
        let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        session.addOutput(fileOutput)
        do {
            videoInput = try AVCaptureDeviceInput(device: videoDevice) as AVCaptureDeviceInput
            session.addInput(videoInput)
        } catch let error as NSError {
            print(error)
        }
        
        if(session.canAddInput(videoInput)){
            session.addInput(videoInput)
        }
        
        let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session) as AVCaptureVideoPreviewLayer
        videoLayer.frame = self.view.frame
        videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(videoLayer)
        session.startRunning()
        
        isRecording = false
        
        startButton.isHidden = false
        startButton.addTarget(self, action: #selector(MovieViewController.pushedStartButton), for: .touchUpInside)
        self.view.addSubview(startButton)
    }
    
    
    func pushedStartButton() {
        if(isRecording){
            stopRecording()
//            startButton.backgroundColor = UIColor.red
            isRecording = false
        }else{
            startRecording()
            startButton.backgroundColor = UIColor.orange
            isRecording = true
        }
    }
    
    func startRecording() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath : String? = "\(documentsDirectory)/temp.mp4"
        let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)
        fileOutput.startRecording(toOutputFileURL: fileURL as URL!, recordingDelegate: self)
    }
    
    func stopRecording() {
        fileOutput.stopRecording()
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("didStartRecordingToOutputFileAtURL")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {

        /*--
        let library = PHPhotoLibrary.shared()
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL as URL)
        }) { (result: Bool, error: Error?) in
            print("VIDEO FILE SAVED.")
        }
--*/
        uploadMemory(outputFileURL: outputFileURL)
    }
    
    func uploadMemory(outputFileURL: URL!) {
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        
        indicator.startAnimating()
        
        var request = URLRequest(url: URL(string: "http://life-cloud.ht.sfc.keio.ac.jp/~karu/orf/NostalGear.php")!)
        request.httpMethod = "POST"
        
        let imageData = UIImageJPEGRepresentation(memoryImage,0.3)
//        let movieData = NSData(contentsOf: outputFileURL)!
        
        Alamofire.upload(multipartFormData: {multipartFormData in
            
            multipartFormData.append("upload".data(using: .utf8)!, withName: "request_type")
            multipartFormData.append(imageData!, withName: "object_image", fileName: "objectImage.jpeg", mimeType: "image/jpeg")
            multipartFormData.append(outputFileURL, withName: "object_movie", fileName: "memoryMovie.jpeg", mimeType: "video/quicktime")
            
        }, with: request, encodingCompletion: {result in  
            switch result{
            case .success(request: let upload, _, _):
                upload.responseData(completionHandler: { response in
                    print(NSString(data:response.result.value!, encoding:String.Encoding.utf8.rawValue) ?? "reponse")
                    indicator.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                })
                /*
                upload.responseJSON { response in
                    
                    print(response.request ?? "request")   original URL request
                    print(response.response ?? "response")  URL response
                    print(response.data ?? "data")      server data
                    print(response.result)    result of response serialization
                                            self.showSuccesAlert()
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
            
                 '
                 '
                 }
                }
 */
            
            case .failure(let encodingError):
            print(encodingError)
            }
        })
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
