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
    @IBOutlet weak var critCount: UILabel!
    @IBOutlet weak var segCon: UISegmentedControl!
    @IBOutlet weak var cumulatSwitch: UISwitch!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var viewLineChartView: LineChartView!
    
    let constantTime : Int = 730
    
    var post : Post?

    var isCumulat : Bool = false
    var timeFrame : Int = 0
    var engageArray = [NSNumber]()
    var likeArray = [NSNumber]()
    var commentArray = [NSNumber]()
    var critArray = [NSNumber]()
    var viewArray = [NSNumber]()
    
    var engageArrayCumulat = [NSNumber]()
    var likeArrayCumulat = [NSNumber]()
    var commentArrayCumulat = [NSNumber]()
    var critArrayCumulat = [NSNumber]()
    var viewArrayCumulat = [NSNumber]()

    var engageValues: [ChartDataEntry] = []
    var likeValues: [ChartDataEntry] = []
    var commentValues: [ChartDataEntry] = []
    var critValues: [ChartDataEntry] = []
    var viewValues: [ChartDataEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.likeCount.text = (post?.likeCount.stringValue ?? "<no_name>") + " likes";
        self.viewCount.text = (post?.numViews.stringValue ?? "<no_name>") + " views";
        
        self.cumulatSwitch.setOn(false, animated: false)
        
        // fix format of view tracking array because we don't guarantee the length
        
        if(self.viewArray.count < constantTime){
            let holder = [NSNumber](repeating: 0, count: 730 - self.viewArray.count )
            self.viewArray.insert(contentsOf: holder, at: 0)
        } else if (self.viewArray.count > constantTime){
            // TODO: implement checked to limit a post that is older than a month
        }
        
        
        lineChartView.backgroundColor = .black;
        
        lineChartView.rightAxis.enabled = false
        let yAxis = lineChartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.axisMinimum = 0
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        lineChartView.xAxis.setLabelCount(0, force: true)
        lineChartView.xAxis.labelTextColor = .white
        lineChartView.xAxis.axisLineColor = .white
        lineChartView.legend.textColor = .white

        lineChartView.xAxis.drawGridLinesEnabled = false;
        lineChartView.xAxis.granularity = 1;
        lineChartView.xAxis.drawLabelsEnabled = false;
        lineChartView.xAxis.drawAxisLineEnabled = false;
        
        lineChartView.animate(xAxisDuration: 1.5)
        
        viewLineChartView.backgroundColor = .black;
        
        viewLineChartView.rightAxis.enabled = false
        let yView = viewLineChartView.leftAxis
        yView.labelFont = .boldSystemFont(ofSize: 12)
        yView.setLabelCount(6, force: false)
        yView.axisMinimum = 0
        yView.labelTextColor = .white
        yView.axisLineColor = .white
        
        viewLineChartView.xAxis.labelPosition = .bottom
        viewLineChartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        viewLineChartView.xAxis.setLabelCount(0, force: true)
        viewLineChartView.xAxis.labelTextColor = .white
        viewLineChartView.xAxis.axisLineColor = .white
        viewLineChartView.legend.textColor = .white

        viewLineChartView.xAxis.drawGridLinesEnabled = false;
        viewLineChartView.xAxis.granularity = 1;
        viewLineChartView.xAxis.drawLabelsEnabled = false;
        viewLineChartView.xAxis.drawAxisLineEnabled = false;
        
        viewLineChartView.animate(xAxisDuration: 1.5)
        
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
        self.critArray.reverse()
        self.engageArrayCumulat = self.engageArray
        self.likeArrayCumulat = self.likeArray
        self.commentArrayCumulat = self.commentArray
        self.critArrayCumulat = self.critArray
        self.viewArrayCumulat = self.viewArray
        
        var engageTotal : Int = 0
        var likeTotal : Int = 0
        var commentTotal : Int = 0
        var critTotal : Int = 0
        var viewTotal : Int = 0
        
        for i in 0..<engageArray.count {
            engageTotal += engageArrayCumulat[i].intValue
            likeTotal += likeArrayCumulat[i].intValue
            commentTotal += commentArrayCumulat[i].intValue
            critTotal += critArrayCumulat[i].intValue
            viewTotal += viewArrayCumulat[i].intValue
            
            engageArrayCumulat[i] = engageTotal as NSNumber
            likeArrayCumulat[i] = likeTotal as NSNumber
            commentArrayCumulat[i] = commentTotal as NSNumber
            critArrayCumulat[i] = critTotal as NSNumber
            viewArrayCumulat[i] = viewTotal as NSNumber
        }
        
        
        let engageCountVal = engageArrayCumulat[engageArrayCumulat.count - 1]
        if(engageCountVal == 1){
            self.engageCount.text = engageArrayCumulat[engageArrayCumulat.count - 1].stringValue + " user engaged";
        } else {
            self.engageCount.text = engageArrayCumulat[engageArrayCumulat.count - 1].stringValue + " users engaged";
        }
        
        let commentCountVal = commentArrayCumulat[commentArrayCumulat.count - 1]
        if(commentCountVal == 1){
            self.commentCount.text = commentArrayCumulat[commentArrayCumulat.count - 1].stringValue + " comment";
        } else {
            self.commentCount.text = commentArrayCumulat[commentArrayCumulat.count - 1].stringValue + " comments";
        }
        
        let critCountVal = critArrayCumulat[critArrayCumulat.count - 1]
        if(critCountVal == 1){
            self.critCount.text = critArrayCumulat[critArrayCumulat.count - 1].stringValue + " critique";
        } else {
            self.critCount.text = critArrayCumulat[critArrayCumulat.count - 1].stringValue + " critiques";
        }
    }
    
    func setData() {
        engageValues = []
        likeValues = []
        commentValues = []
        critValues = []
        viewValues = []
        
        var limit = 0
        if(self.timeFrame == 1){
            limit = 562
        } else if (self.timeFrame == 2){
            limit = 706
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
            
            for i in limit..<critArrayCumulat.count {
                critValues.append(ChartDataEntry(x: Double(i), y: critArrayCumulat[i].doubleValue))
            }
            
            for i in limit..<viewArrayCumulat.count {
                viewValues.append(ChartDataEntry(x: Double(i), y: viewArrayCumulat[i].doubleValue))
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

            for i in limit..<critArray.count {
                critValues.append(ChartDataEntry(x: Double(i), y: critArray[i].doubleValue))
            }
            
            for i in limit..<viewArray.count {
                viewValues.append(ChartDataEntry(x: Double(i), y: viewArray[i].doubleValue))
            }
        }
        

        let set1 = LineChartDataSet(entries: engageValues, label: "User Engagement")
        set1.drawCirclesEnabled = false
        
        let set2 = LineChartDataSet(entries: likeValues, label: "Likes")
        set2.drawCirclesEnabled = false
        
        let set3 = LineChartDataSet(entries: commentValues, label: "Comments")
        set3.drawCirclesEnabled = false
        
        let set4 = LineChartDataSet(entries: critValues, label: "Critiques")
        set4.drawCirclesEnabled = false
        
        let set5 = LineChartDataSet(entries: viewValues, label: "Views")
        set5.drawCirclesEnabled = false
        
        set1.lineWidth = 2
        set1.setColor(.systemCyan)
        set1.fillColor = .systemCyan
        set1.fillAlpha = 0.1
        set1.drawFilledEnabled = true;
        set1.drawHorizontalHighlightIndicatorEnabled = false
        
        set2.lineWidth = 2
        set2.setColor(.systemRed)
        set2.fillColor = .systemRed
        set2.fillAlpha = 0.1
        set2.drawFilledEnabled = true;
        set2.drawHorizontalHighlightIndicatorEnabled = false
        
        set3.lineWidth = 2
        set3.setColor(.systemMint)
        set3.fillColor = .systemMint
        set3.fillAlpha = 0.1
        set3.drawFilledEnabled = true;
        set3.drawHorizontalHighlightIndicatorEnabled = false
        
        set4.lineWidth = 2
        set4.setColor(.systemYellow)
        set4.fillColor = .systemYellow
        set4.fillAlpha = 0.1
        set4.drawFilledEnabled = true;
        set4.drawHorizontalHighlightIndicatorEnabled = false
        
        set5.lineWidth = 2
        set5.setColor(.systemPurple)
        set5.fillColor = .systemPurple
        set5.fillAlpha = 0.1
        set5.drawFilledEnabled = true;
        set5.drawHorizontalHighlightIndicatorEnabled = false
        
        let data = LineChartData(dataSets: [set1, set2, set3, set4])
        data.setDrawValues(false)
        
        let viewdata = LineChartData(dataSets: [set5])
        viewdata.setDrawValues(false)
    
        lineChartView.data = data;
        viewLineChartView.data = viewdata;
    }
    
    @IBAction func changedTime(_ sender: Any) {
        self.timeFrame = self.segCon.selectedSegmentIndex
        lineChartView.animate(xAxisDuration: 1.0)
        setData()
    }
    
    @IBAction func hitSwitch(_ sender: Any) {
        if(self.cumulatSwitch.isOn){
            self.isCumulat = true
            lineChartView.animate(xAxisDuration: 1.0)
            setData()
        } else {
            self.isCumulat = false
            lineChartView.animate(xAxisDuration: 1.0)
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
