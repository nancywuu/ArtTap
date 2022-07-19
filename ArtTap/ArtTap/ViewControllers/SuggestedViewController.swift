//
//  SuggestedViewController.swift
//  ArtTap
//
//  Created by Nancy Wu on 7/18/22.
//

import UIKit
import Vision

@objcMembers class SuggestedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segCon: UISegmentedControl!
    
    var testurl: URL?
    var sampleArray = [URL]()

    var urlArray = [URL]()
    var ranking = [(contestantIndex: Int, featureprintDistance: Float)]()
    
    private let cellIdentifier: String = "suggestedCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.processImages()
    }
    
    func processImages() {
        
        // get feature prints of user's posts (input)
        var origArray = [VNFeaturePrintObservation]()
        for idx in urlArray.indices {
            let origURL = urlArray[idx]
            if let origFPO = featureprintObservationForImage(atURL: origURL) {
                origArray.append(origFPO)
            }
        }
        
        // setup ranked array for adding to

        // Generate featureprints for copies and compute distances from original featureprint.
        for idx in sampleArray.indices {
            let contestantImageURL = sampleArray[idx]
            ranking.append((contestantIndex: idx, featureprintDistance: 0.0))
            if let contestantFPO = featureprintObservationForImage(atURL: contestantImageURL) {
                do {
                    for i in origArray.indices {
                        let originalFPO = origArray[i]
                        var distance = Float(0)
                        try contestantFPO.computeDistance(&distance, to: originalFPO)
                        ranking[idx].featureprintDistance += distance
                    }
                } catch {
                    print("Error computing distance between featureprints.")
                }
            }
        }
        // Sort results based on distance.
        ranking.sort { (result1, result2) -> Bool in
            return result1.featureprintDistance < result2.featureprintDistance
        }
        
        for res in ranking {
            print(res)
            print(sampleArray[res.contestantIndex])
        }

        self.tableView.reloadData()
        
    }

    
    func featureprintObservationForImage(atURL url: URL) -> VNFeaturePrintObservation? {
        let requestHandler = VNImageRequestHandler(url: url, options: [:])
        let request = VNGenerateImageFeaturePrintRequest()
        request.usesCPUOnly = true
        do {
            try requestHandler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            print("Vision error: \(error)")
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ranking.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? SuggestedCell {
            let currentURL = sampleArray[ranking[indexPath.row].contestantIndex]
            cell.previewImage.image = UIImage(contentsOfFile: currentURL.path)
            return cell
        }
        return UITableViewCell()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
