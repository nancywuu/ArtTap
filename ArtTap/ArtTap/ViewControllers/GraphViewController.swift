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
    
    var post : Post?
    var dataArray = [NSNumber]()
    
    let yValues: [ChartDataEntry] = [
        ChartDataEntry(x: 0.0, y: 10.0),
        ChartDataEntry(x: 1.0, y: 16.0),
        ChartDataEntry(x: 2.0, y: 12.0),
        ChartDataEntry(x: 3.0, y: 20.0),
        ChartDataEntry(x: 4.0, y: 9.0),
        ChartDataEntry(x: 5.0, y: 13.0),
        ChartDataEntry(x: 6.0, y: 14.0),
        ChartDataEntry(x: 7.0, y: 18.0)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.likeCount.text = (post?.likeCount.stringValue ?? "<no_name>") + " likes";
        self.viewCount.text = (post?.numViews.stringValue ?? "<no_name>") + " views";
        
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
        lineChartView.xAxis.setLabelCount(6, force: false)
        lineChartView.xAxis.labelTextColor = .white
        lineChartView.xAxis.axisLineColor = .white
        lineChartView.legend.textColor = .white
        
        let days = ["Jul 7", "Jul 8", "Jul 9", "Jul 10", "Jul 11", "Jul 12", "Jul 13", "Jul 14"]
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:days)
        lineChartView.xAxis.granularity = 1
        
        lineChartView.animate(xAxisDuration: 0.7)
        
        setData();
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func setData() {
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
