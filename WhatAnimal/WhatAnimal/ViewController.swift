//
//  ViewController.swift
//  WhatAnimal
//
//  Created by Matt Bremner on 3/1/20.
//  Copyright © 2020 SCL Gaming Studio. All rights reserved.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var whatAnimalLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            //covert to an image the model can handle
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            detect(ciImage)
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(_ image: CIImage) {
        //load the model so we can test image
        guard let model = try? VNCoreMLModel(for: CatOrDogClassifier_1().model) else {
            fatalError("Loading the model failed")
        }
        //process image
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation]else {
                fatalError("model failed to process image")
            }
            if let firstResult = results.first {
                let part = firstResult.identifier.components(separatedBy: ",")
                self.whatAnimalLabel.text = part[0]
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        }catch{
            print(error)
        }
    }
    
    
    

    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
}

