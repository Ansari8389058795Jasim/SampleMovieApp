//
//  Connectivity.swift
//  MovieMania
//
//  Created by Jassi on 6/16/22.
//

import UIKit
import Alamofire

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
