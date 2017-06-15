//
//  CommentCell.swift
//  Lingo_01
//
//  Created by WuKaipeng on 13/6/17.
//  Copyright © 2017 WuKaipeng. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var profileImg: CircieView!
    @IBOutlet weak var commentTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func didMoveToSuperview() {
        self.layoutIfNeeded()
    }
    
    func configureCell(comment: Comment){
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("\(comment.userName)  ")
            .normal("\(comment.content)")
        self.commentTextView.attributedText = formattedString
        let url = URL(string: "\(comment.imageUrl)")!
        self.profileImg.kf.setImage(with: url)
        
    }
}
