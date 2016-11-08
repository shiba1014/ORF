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
            self.dismiss(animated: true, completion: nil)
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
        //写真　＝　picture
        //動画　＝　movie
/*--
        let imageData = NSData(data: UIImagePNGRepresentation(memoryImage)!)
        let movieData = NSData(contentsOf: outputFileURL)!

        //let url = URL(string:"http://life-cloud.ht.sfc.keio.ac.jp/~karu/orf/NostalGear.php")
        let boundary = NSString(format: "%d", arc4random() % 10000000)
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type": NSString(format: "multipart/form-data; boundary=%@", boundary)]
        var request = URLRequest(url: URL(string:"http://life-cloud.ht.sfc.keio.ac.jp/~karu/orf/NostalGear.php")!)
        let session = URLSession(configuration: config)
        let body = NSMutableData()
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"type\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("upload\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Disposition: form-data; name=\"picture\"; filename=\"filename\"\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8)!)
//        body.append(imageData as Data)
//        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Disposition: form-data; name=\"movie\"; filename=\"filename\"\r\n".data(using: String.Encoding.utf8)!)
        //body.append("Content-Type: video/quicktime\r\n\r\n".data(using: String.Encoding.utf8)!)
        //body.append(movieData as Data)
        //body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = body as Data
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            if error != nil {
                print(error ?? "error")
                return
            }
            
            print("response: \(response!)")
            
            let phpOutput = String(data: data!, encoding: .utf8)!
            print("php output: \(phpOutput)")
            print(data ?? "data")
        })
        task.resume()
        
        var request1 = URLRequest(url: URL(string:"http://life-cloud.ht.sfc.keio.ac.jp/~karu/orf/NostalGear.php")!)
        request1.httpMethod = "POST"
        var postData:Data = Data()
        postData.append((String("type=upload")?.data(using: .utf8))!)
//        data.append((String("type=upload&")?.data(using: .utf8))!)
//        data.append((String("picture=")?.data(using: .utf8))!)
//        data.append(imageData as Data)
//        data.append((String("&")?.data(using: .utf8))!)
//        data.append((String("movie=")?.data(using: .utf8))!)
//        data.append(movieData as Data)
        
        request1.httpBody = postData

        let taskTest = URLSession.shared.dataTask(with: request1, completionHandler: {
            (data, response, error) in
 
            if error != nil {
                print(error ?? "error")
                return
            }
            
            print("response: \(response!)")
            
           let phpOutput = String(data: data!, encoding: .utf8)!
            print("php output: \(phpOutput)")
            print(data ?? "data")
            
        })
//        taskTest.resume()
--*/
     //   upload(outputFileURL: outputFileURL)
        uploadMemory(outputFileURL: outputFileURL)
    }
//    
//    func upload(outputFileURL: URL!){
//        
//        let imageData = UIImageJPEGRepresentation(memoryImage,0.01)
////        let movieData = NSData(contentsOf: outputFileURL)!
//        
//        let boundary = "--CreateMemory"
//        let config = URLSessionConfiguration.default
////        config.timeoutIntervalForRequest = TimeInterval(60 * 60 * 24 * 7)
//        config.httpAdditionalHeaders = ["Content-Type": NSString(format: "multipart/form-data; boundary=%@", boundary)]
//        var request = URLRequest(url: URL(string: "http://life-cloud.ht.sfc.keio.ac.jp/~karu/orf/NostalGear.php")!)
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        let body = NSMutableData()
//        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Disposition: form-data; name=\"request_type\"\r\n\r\n".data(using: String.Encoding.utf8)!)
//        body.append("upload\r\n".data(using: String.Encoding.utf8)!)
//        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//
//        body.append("Content-Disposition: form-data; name=\"object_image\"; filename=\"objectImage.jpeg\"\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8)!)
//        body.append(imageData!)
//        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
//        /*
//        body.append("Content-Disposition: form-data; name=\"movie\"; filename=\"filename\"\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Type: video/quicktime\r\n\r\n".data(using: String.Encoding.utf8)!)
//        body.append(movieData as Data)
//        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
// */
//        
//    //    request.setValue(String(body.length), forHTTPHeaderField: "Content-Length")
//        request.httpMethod = "POST"
//        request.httpBody = body as Data
//        let session = URLSession(configuration: config)
//        session.dataTask(with: request, completionHandler: ({
//            data, response, error in
//            
//            if error != nil {
//                print(error ?? "error")
//                return
//            }
//            
//            print("response: \(response!)")
//            
//            let phpOutput = String(data: data!, encoding: .utf8)!
//            print("php output: \(phpOutput)")
//
//        })).resume()
//    }
    
    func uploadMemory(outputFileURL: URL!) {
        var request = URLRequest(url: URL(string: "http://life-cloud.ht.sfc.keio.ac.jp/~karu/orf/NostalGear.php")!)
        request.httpMethod = "POST"
        
        let imageData = UIImageJPEGRepresentation(memoryImage,0.3)
//        let movieData = NSData(contentsOf: outputFileURL)!
        
        Alamofire.upload(multipartFormData: {multipartFormData in
            
            multipartFormData.append("upload".data(using: .utf8)!, withName: "request_type")
            multipartFormData.append(imageData!, withName: "object_image", fileName: "objectImage.jpeg", mimeType: "image/jpeg")
            multipartFormData.append(outputFileURL, withName: "movie", fileName: "memoryMovie.jpeg", mimeType: "video/quicktime")
            
        }, with: request, encodingCompletion: {result in  
            switch result{
            case .success(request: let upload, _, _):
                upload.responseData(completionHandler: { response in
                    print(NSString(data:response.result.value!, encoding:String.Encoding.utf8.rawValue) ?? "reponse")
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
