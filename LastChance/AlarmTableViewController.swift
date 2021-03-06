//
//  AlarmTableViewController.swift
//  LastChance
//
//  Created by Ben Chaimberg on 2/11/16.
//  Copyright © 2016 Ben Chaimberg. All rights reserved.
//

import UIKit

class AlarmTableViewController: UITableViewController {

    var alarms = [Alarm]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedAlarms = loadAlarms() {
            alarms += savedAlarms
        }
        print(alarms)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "AlarmTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AlarmTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let alarm = alarms[indexPath.row]
        let dateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: alarm.time)
        let dateString = String(format: "%02d:%02d", dateComponents.hour, dateComponents.minute)
        cell.timeLabel.text = dateString

        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            alarms.removeAtIndex(indexPath.row)
            saveAlarms()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    @IBAction func unwindToAlarmList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? AddAlarmViewController, alarm = sourceViewController.alarm {
            for index in 0...3 {
                let localNotification = UILocalNotification()
                let newAlarmTime = alarm.time.dateByAddingTimeInterval(15.0 * Double(index))
                localNotification.fireDate = newAlarmTime
                localNotification.repeatInterval = NSCalendarUnit.Minute
                print("lN.fD", localNotification.fireDate)
                localNotification.alertAction = "Dismiss"
                localNotification.alertTitle = "LastChance Alarm"
                localNotification.alertBody = "You haven't left yet and if you don't now you might be late!"
                localNotification.soundName = "Radiate.aiff"
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            }
            let newIndexPath = NSIndexPath(forRow: alarms.count, inSection: 0)
            alarms.append(alarm)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
        }
        saveAlarms()
    }

    func saveAlarms() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(alarms, toFile: Alarm.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save meals...")
        }
    }
    func loadAlarms() -> [Alarm]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Alarm.ArchiveURL.path!) as? [Alarm]
    }

}
