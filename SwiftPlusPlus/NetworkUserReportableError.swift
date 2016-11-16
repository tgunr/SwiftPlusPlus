//
//  NetworkUserReportableError.swift
//  SwiftPlusPlus
//
//  Created by Andrew J Wagner on 4/24/16.
//  Copyright © 2016 Drewag LLC. All rights reserved.
//

public struct NetworkUserReportableError: UserReportableError {
    public enum `Type` {
        case unauthorized
        case noInternet
        case notFound
        case `internal`(message: String)
        case user(message: String)
    }

    let source: String
    public let operation: String
    public let type: Type
    public let otherInfo: [String : String]?

    public init(source: String, operation: String, type: Type) {
        self.source = source
        self.operation = operation
        self.type = type
        self.otherInfo = nil
    }

    public init(source: String, operation: String, error: NSError) {
        self.source = source
        self.operation = operation
        self.otherInfo = nil
        if error.domain == "NSURLErrorDomain" && error.code == -1009 {
            self.type = .noInternet
        }
        else {
            self.type = .internal(message: error.localizedDescription)
        }
    }

    public init?(source: String, operation: String, response: HTTPURLResponse?, data: Data?) {
        self.source = source
        self.operation = operation
        if let response = response {
            switch response.statusCode ?? 0 {
            case 404:
                self.type = .notFound
                self.otherInfo = nil
            case 401:
                self.type = .unauthorized
                self.otherInfo = nil
            case let x where x >= 400 && x < 500:
                if let data = data {
                    (self.type, self.otherInfo) = NetworkUserReportableError.typeAndOtherInfo(fromData: data, andResponse: response)
                }
                else {
                    self.type = .user(message: "Invalid request")
                    self.otherInfo = nil
                }
            case let x where x >= 500 && x < 600:
                if let data = data {
                    (self.type, self.otherInfo) = NetworkUserReportableError.typeAndOtherInfo(fromData: data, andResponse: response)
                }
                else {
                    self.type = .internal(message: "Unknown error")
                    self.otherInfo = nil
                }
            default:
                return nil
            }
        }
        else {
            return nil
        }
    }

    public var alertTitle: String {
        switch self.type {
        case .user:
            return "Problem \(self.operation)"
        case .internal:
            return "Internal Error"
        case .noInternet:
            return "No Interent Connection"
        case .unauthorized:
            return "Unauthorized"
        case .notFound:
            return "Endpoint not found"
        }
    }

    public var alertMessage: String {
        switch self.type {
        case .internal(let message):
            return "Please try again. If the problem persists please contact support with the following description: \(message)"
        case .user(let message):
            return message
        case .noInternet:
            return "Please make sure you are connected to the internet and try again"
        case .unauthorized:
            return "You have been signed out. Please sign in again."
        case .notFound:
            return "Please try again. If the problem persists please contact support"
        }
    }
}

private extension NetworkUserReportableError {
    static func typeAndOtherInfo(fromData data: Data, andResponse response: HTTPURLResponse) -> (type: Type, otherInfo: [String:String]?){
        let encoding: String.Encoding
        if let encodingName = response.textEncodingName {
            encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingName as CFString!)))
        }
        else {
            encoding = String.Encoding.utf8
        }
        if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
            , let dict = json as? [String:String]
            , let message = dict["message"]
        {
            return (type: .user(message: message ?? ""), otherInfo: dict)
        }
        else {
            let string = String(data: data, encoding: encoding)
            return (type: .user(message: string ?? ""), otherInfo: nil)
        }
    }
}
