//
//  GraphViewController.swift
//  ArtTap
//
//  Created by Nancy Wu on 7/14/22.
//

import UIKit
import Charts
import TinyConstraints

@objcMembers class GraphViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var viewCount: UILabel!
    @IBOutlet weak var engageCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var segCon: UISegmentedControl!
    @IBOutlet weak var cumulatSwitch: UISwitch!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var viewLineChartView: LineChartView!
    
    var post : Post?

    var isCumulat : Bool = false
    var isByWeek : Bool = false
    var engageArray = [NSNumber]()
    var likeArray = [NSNumber]()
    var commentArray = [NSNumber]()
    var viewArray = [NSNumber]()
    
    var engageArrayCumulat = [NSNumber]()
    var likeArrayCumulat = [NSNumber]()
    var commentArrayCumulat = [NSNumber]()
    var viewArrayCumulat = [NSNumber]()

    var engageValues: [ChartDataEntry] = []
    var likeValues: [ChartDataEntry] = []
    var commentValues: [ChartDataEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.likeCount.text = (post?.likeCount.stringValue ?? "<no_name>") + " likes";
        self.viewCount.text = (post?.numViews.stringValue ?? "<no_name>") + " views";
        
        self.cumulatSwitch.setOn(false, animated: false)
        
        lineChartView.backgroundColor = .black;
        
        lineChartView.rightAxis.enabled = false
        let yAxis = lineChartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: true)
        yAxis.axisMinimum = 0
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        lineChartView.xAxis.setLabelCount(6, force: true)
        lineChartView.xAxis.labelTextColor = .white
        lineChartView.xAxis.axisLineColor = .white
        lineChartView.legend.textColor = .white

        
        let days = ["July 10"]
        lineChartView.xAxis.drawGridLinesEnabled = false;
        lineChartView.xAxis.granularity = 1;
        lineChartView.xAxis.drawLabelsEnabled = true;
        lineChartView.xAxis.drawAxisLineEnabled = false;
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:days)
        
        lineChartView.animate(xAxisDuration: 1.5)
        
        setCumulative()
        setData()
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func setCumulative() {
        self.engageArray.reverse()
        self.likeArray.reverse()
        self.commentArray.reverse()
        self.engageArrayCumulat = self.engageArray
        self.likeArrayCumulat = self.likeArray
        self.commentArrayCumulat = self.commentArray
        
        var engageTotal : Int = 0
        var likeTotal : Int = 0
        var commentTotal : Int = 0
        
        for i in 0..<engageArray.count {
            engageTotal += engageArrayCumulat[i].intValue
            likeTotal += likeArrayCumulat[i].intValue
            commentTotal += commentArrayCumulat[i].intValue
            
            engageArrayCumulat[i] = engageTotal as NSNumber
            likeArrayCumulat[i] = likeTotal as NSNumber
            commentArrayCumulat[i] = commentTotal as NSNumber
        }
        
        self.engageCount.text = engageArrayCumulat[engageArrayCumulat.count - 1].stringValue + " users engaged";
        self.commentCount.text = commentArrayCumulat[commentArrayCumulat.count - 1].stringValue + " comments";
    }
    
    func setData() {
        engageValues = []
        likeValues = []
        commentValues = []
        
        var limit = 0
        if(self.isByWeek){
            limit = 562
        }
        
        if(self.isCumulat){
            for i in limit..<engageArrayCumulat.count {
                engageValues.append(ChartDataEntry(x: Double(i), y: engageArrayCumulat[i].doubleValue))
            }
            
            for i in limit..<likeArrayCumulat.count {
                likeValues.append(ChartDataEntry(x: Double(i), y: likeArrayCumulat[i].doubleValue))
            }
            
            for i in limit..<commentArrayCumulat.count {
                commentValues.append(ChartDataEntry(x: Double(i), y: commentArrayCumulat[i].doubleValue))
            }
        } else {
            for i in limit..<engageArray.count {
                engageValues.append(ChartDataEntry(x: Double(i), y: engageArray[i].doubleValue))
            }

            for i in limit..<likeArray.count {
                likeValues.append(ChartDataEntry(x: Double(i), y: likeArray[i].doubleValue))
            }

            for i in limit..<commentArray.count {
                commentValues.append(ChartDataEntry(x: Double(i), y: commentArray[i].doubleValue))
            }
        }
        

        let set1 = LineChartDataSet(entries: engageValues, label: "User Engagement")
        set1.drawCirclesEnabled = false
        
        let set2 = LineChartDataSet(entries: likeValues, label: "Likes")
        set2.drawCirclesEnabled = false
        
        let set3 = LineChartDataSet(entries: commentValues, label: "Comments")
        set3.drawCirclesEnabled = false
        
        set1.lineWidth = 2
        set1.setColor(.systemCyan)
        set1.fillColor = .systemCyan
        set1.fillAlpha = 0.2
        set1.drawFilledEnabled = true;
        set1.drawHorizontalHighlightIndicatorEnabled = false
        
        set2.lineWidth = 2
        set2.setColor(.systemRed)
        set2.fillColor = .systemRed
        set2.fillAlpha = 0.2
        set2.drawFilledEnabled = true;
        set2.drawHorizontalHighlightIndicatorEnabled = false
        
        set3.lineWidth = 2
        set3.setColor(.systemMint)
        set3.fillColor = .systemMint
        set3.fillAlpha = 0.2
        set3.drawFilledEnabled = true;
        set3.drawHorizontalHighlightIndicatorEnabled = false
        
        let data = LineChartData(dataSets: [set1, set2, set3])
        data.setDrawValues(false)
    
        lineChartView.data = data;
    }
    
    @IBAction func changedTime(_ sender: Any) {
        if(self.segCon.selectedSegmentIndex == 0) {
            self.isByWeek = false
            lineChartView.animate(xAxisDuration: 1.5)
            setData()
        } else if(self.segCon.selectedSegmentIndex == 1) {
            self.isByWeek = true
            lineChartView.animate(xAxisDuration: 1.0)
            setData()
        }
    }
    
    @IBAction func hitSwitch(_ sender: Any) {
        if(self.cumulatSwitch.isOn){
            self.isCumulat = true
            lineChartView.animate(xAxisDuration: 1.2)
            setData()
        } else {
            self.isCumulat = false
            lineChartView.animate(xAxisDuration: 1.2)
            setData()
        }
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
