//
//  TwitterCell.swift
//  swiftでtwitterclient app
//
//  Created by 有村 琢磨 on 2015/02/17.
//  Copyright (c) 2015年 takuma arimura. All rights reserved.
//

import UIkit

class Twittercell: UITableViewCell {
    
    @IBOutlet var twitterIqon : UIImageView!
    @IBOutlet var twitterIDLabel : UITextView!
    @IBOutlet var twitterNameLabel : UILabel!
    @IBOutlet var tweetTextView : UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
