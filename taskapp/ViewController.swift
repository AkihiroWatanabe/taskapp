//
//  ViewController.swift
//  taskapp
//
//  Created by AkihiroWatanabe on 2016/05/22.
//  Copyright © 2016年 Akihiro Watanabe. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    var searchBar: UISearchBar!
    private func setupSearchBar() {
        if let navigationBarFrame = navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "Search"
            searchBar.showsCancelButton = true
            searchBar.autocapitalizationType = UITextAutocapitalizationType.None
            searchBar.keyboardType = UIKeyboardType.Default
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
            searchBar.becomeFirstResponder()
        }
    }
    
    //サーチボタンクリック時
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        taskArray = realm.objects(Task).sorted("date", ascending: true).filter("category = '\(searchBar.text!)'")
        print(taskArray)
        if taskArray.isEmpty{
        
            let alertController = UIAlertController(title: "エラー", message: "該当するカテゴリーがありません", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            taskArray = realm.objects(Task).sorted("date", ascending: true)
            alertController.addAction(defaultAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)        }
        else{
        tableView.reloadData()
        //searchBar.endEditing(true)
        }
        
    }
    
    //キャンセルクリック時
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        print("push")
        taskArray = realm.objects(Task).sorted("date", ascending: true)
        searchBar.text = ""
        tableView.reloadData()
    }
    
    
    
    let realm = try! Realm()
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task).sorted("date", ascending: true)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
    
        return taskArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
    
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
        
        if indexPath.row == taskArray.last{}
        
        return cell
    }
    
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("cellSegue", sender: nil)
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let inputViewController:InputViewController = segue.destinationViewController as! InputViewController
        
        if segue.identifier == "cellSegue" {
        
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0{
            
                task.id = taskArray.max("id")! + 1
            }
        
            inputViewController.task = task
            
        }
    }
    
    
    
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            
            
            try! realm.write {
                
                //self.taskArray.removeAtIndex(indexPath.row)
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                
            }
            
            

            
        }
    }

    
    //入力画面から戻ってきたときに画面を更新するメソッド
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        searchBar.text = ""
        taskArray = try! Realm().objects(Task).sorted("date", ascending: false)
        tableView.reloadData()
    }
    
    
    
    
    
    
}

