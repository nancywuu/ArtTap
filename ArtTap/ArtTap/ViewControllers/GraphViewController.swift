//
//  GraphViewController.swift
//  ArtTap
//
//  Created by Nancy Wu on 7/14/22.
//

import UIKit
import Charts

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
    
    let hoursInMonth : Int = 730
    let hoursInWeek : Int = 168
    let hoursInDay : Int = 24

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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cumulatSwitch.setOn(false, animated: false)
        
        if(self.viewArray.count < hoursInMonth){
            let holder = [NSNumber](repeating: 0, count: 730 - self.viewArray.count )
            self.viewArray.insert(contentsOf: holder, at: 0)
        }
        
        modifyLineChart(lineChartView: lineChartView)
        modifyLineChart(lineChartView: viewLineChartView)
        
        getCumulativeArrays()
        setData()
    }
    
    func getCumulativeArrays() {
        self.engageArray.reverse()
        self.likeArray.reverse()
        self.commentArray.reverse()
        self.critArray.reverse()
        
        self.engageArrayCumulat = createCumulativeArray(givenArray: self.engageArray)
        self.likeArrayCumulat = createCumulativeArray(givenArray: self.likeArray)
        self.commentArrayCumulat = createCumulativeArray(givenArray: self.commentArray)
        self.critArrayCumulat = createCumulativeArray(givenArray: self.critArray)
        self.viewArrayCumulat = createCumulativeArray(givenArray: self.viewArray)
        
        let engageCountVal = engageArrayCumulat[engageArrayCumulat.count - 1]
        self.engageCount.text = Int(truncating: engageCountVal) > 1 ? engageCountVal.stringValue + " users engaged" : engageCountVal.stringValue + " user engaged";
        
        let commentCountVal = commentArrayCumulat[commentArrayCumulat.count - 1]
        self.commentCount.text = Int(truncating: commentCountVal) > 1 ? commentCountVal.stringValue + " comments" : commentCountVal.stringValue + " comment";
        
        let critCountVal = critArrayCumulat[critArrayCumulat.count - 1]
        self.critCount.text = Int(truncating: critCountVal) > 1 ? critCountVal.stringValue + " critiques" : critCountVal.stringValue + " critique";
        
        let likeCountVal = likeArrayCumulat[likeArrayCumulat.count - 1]
        self.likeCount.text = Int(truncating: likeCountVal) > 1 ? likeCountVal.stringValue + " likes" : likeCountVal.stringValue + " like";
        
        let viewCountVal = viewArrayCumulat[viewArrayCumulat.count - 1]
        self.viewCount.text = Int(truncating: viewCountVal) > 1 ? viewCountVal.stringValue + " views" : engageCountVal.stringValue + " view";
    }
    
    func setData() {
        var limit = 0
        if(self.timeFrame == 1){
            limit = hoursInMonth - hoursInWeek
        } else if (self.timeFrame == 2){
            limit = hoursInMonth - hoursInDay
        }
        
        var engageSet : LineChartDataSet
        var likeSet : LineChartDataSet
        var commentSet : LineChartDataSet
        var critSet : LineChartDataSet
        var viewSet : LineChartDataSet
        
        if(self.isCumulat){
            engageSet = createDataSetFromArr(ourArray: engageArrayCumulat, limit: limit, ourLabel: "User Engagement", ourColor: UIColor.systemCyan)
            likeSet = createDataSetFromArr(ourArray: likeArrayCumulat, limit: limit, ourLabel: "Likes", ourColor: UIColor.systemRed)
            commentSet = createDataSetFromArr(ourArray: commentArrayCumulat, limit: limit, ourLabel: "Comments", ourColor: UIColor.systemMint)
            critSet = createDataSetFromArr(ourArray: critArrayCumulat, limit: limit, ourLabel: "Critiques", ourColor: UIColor.systemYellow)
            viewSet = createDataSetFromArr(ourArray: viewArrayCumulat, limit: limit, ourLabel: "Views", ourColor: UIColor.systemPurple)
        } else {
            engageSet = createDataSetFromArr(ourArray: engageArray, limit: limit, ourLabel: "User Engagement", ourColor: UIColor.systemCyan)
            likeSet = createDataSetFromArr(ourArray: likeArray, limit: limit, ourLabel: "Likes", ourColor: UIColor.systemRed)
            commentSet = createDataSetFromArr(ourArray: commentArray, limit: limit, ourLabel: "Comments", ourColor: UIColor.systemMint)
            critSet = createDataSetFromArr(ourArray: critArray, limit: limit, ourLabel: "Critiques", ourColor: UIColor.systemYellow)
            viewSet = createDataSetFromArr(ourArray: viewArray, limit: limit, ourLabel: "Views", ourColor: UIColor.systemPurple)
        }
        
        let data = LineChartData(dataSets: [engageSet, likeSet, commentSet, critSet])
        data.setDrawValues(false)
        
        let viewdata = LineChartData(dataSets: [viewSet])
        viewdata.setDrawValues(false)
    
        lineChartView.data = data;
        viewLineChartView.data = viewdata;
    }
    
    func modifyLineChart(lineChartView: LineChartView) {
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
    }
    
    func createDataSetFromArr(ourArray: [NSNumber], limit: Int, ourLabel: String, ourColor: UIColor) -> LineChartDataSet{
        var ourValues : [ChartDataEntry] = []
        for i in limit..<ourArray.count {
            ourValues.append(ChartDataEntry(x: Double(i), y: ourArray[i].doubleValue))
        }
        
        let ourSet = LineChartDataSet(entries: ourValues, label: ourLabel)
        ourSet.drawCirclesEnabled = false
        ourSet.lineWidth = 2
        ourSet.setColor(ourColor)
        ourSet.fillColor = ourColor
        ourSet.fillAlpha = 0.1
        ourSet.drawFilledEnabled = true;
        ourSet.drawHorizontalHighlightIndicatorEnabled = false
        
        return ourSet
    }
    
    func createCumulativeArray(givenArray: [NSNumber]) -> [NSNumber]{
        var resArray : [NSNumber] = []
        resArray = givenArray
        
        var total : Int = 0
        for i in 0..<givenArray.count {
            total += resArray[i].intValue
            
            resArray[i] = total as NSNumber
        }
        
        return resArray
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
}
