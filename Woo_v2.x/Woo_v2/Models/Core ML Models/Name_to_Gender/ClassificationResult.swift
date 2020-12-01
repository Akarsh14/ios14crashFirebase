//
//  ClassificationResult.swift
//  Woo_v2
//
//  Created by Kuramsetty Harish on 19/02/2019.
//  Copyright © 2018 Woo. All rights reserved.
//

struct ClassificationResult {
  enum Gender: String {
    case male = "M"
    case female = "F"

    var string: String {
      switch self {
      case .male:
        return "MALE"
      case .female:
        return "FEMALE"
      }
    }
  }

  let gender: Gender
  let probability: Double
}
