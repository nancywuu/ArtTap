//
//  Suggested.swift
//  ArtTap
//
//  Created by Nancy Wu on 7/19/22.
//

import UIKit
import Vision

@objcMembers public class Suggested: NSObject {
    var sampleArray = [Post]()
    var resArray = [Post]()
    var urlArray = [URL]()
    var ranking = [(contestantIndex: Int, featureprintDistance: Float)]()

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
            let contestantImageURL = URL(string:sampleArray[idx].image.url!)
            ranking.append((contestantIndex: idx, featureprintDistance: 0.0))
            if let contestantFPO = featureprintObservationForImage(atURL: contestantImageURL!) {
                do {
                    for i in origArray.indices {
                        let originalFPO = origArray[i]
                        var distance = Float(0)
                        
                        try contestantFPO.computeDistance(&distance, to: originalFPO)
                        print(distance)
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
        
        for rank in ranking {
            resArray.append(sampleArray[rank.contestantIndex])
        }
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
}
