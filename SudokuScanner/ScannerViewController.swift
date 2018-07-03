//
//  ScannerViewController.swift
//  Sudoku
//
//  Created by Jeremy Doneghue on 28/06/18.
//  Using modified code from the Apple ClassifyingImagesWithVisionAndCoreML sample project under the Apache licence

import UIKit
import CoreML
import Vision

@available(iOS 11.0, *)
class ScannerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    private let _MNISTSize: CGFloat = 28.0
    
    /// - Tag: MLModelSetup
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: ImageClassifier().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    lazy var textDetectionRequest: VNDetectTextRectanglesRequest = {
        return VNDetectTextRectanglesRequest(completionHandler: self.handleTextRects)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.contentMode = .scaleAspectFit
    }
    
    // MARK: - Image Classification
    
    // MARK: - Photo Actions
    
    @IBAction func takePhoto(_ sender: Any) {
        
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let ctx = CIContext()

        imageView.image = image

        if let ciImage = CIImage(image: image) {
            
            let orientation = CGImagePropertyOrientation(image.imageOrientation)
            let detectYaRect = CIDetector(ofType: CIDetectorTypeRectangle, context: ctx, options: nil)
            if let features = detectYaRect?.features(in: ciImage) {
                
                if features.count > 0 {
                    
                    let rectangleFeature: CIRectangleFeature = features[0] as! CIRectangleFeature
                    
                    guard let perspectiveCorrected = perspectiveCorrect(image: ciImage, rect: rectangleFeature)
                        else { print("🔴 Perspective correction failed"); return }
                    guard let squareCropped = cropToSquare(image: perspectiveCorrected)
                        else { print("🔴 Cropping to square failed"); return }

                    imageView.image = UIImage(ciImage: squareCropped, scale: 1.0, orientation: .up)
                    let imageRequestHandler = VNImageRequestHandler(ciImage: squareCropped, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: [:])
                    
                    self.textDetectionRequest.reportCharacterBoxes = true
                    self.textDetectionRequest.preferBackgroundProcessing = false
                    if #available(iOS 12.0, *) {
                        self.textDetectionRequest.revision = 1
                    }
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            try imageRequestHandler.perform([self.textDetectionRequest])
                        } catch let error as NSError {
                            print("Failed to perform image request: \(error)")
                            return
                        }
                    }
                                                                    
                                                                    
                    
                    
                    
                    
//                    guard let monochrome = imageToBW(image: squareCropped)
//                        else { print("🔴 Monochrome filter failed"); return }
//                    guard let inverted = invertImage(image: monochrome)
//                        else { print("🔴 Monochrome filter failed"); return }
//                    guard let contrastBoosted = contrastBoost(image: inverted)
//                        else { print("🔴 Contrast boost failed"); return }
//
//                    imageView.image = UIImage(ciImage: contrastBoosted, scale: 1.0, orientation: .up)
//
//                    // Extract out 81 cells
//                    var cells: [[CIImage?]] = Array(repeating: Array(repeating: nil, count: 9), count: 9)
//                    let cellWidth = contrastBoosted.extent.width / 9.0
//                    let cellHeight = contrastBoosted.extent.height / 9.0
//                    let cropInset = ((cellWidth + cellHeight) / 2.0) * 0.35 // 10% of the average of cell width and height
//                    let croppedCellSize = cellWidth - cropInset
//                    let resizeScalar = findScalarToResize(from: croppedCellSize, to: _MNISTSize)
//                    for col in 0..<9 {
//                        for row in (0..<9).reversed() {
//                            let cell = contrastBoosted.cropped(to: CGRect(x: cellWidth * CGFloat(col) + cropInset,
//                                                                              y: cellHeight * CGFloat(row) + cropInset,
//                                                                              width: cellWidth - cropInset, // Width and height of the patch need to be equal for later on
//                                                                              height: cellWidth - cropInset)).oriented(.right) // Probably need to make this smarter
//                            cells[col][row] = resizeImage(image: cell, scalar: resizeScalar)
//                        }
//                    }
//                    //print(cells[0][2]?.extent)
//
//                    for col in 0..<9 {
//                        print(classifyInstance(input: cells[0][col]!, orientation: .right))
//                    }
                }
            }
        }
    }
    
    // MARK: Vision completion handlers
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                print("Unable to classify image.\n\(error!.localizedDescription)")
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                print("Nothing recognized.")
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(1)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                    return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                print(descriptions.joined(separator: ", "))
            }
        }
    }
    
    func handleTextRects(for request: VNRequest, error: Error?) {
        
        if let results = request.results as? [VNTextObservation] {
            for observation in results {
                if let boxes: [VNRectangleObservation] = observation.characterBoxes {
                    for box in boxes {
                        print(box)
                    }
                }
                
            }
        }
    }
    
    private func classifyInstance(input: CIImage, orientation: CGImagePropertyOrientation) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: input, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
        
    }
    
    // MARK: CoreImage transformations
    
    private func imageToBW(image: CIImage) -> CIImage? {
        
        let BWFilter = CIFilter(name: "CIColorMonochrome")
        BWFilter?.setValue(image, forKey: "inputImage")
        BWFilter?.setValue(CIColor.black, forKey: "inputColor")
        return BWFilter?.outputImage
    }
    
    private func invertImage(image: CIImage) -> CIImage? {
        
        let invertFilter = CIFilter(name: "CIColorInvert")
        invertFilter?.setValue(image, forKey: "inputImage")
        return invertFilter?.outputImage
    }
    
    private func contrastBoost(image: CIImage) -> CIImage? {
        
        let contrastBoost = CIFilter(name: "CIColorControls")
        contrastBoost?.setValue(image, forKey: "inputImage")
        contrastBoost?.setValue(128.0, forKey: "inputContrast")
        contrastBoost?.setValue(0.0, forKey: "inputBrightness")
        return contrastBoost?.outputImage
    }
    
    private func perspectiveCorrect(image: CIImage, rect: CIRectangleFeature) -> CIImage? {
        
        let perspectiveCorrect = CIFilter(name: "CIPerspectiveCorrection")
        perspectiveCorrect?.setValue(image, forKey: "inputImage")
        perspectiveCorrect?.setValue(CIVector(cgPoint: rect.bottomLeft), forKey: "inputBottomLeft")
        perspectiveCorrect?.setValue(CIVector(cgPoint: rect.bottomRight), forKey: "inputBottomRight")
        perspectiveCorrect?.setValue(CIVector(cgPoint: rect.topLeft), forKey: "inputTopLeft")
        perspectiveCorrect?.setValue(CIVector(cgPoint: rect.topRight), forKey: "inputTopRight")
        return perspectiveCorrect?.outputImage
    }
    
    // Crops an image to a square of edge length of the shortest side of the input image
    private func cropToSquare(image: CIImage) -> CIImage? {
        
        let width = image.extent.width
        let height = image.extent.height
        // If already square, just return identity
        if width == height { return image }
        print(image.extent)
        
        enum SideToCrop { case width; case height }
        let longestSide: SideToCrop = (width < height) ? .height : .width
        let cropSize = ((width < height) ? width : height).rounded(.down)
        
        let origin = CGPoint(x: ((longestSide == .width) ? (width - height) / 2 : 0).rounded(.down),
                             y: ((longestSide == .height) ? (height - width) / 2 : 0).rounded(.down))
        
        let cropRect = CGRect(x: origin.x, y: origin.y, width: cropSize, height: cropSize)
        return image.cropped(to: cropRect)
    }
    
    private func findScalarToResize(from oldSize: CGFloat, to newSize: CGFloat) -> CGFloat {
        return newSize / oldSize
    }
    
    private func resizeImage(image: CIImage, scalar: CGFloat) -> CIImage? {
        
        let resizeFilter = CIFilter(name: "CILanczosScaleTransform")
        resizeFilter?.setValue(image, forKey: "inputImage")
        resizeFilter?.setValue(scalar, forKey: "inputScale")
        return resizeFilter?.outputImage
    }
    
    @IBAction func cancelScanning(_ sender: Any) {
        
        performSegue(withIdentifier: "unwindFromScanner", sender: self)
    }
    
    
}
