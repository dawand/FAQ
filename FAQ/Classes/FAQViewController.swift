//
//  ViewController.swift
//  FAQ
//
//  Created by Dawand Sulaiman on 02/01/2020.
//  Copyright © 2020 CarrotApps. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var questionsArray = [String]()
    var answersDict = Dictionary<String, [String]>() // multiple answers for a question
    var collapsedArray = [Bool]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        addTableStyles()
        readQAFile()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func addTableStyles(){
        navigationController?.isNavigationBarHidden = false
        
        self.tableView?.backgroundView = {
            let view = UIView(frame: self.tableView.bounds)
            let gradient = CAGradientLayer()
                   gradient.frame = self.view.bounds
                   gradient.startPoint = CGPoint.zero
                   gradient.endPoint = CGPoint(x: 1, y: 1)
                   gradient.colors = [
                    UIColor.red.cgColor,
                    UIColor.yellow.cgColor
                   ]
            view.layer.addSublayer(gradient)
            return view
        }()
        
        tableView.estimatedRowHeight = 43.0;
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
    }
    
    func readQAFile(){
        guard let url = Bundle.main.url(forResource: "QA", withExtension: "plist")
            else { print("no QAFile found")
                return
        }
        
        let QAFileData = try! Data(contentsOf: url)
        let dict = try! PropertyListSerialization.propertyList(from: QAFileData, format: nil) as! Dictionary<String, Any>
        
        // Read the questions and answers from the plist
        questionsArray = dict["Questions"] as! [String]
        answersDict = dict["Answers"] as! Dictionary<String, [String]>
        
        // Initially collapse every question
        for _ in 0..<questionsArray.count {
            collapsedArray.append(false)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return questionsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if collapsedArray[section] {
            let ansCount = answersDict[String(section)]!
            return ansCount.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Set it to any number
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if collapsedArray[indexPath.section] {
            return UITableView.automaticDimension
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:40))
        headerView.tag = section
        
        let headerString = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width, height: 50)) as UILabel
        // For RTL
//        headerString.textAlignment = .right
//        headerString.text = questionsArray[section]
         headerString.text = "\(section+1). \(questionsArray[section])"
        headerView .addSubview(headerString)
        
        let headerTapped = UITapGestureRecognizer (target: self, action:#selector(sectionHeaderTapped(_:)))
        headerView.addGestureRecognizer(headerTapped)
        
        return headerView
    }
    
    @objc func sectionHeaderTapped(_ recognizer: UITapGestureRecognizer) {
        
        let indexPath : IndexPath = IndexPath(row: 0, section:recognizer.view!.tag)
        if (indexPath.row == 0) {
            
            let collapsed = collapsedArray[indexPath.section]
            
            collapsedArray[indexPath.section] = !collapsed
            
            //reload specific section animated
            let range = Range(NSRange(location: indexPath.section, length: 1))!
            let sectionToReload = IndexSet(integersIn: range)
            self.tableView.reloadSections(sectionToReload as IndexSet, with:UITableView.RowAnimation.fade)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cellIdentifier = "Cell"
        let cell: UITableViewCell! = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.numberOfLines = 0
        // For RTL
        // cell.textLabel?.textAlignment = .right
        
        let manyCells : Bool = collapsedArray[indexPath.section]
        
        if (manyCells) {
            let content = answersDict[String(indexPath.section)]
            cell.textLabel?.text = content![indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        // Add specific actions to the answers
        
        if indexPath.section == 1 && indexPath.row == 0 {
          if UIApplication.shared.canOpenURL(URL(string:"fb://profile/144976955616306")!){
                         UIApplication.shared.open(URL(string:"fb://profile/144976955616306")!)
                     } else{
                         UIApplication.shared.open(URL(string:"https://www.facebook.com/kurdcode")!)
                     }
        }
            
        else if indexPath.section == 3 && indexPath.row == 0 {
            
            let appID = "492666610"
                      if let checkURL = URL(string: "https://apps.apple.com/developer/id\(appID)") {
                          UIApplication.shared.open(checkURL)
                      } else {
                          print("invalid url")
                      }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

