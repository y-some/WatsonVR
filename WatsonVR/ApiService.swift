//
//  ApiService.swift
//  WatsonVR
//
//  Created by Yasuyuki Someya on 2018/04/04.
//  Copyright © 2018年 Yasuyuki Someya. All rights reserved.
//

import UIKit

/// Watson VR APIを扱うクラス
class ApiService {

    /// API連携
    ///
    /// - Parameter image: 解析対象画像イメージ
    func callApi(image: UIImage, completionHandler: @escaping () -> Void) {
        // 解析結果はAppDelegateの変数を経由してSubViewに渡す
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

        // API呼び出し準備（※API Keyをapikey.plistに設定しておく必要があります。キー名は"apikey"。）
        var urlComponents = URLComponents(string: "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/detect_faces")!
        guard let APIKey = fetchApiKey() else {
            print("API Key取得エラー")
            fatalError()
        }
        urlComponents.query = "api_key=" + APIKey + "&version=2016-05-20"
        guard let destURL = urlComponents.url else {
            print ("URLエラー： \n" + urlComponents.path)
            fatalError()
        }
        var request = URLRequest(url: destURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        // API仕様の画像サイズを超えないようにリサイズしてからAPIコールする
        // WatsonVR detect_faces APIの仕様により画像サイズは最大2MG（2016年12月現在）
        guard let resizedImage = image.fixedOrientation()?.resizeImage(maxSize: 2097152) else {
            print("画像リサイズエラー")
            fatalError()
        }
        request.httpBody = UIImageJPEGRepresentation(resizedImage, 1)

        // WatsonAPIコール
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            defer {
                // スコープを抜ける際に全タスクを終了してURLSessionを無効化
                URLSession.shared.finishTasksAndInvalidate()
            }
            
            if error == nil, let data = data {
                do {
                    // APIレスポンス：正常
                    let faceData = try JSONDecoder().decode(FaceData.self, from: data)
                    appDelegate.analyzedFaces = self.interpret(image: resizedImage, parsedData: faceData)
                } catch {
                    // JSONデコードエラー
                    print("JSONデコードエラー：\n" + error.localizedDescription)
                    fatalError()
                }
                // クロージャー実行
                completionHandler()
            } else {
                // APIレスポンスエラー
                print("APIレスポンスエラー：\n" + error.debugDescription)
                fatalError()
            }
            
        }
        task.resume()
        
    }
    
    /// 解析結果のJSONを解釈してAnalyzedFace型の配列で返す
    ///
    /// - parameter image: 元画像
    /// - parameter parsedData: パース後データ
    /// - returns: AnalyzedFace型の配列
    private func interpret(image: UIImage, parsedData: FaceData) -> [AnalyzedFace] {
        let parsedFaces = parsedData.images[0].faces
        // レスポンスのimageFaces要素は配列となっている（複数人が映った画像の解析が可能）。それを抽出しながらAnalyzedFace型の配列に変換する
        return parsedFaces.map {
            let analyzedFace = AnalyzedFace()
            // 性別およびスコア
            if $0.gender.gender == "MALE" {
                analyzedFace.gender = "男性"
            } else {
                analyzedFace.gender = "女性"
            }
            analyzedFace.genderScore = String(floor($0.gender.score * 1000) / 10)
            // 年齢およびスコア
            analyzedFace.ageMin = String($0.age.min)
            if let max = $0.age.max {
                analyzedFace.ageMax = String(max)
            }
            analyzedFace.ageScore = String(floor($0.age.score * 1000) / 10)
            // Identity
            if let identity = $0.identity?.name {
                analyzedFace.identity = identity
            }
            let left = $0.face_location.left
            let top = $0.face_location.top
            let width = $0.face_location.width
            let height = $0.face_location.height
            // 元画像から切り抜いて変数にセット
            analyzedFace.image = cropping(image: image, left: CGFloat(left), top: CGFloat(top), width: CGFloat(width), height: CGFloat(height))
            // 抽出完了
            return analyzedFace
        }
    }
    
    /// 元画像から矩形を切り抜く
    ///
    /// - parameter image: 元画像
    /// - parameter left: x座標
    /// - parameter top: y座標
    /// - parameter width: 幅
    /// - parameter height: 高さ
    /// - returns: UIImage
    private func cropping(image: UIImage, left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) -> UIImage? {
        let imgRef = image.cgImage?.cropping(to: CGRect(x: left, y: top, width: width, height: height))
        return UIImage(cgImage: imgRef!, scale: image.scale, orientation: image.imageOrientation)
    }
    
    /// plistからWatson VRのAPIキーを取得する
    ///
    /// - Returns: APIキーの文字列
    private func fetchApiKey() -> String? {
        // API Keyをapikey.plistに設定しておく必要があります。キー名は"apikey"
        guard let keyFilePath = Bundle.main.path(forResource: "apikey", ofType: "plist") else {
            return nil
        }
        guard let keys = NSDictionary(contentsOfFile: keyFilePath) else {
            return nil
        }
        return keys["apikey"] as? String
    }

}

