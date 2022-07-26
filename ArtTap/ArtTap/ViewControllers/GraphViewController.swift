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
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var viewLineChartView: LineChartView!
    
    var post : Post?
    var dataArray = [NSNumber]()
    
    
    
    var yValues: [ChartDataEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.likeCount.text = (post?.likeCount.stringValue ?? "<no_name>") + " likes";
        self.viewCount.text = (post?.numViews.stringValue ?? "<no_name>") + " views";
        
        print("printing data array")
        print(dataArray)
        
//        view.addSubview(lineChartView)
//        lineChartView.centerInSuperview()
//        lineChartView.width(to: view);
//        lineChartView.heightToWidth(of: view)
        
        lineChartView.backgroundColor = .black;
        
        lineChartView.rightAxis.enabled = false
        let yAxis = lineChartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        lineChartView.xAxis.setLabelCount(180, force: false)
        lineChartView.xAxis.labelTextColor = .white
        lineChartView.xAxis.axisLineColor = .white
        lineChartView.legend.textColor = .white

        
        let days = ["July 10"]
        
        
        lineChartView.xAxis.drawGridLinesEnabled = false;
        lineChartView.xAxis.granularity = 1;
        lineChartView.xAxis.drawLabelsEnabled = true;
        lineChartView.xAxis.drawAxisLineEnabled = false;
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:days)
       // lineChartView.xAxis.granularity = 10
        
        lineChartView.animate(xAxisDuration: 1.5)
        
        setData();
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func setData() {
        var counter : Int = 0
        for i in 0..<dataArray.count {
            yValues.append(ChartDataEntry(x: Double(i), y: dataArray[i].doubleValue))
            counter += dataArray[i].intValue
        }
        self.engageCount.text = String(counter) + " users engaged";
        
        let set1 = LineChartDataSet(entries: yValues, label: "User Engagement")
        let data = LineChartData(dataSet: set1)
        set1.drawCirclesEnabled = false
        data.setDrawValues(false)
        
        set1.lineWidth = 2
        set1.setColor(.systemCyan)
        set1.fillColor = .systemCyan
        set1.fillAlpha = 0.5
        set1.drawFilledEnabled = true;
        set1.drawHorizontalHighlightIndicatorEnabled = false
    
        lineChartView.data = data;
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
