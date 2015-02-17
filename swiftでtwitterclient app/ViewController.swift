//
//  ViewController.swift
//  swiftでtwitterclient app
//
//  Created by 有村 琢磨 on 2015/02/17.
//  Copyright (c) 2015年 takuma arimura. All rights reserved.
//

import UIKit
import Social
import Accounts

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSURLConnectionDelegate{
    
    var myComposeView : SLComposeViewController?
    var myTwitterButton : UIButton?
    
    var tweetArray :NSMutableArray!
    @IBOutlet var timelineTableview : UITableView!
    
    
    @IBAction func tweetButton(sender : AnyObject) {
        myComposeView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        self.presentViewController(myComposeView!, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.twitterTimeLine()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refresh(){
        self.twitterTimeLine()
    }
    
    
    
    func twitterTimeLine(){
        
        //tweetArrayの初期化
        tweetArray = NSMutableArray()
        //ACAccountStoreの初期化
        var accountStore : ACAccountStore! = ACAccountStore()
        let twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        //ユーザーにtiwtter情報を使うことの許可を得る
        
        //        let handler: ACAccountStoreRequestAccessCompletionHandler = {
        //            granted, error in
        //            if(!granted){
        //                NSLog("ユーザーがアクセスを拒否しました")
        //                return
        //            }
        //
        //            let twitterAccounts = accountStore.accountsWithAccountType(twitterAccountType)
        //            NSLog("twitterAccounts = \(twitterAccounts)")
        //            if(twitterAccounts.count > 0){
        //                let account = twitterAccounts[0] as ACAccount
        //                NSLog("account = \(account)")
        //            }
        //        }
        accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil){
            
            granted, error in
            
            if granted == true {
                var arrayOfAccounts = accountStore.accountsWithAccountType(twitterAccountType!)
                
                if arrayOfAccounts.count > 0{
                    var twitterAccount :ACAccount = arrayOfAccounts.last? as ACAccount
                    var requestAPI : NSURL = NSURL(string:"https://api.twitter.com/1.1/statuses/home_timeline.json")!
                    
                    //NSMutableDictionaryの初期化
                    var parameters :NSMutableDictionary = NSMutableDictionary()
                    parameters.setValue("100", forKey: "count")
                    parameters.setValue("1", forKey: "include_entities")
                    
                    //リクエストを生成
                    var post :SLRequest = SLRequest(forServiceType: SLServiceTypeTwitter,
                        requestMethod: SLRequestMethod.GET,
                        URL: requestAPI,
                        parameters: parameters)
                    //リクエストに認証情報を付加
                    post.account = twitterAccount
                    //ステータスバーのActivity Indicatorを開始
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    //リクエストを発行
                    post.performRequestWithHandler({response, urlResponse, urlerror
                        
                        in
                        
                        var arrayForRemoteData = NSJSONSerialization.JSONObjectWithData(response, options: NSJSONReadingOptions(), error: nil) as NSMutableArray
                        println(arrayForRemoteData)
                        self.tweetArray = arrayForRemoteData
                        println(self.tweetArray)
                        
                        if (self.tweetArray.count != 0) {
                            dispatch_async(dispatch_get_main_queue(), {self.timelineTableview.reloadData()})
                        }
                        
                    })
                }
                
                //tweet取得完了したらActivity Indicatorを終了
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            } else {
                NSLog("%@", error)
            }
        }
    }
    
    //書かなくてよい
    //
    //func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    //    return 1
    //}
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //一旦標準のUITableViewCellにて表示
        let cell :UITableViewCell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as UITableViewCell
        if (tweetArray.count > 0) {
            var tweet = tweetArray[indexPath.row] as NSDictionary
            var userInfo :NSDictionary = tweet["user"] as NSDictionary
            cell.textLabel?.text = userInfo["screen_name"] as NSString
            
        } else {
            //FIX: 読み込まれるまで、くるくるを表示させたい所
            //なくても良い
        }
        return cell
    }
}