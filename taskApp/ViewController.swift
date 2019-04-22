//
//  ViewController.swift
//  taskApp
//
//  Created by 関口 咲季 on 2019/04/16.
//  Copyright © 2019 saki.sekiguchi. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate {
    
    let realm = try! Realm()
    //タスクデータ配列
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date",ascending: false)
    //検索結果配列
    var resultArray = [Task]()
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //戻る
    @IBAction func tapToBack(_ segue: UIStoryboardSegue){
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //デリゲート結びつけ
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        //デフォルトテキスト
        searchBar.placeholder = "ここに入力してください"
        
        //検索キャンセル非表示
        //searchBar.showsCancelButton = false
        //何も入力されていなくてもReturnキーを押せるようにする。
        searchBar.enablesReturnKeyAutomatically = false
        
        //データをコピー
        //resultArray = taskArray
        
    
    }
    
    //テーブル更新
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()

        
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView:UITableView,numberOfRowsInSection section:Int) -> Int {
        return taskArray.count
    }
    
    //各セルの内容を返すメソッド
    func tableView(_ tableView:UITableView,cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        //再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for:indexPath)
        
        //Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
        
    }

    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView:UITableView,didSelectRowAt indexPath:IndexPath) {
        
        performSegue(withIdentifier: "cellSegue", sender: nil)
        
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView:UITableView,editingStyleForRowAt indexPath:IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView:UITableView,commit editingStyle:UITableViewCell.EditingStyle,forRowAt indexPath:IndexPath){
        
        if editingStyle == .delete{
            
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
    }
    }
    
    
        
    
    //検索ボタン押した時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let realm = try! Realm()
        let searchText:String = searchBar.text!

        
        if searchText.isEmpty{
            taskArray = realm.objects(Task.self)
        }else{
            taskArray = realm.objects(Task.self).filter("category BEGINSWITH %@", searchText)
        }
        
        tableView.reloadData()
        
    }
    
//    //編集中キャンセル有効
//    func  handleKeyboardWillShowNotification(notification: NSNotification){
//        searchBar.showsCancelButton = true
//    }
    
    //キャンセルたっぷ
    func searchBarCancelButtonClicked(_ searchBar:UISearchBar) {
        searchBar.text = ""
        //searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    //segueで遷移するときに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:inputViewController = segue.destination as! inputViewController
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            let task = Task()
            task.date = Date()
            
            let allTasks = realm.objects(Task.self)
            
            if allTasks.count != 0{
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
            
        }
        
    }
    
}





