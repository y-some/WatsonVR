//
//  MainViewController.swift
//  WatsonVR
//
//  Created by Yasuyuki Someya on 2016/12/17.
//  Copyright © 2016年 Yasuyuki Someya. All rights reserved.
//

import UIKit
import Photos

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // ガイド文言Label
    @IBOutlet weak var guideLabel: UILabel!
    // 選択された画像
    @IBOutlet weak var selectedImageView: UIImageView!
    // 解析中のインジケータ
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: UIViewController - Event
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: IBAction
    
    /// カメラ起動
    @IBAction func launchCamera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            launchImagePicker(type: .camera)
        }
    }
    
    /// 写真選択
    @IBAction func launchPhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            launchImagePicker(type: .photoLibrary)
        }
    }
    
    /// 解析開始
    @IBAction func analyze(_ sender: Any) {
        guard let selectedImage = selectedImageView.image else {
            return
        }
        // API仕様の画像サイズを超えないようにリサイズしてからAPIコールする
        // WatsonVR detect_faces APIの仕様により画像サイズは最大2MG（2016年12月現在）
        guard let resizedImage = selectedImage.fixedOrientation()?.resizeImage(maxSize: 2097152) else {
            print("画像リサイズエラー")
            fatalError()
        }

        //　activityIndicator開始
        self.activityIndicator.startAnimating()
        
        // APIコール
        ApiService().callApi(image: resizedImage) {
            // リクエストは非同期のため画面遷移をmainQueueで行わないとエラーになる
            OperationQueue.main.addOperation(
                {
                    //　activityIndicator停止
                    self.activityIndicator.stopAnimating()
                    
                    // 解析結果はAppDelegateの変数を経由してSubViewに渡す
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    if appDelegate.analyzedFaces.count > 0 {
                        // 顔解析結果あり
                        self.performSegue(withIdentifier: "ShowResult", sender: self)
                    } else {
                        // 顔解析結果なし
                        let actionSheet = UIAlertController(title:"エラー", message: "顔検出されませんでした", preferredStyle: .alert)
                        let actionCancel = UIAlertAction(title: "キャンセル", style: .cancel)
                        actionSheet.addAction(actionCancel)
                        self.present(actionSheet, animated: true, completion: nil)
                    }
                }
            )
        }
        
    }
    
    // MARK: Delegate
    
    /// UIImagePickerControllerDelegate：画像選択時
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] else {
            return
        }
        // 選択画像をImageViewに表示
        selectedImageView.image = image as? UIImage
        // ガイドLabelを非表示に
        guideLabel.isHidden = true
    }

    // MARK: Method

    /// カメラ/フォトライブラリの起動
    ///
    /// - Parameter type: カメラ/フォトライブラリ
    func launchImagePicker(type: UIImagePickerControllerSourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = type
        present(controller, animated: true, completion: nil)
    }
    
}

