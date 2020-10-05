//
//  PostTableViewCell.swift
//  reignposts
//
//  Created by Daniel Durán Schütz on 1/10/20.
//

import Foundation
import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cell_title: UILabel!
    @IBOutlet weak var cell_author_create_at: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
