//
//  ResultTableViewCell.swift
//  WatsonVR
//
//  Created by Yasuyuki Someya on 2016/12/17.
//  Copyright © 2016年 Yasuyuki Someya. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var genderNameLabel: UILabel!
    @IBOutlet weak var genderScoreLabel: UILabel!
    @IBOutlet weak var ageRangeLabel: UILabel!
    @IBOutlet weak var ageScoreLabel: UILabel!
    @IBOutlet weak var identityLabel: UILabel!

    /// セルの内容をセット
    ///
    /// - parameter data: 解析結果
    func setData(data: AnalyzedFace) {
        faceImageView.image = data.image
        genderNameLabel.text = "性別：" + data.gender
        genderScoreLabel.text = "　　　確信度：" + data.genderScore + "%"
        var ageRangeText = "年齢："
        ageRangeText += data.ageMin + "才以上 "
        if let ageMax = data.ageMax {
            ageRangeText += ageMax + "才以下"
        }
        ageRangeLabel.text = ageRangeText
        ageScoreLabel.text = "　　　確信度：" + data.ageScore + "%"
        identityLabel.text = data.identity
    }
    
}
