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
    
    let hoursInMonth : Int = 730
    let hoursInWeek : Int = 168
    let hoursInDay : Int = 24
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(post?.likeCount == 1){
            self.likeCount.text = (post?.likeCount.stringValue ?? "<no_name>") + " like"
        } else {
            self.likeCount.text = (post?.likeCount.stringValue ?? "<no_name>") + " likes"
        }
        
        if(post?.numViews == 1){
            self.viewCount.text = (post?.numViews.stringValue ?? "<no_name>") + " view";
        } else {
            self.viewCount.text = (post?.numViews.stringValue ?? "<no_name>") + " views";
        }

        self.cumulatSwitch.setOn(false, animated: false)
        
        if(self.viewArray.count < hoursInMonth){
            let holder = [NSNumber](repeating: 0, count: 730 - self.viewArray.count )
            self.viewArray.insert(contentsOf: holder, at: 0)
        } else if (self.viewArray.count > hoursInMonth){
            // TODO: implement checked to limit a post that is older than a month
        }
        
        modifyLineChart(lineChartView: lineChartView)
        modifyLineChart(lineChartView: viewLineChartView)
        
        setCumulative()
        setData()
    }
    
    func setCumulative() {
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
        var limit = 0
        if(self.timeFrame == 1){
            limit = hoursInMonth - hoursInWeek
        } else if (self.timeFrame == 2){
            limit = hoursInMonth - hoursInDay
        }
        
        var set1 : LineChartDataSet
        var set2 : LineChartDataSet
        var set3 : LineChartDataSet
        var set4 : LineChartDataSet
        var set5 : LineChartDataSet
        
        if(self.isCumulat){
            set1 = createDataSetFromArr(ourArray: engageArrayCumulat, limit: limit, ourLabel: "User Engagement", ourColor: UIColor.systemCyan)
            set2 = createDataSetFromArr(ourArray: likeArrayCumulat, limit: limit, ourLabel: "Likes", ourColor: UIColor.systemRed)
            set3 = createDataSetFromArr(ourArray: commentArrayCumulat, limit: limit, ourLabel: "Comments", ourColor: UIColor.systemMint)
            set4 = createDataSetFromArr(ourArray: critArrayCumulat, limit: limit, ourLabel: "Critiques", ourColor: UIColor.systemYellow)
            set5 = createDataSetFromArr(ourArray: viewArrayCumulat, limit: limit, ourLabel: "Views", ourColor: UIColor.systemPurple)
        } else {
            set1 = createDataSetFromArr(ourArray: engageArray, limit: limit, ourLabel: "User Engagement", ourColor: UIColor.systemCyan)
            set2 = createDataSetFromArr(ourArray: likeArray, limit: limit, ourLabel: "Likes", ourColor: UIColor.systemRed)
            set3 = createDataSetFromArr(ourArray: commentArray, limit: limit, ourLabel: "Comments", ourColor: UIColor.systemMint)
            set4 = createDataSetFromArr(ourArray: critArray, limit: limit, ourLabel: "Critiques", ourColor: UIColor.systemYellow)
            set5 = createDataSetFromArr(ourArray: viewArray, limit: limit, ourLabel: "Views", ourColor: UIColor.systemPurple)
        }
        
        let data = LineChartData(dataSets: [set1, set2, set3, set4])
        data.setDrawValues(false)
        
        let viewdata = LineChartData(dataSets: [set5])
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
