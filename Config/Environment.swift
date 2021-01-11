//
//  Environment.swift
//  hrate
//
//  Created by Anselm Joseph on 12/01/21.
//

import Foundation


public enum Environment {
  // MARK: - Keys
  enum Keys {
    enum Plist {
      static let baseURL = "BASE_URL"
    }
  }

  // MARK: - Plist
  private static let infoDictionary: [String: Any] = {
    guard let dict = Bundle.main.infoDictionary else {
      fatalError("Plist file not found")
    }
    return dict
  }()

  // MARK: - Plist values
  static let rootURL: URL = {
    guard let rootURLstring = Environment.infoDictionary[Keys.Plist.baseURL] as? String else {
      fatalError("Base URL not set in plist for this environment")
    }
    guard let url = URL(string: rootURLstring) else {
      fatalError("Root URL is invalid")
    }
    return url
  }()
}
