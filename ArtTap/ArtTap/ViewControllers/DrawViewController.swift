//
//  DrawViewController.swift
//  ArtTap
//
//  Created by Nancy Wu on 8/3/22.
//

import UIKit
import PencilKit
import Parse

@objcMembers class DrawViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var pencilFingerButton: UIBarButtonItem!
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var underlayImage: UIImageView!
    
    
    let canvasWidth: CGFloat = 786
    let canvasOverscrollHeight: CGFloat = 500
    var drawing = PKDrawing()
    var image : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
        canvasView.drawing = drawing
        
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = true
        self.canvasView.maximumZoomScale = 2.0
        self.canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.contentOffset = CGPoint.zero
        //canvasView.contentSize = image.size
        
        underlayImage.contentMode = .scaleToFill
        underlayImage.image = image
        //underlayImage.frame = CGRect(origin: CGPoint.zero, size: image.size)
        underlayImage.layer.borderColor = UIColor.orange.cgColor
        underlayImage.layer.borderWidth = 1.0
        
        
        if let window = parent?.view.window, let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            toolPicker.addObserver(self)
            canvasView.becomeFirstResponder()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.canvasView.sendSubviewToBack(self.underlayImage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.canvasView.becomeFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let contentSize = self.image.size
        self.canvasView.contentSize = contentSize
        self.underlayImage.frame = CGRect(origin: CGPoint.zero, size: contentSize)
        
        let margin = CGSize(width: 0.5*(self.canvasView.bounds.size.width - contentSize.width),
                              height: 0.5*(self.canvasView.bounds.size.height - contentSize.height))
        let insets = [margin.width, margin.height].map { $0 > 0 ? $0 : 0 }
        self.canvasView.contentInset = UIEdgeInsets(top: insets[1], left: insets[0], bottom: insets[1], right: insets[0])
    }
    
    @IBAction func saveDrawing(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
