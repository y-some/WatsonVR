//
//  FaceData.swift
//  WatsonVR
//
//  Created by Yasuyuki Someya on 2018/01/02.
//  Copyright © 2018年 Yasuyuki Someya. All rights reserved.
//

/// Watson VR APIのレスポンスをCodableに準拠させた構造体
struct FaceData: Codable {
    struct Faces: Codable {
        struct Face: Codable {
            struct Identity: Codable {
                let name: String?
                let type_hierarchy: String?
                let score: Double?
            }
            struct Age: Codable {
                let min: Int
                let max: Int?
                let score: Double
            }
            struct Gender: Codable {
                let gender: String
                let score: Double
            }
            struct FaceLocation: Codable {
                let left: Int
                let height: Int
                let top: Int
                let width: Int
            }
            let identity: Identity?
            let age: Age
            let gender: Gender
            let face_location: FaceLocation
        }
        let faces: [Face]
    }
    let images_processed: Int
    let images: [Faces]
}

/* レスポンスサンプル
{
"images_processed" : 1,
"images" : [
    {
        "faces" : [
            {
                "identity" : {
                    "name" : "Barack Obama",
                    "type_hierarchy" : "\/people\/politicians\/democrats\/barack obama",
                    "score" : 0.98901300000000003
                },
                "age" : {
                    "min" : 35,
                    "max" : 44,
                    "score" : 0.39339299999999999
                },
                "gender" : {
                    "gender" : "MALE",
                    "score" : 0.99330700000000005
                },
                "face_location" : {
                    "left" : 73,
                    "height" : 78,
                    "top" : 22,
                    "width" : 62
                }
            }
        ]
    }
]
}
*/
