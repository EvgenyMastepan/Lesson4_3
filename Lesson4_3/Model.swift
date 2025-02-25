//
//  Model.swift
//  Lesson4_3
//
//  Created by Evgeny Mastepan on 25.02.2025.
//

import Foundation

struct Launch: Codable, Identifiable{
    let id: String
    let name: String
    let date_utc: String
    let details: String?
    let success: Bool?
}
