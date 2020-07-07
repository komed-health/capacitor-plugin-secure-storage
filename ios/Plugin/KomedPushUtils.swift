//
//  KomedUtils.swift
//  Komed Health
//  Copyright © 2019 Komed Health. All rights reserved.
//

import Foundation
import os.log
import os

/**
 * Util methods that can be used as static
 */
class KomedUtils : NSObject {
    let komedDataStorage = KomedSecureKeyChainDataStorage()

    /**
     * Loads the logged in user object set on the FE and extracts and sets the user language for iOS app
     */
    func setLanguageFromStoredUser() {
        if let loggedInUserData = komedDataStorage.loadJsonDataFromDefaults(key: KEY_LOGGED_IN_USER) {
            let loggedInUser = loggedInUserData as! Dictionary<String, AnyObject>
            let lang: String = loggedInUser["language"] as! String
            // FE language comes with a locale, such as de-ch. Strip off the locale part.
            let indexEndOfText = lang.index(lang.startIndex, offsetBy: 2)
            let langWithoutLocale = lang[..<indexEndOfText]
            // Set as current language for app
            UserDefaults.standard.set([langWithoutLocale], forKey: "AppleLanguages")
        } else {
            Logger().warn("Could not get logged in user (language)")
        }
    }
    
    /**
     * Provides a "manual translation" over build in because setting a new language
     * does not take effect until the next app reboot. This method uses current language as soon
     * as it is set. Defaults to English if translation file is not found.
     */
    static func translate(key: String) -> String {
        let lang: String = Locale.preferredLanguages[0] // Gets the selected language
        var langFile = Bundle.main.path(forResource: lang, ofType: "lproj")
        // If provided language is not not found use English by default
        if (langFile == nil) {
            langFile = Bundle.main.path(forResource: "en", ofType: "lproj")
            UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        }

        let bundle = Bundle(path: langFile!)
        // using key as default value if translation is not found
        return bundle?.localizedString(forKey: key, value: key, table: nil) ?? ""
    }
    
    /**
     * Transforms any object to to JSON string data. (used for storing already shown notifications that need to read on FE too)
     */
    static func dataToJsonString(from object: Any) -> String? {
        if object is String {
            return object as? String
        }
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    /**
     * Transforms any object to to JSON string data. (used for storing already shown notifications that need to read on FE too)
     */
    static func jsonStringToData(from jsonString: String) -> Any! {
        if let jsonAsEncodedData = jsonString.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: jsonAsEncodedData, options: [.allowFragments])
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    /**
     * Generates a random number between 10000-100000
     */
    static func generateNotifRandId() -> Int {
        return Int.random(in: 10000 ... 100000);
    }
}

/**
 * Logger utility class
 */
enum LogLevel: Int {
    case DEBUG = 0
    case INFO = 1
    case WARN = 2
    case ERROR = 3
}

/**
 * Logging helper. Can also write logs to file "<doc-dir>/log.txt".
 */
class Logger {
    
    var logFile: URL!
    let logToFile = false   // change to true if logging to file is needed
    var logLevel: LogLevel = .DEBUG // default log level
    
    @available(iOS 10.0, *)
    static let ui_log = OSLog(subsystem: "com.komed.komed-ios", category: "UI")
    
    init() {
        let defaultDocDir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
        logFile = defaultDocDir.appendingPathComponent("log.txt")
    }
    
    func debug(_ aMsg: String) {
        if(logLevel == .DEBUG) {
            if #available(iOS 10.0, *) {
                os_log("*DEBUG*: %@", log: Logger.ui_log, type: .debug, aMsg)
            } else {
                // Fallback on earlier versions
                print(aMsg)
            }
            if(logToFile) {
                do {
                    try "\(Date()): DEBUG - \(aMsg) ".appendLineToURL(fileURL: logFile)
                }
                catch {
                    print("Could not write to file")
                }
            }
        }
    }
    
    func info(_ aMsg: String) {
        if(logLevel == .DEBUG || logLevel == .INFO) {
            if #available(iOS 10.0, *) {
                os_log("*INFO*: %@", log: Logger.ui_log, type: .info, aMsg)
            } else {
                // Fallback on earlier versions
                print(aMsg)
            }
            if(logToFile) {
                do {
                    try "\(Date()): INFO - \(aMsg) ".appendLineToURL(fileURL: logFile)
                }
                catch {
                    print("Could not write to file")
                }
            }
        }
    }
    
    func warn(_ aMsg: String) {
        if(logLevel != .ERROR) {
            if #available(iOS 10.0, *) {
                os_log("*WARN*: %@", log: Logger.ui_log, type: .fault, aMsg)
            } else {
                // Fallback on earlier versions
                print(aMsg)
            }
            if(logToFile) {
                do {
                    try "\(Date()): WARN - \(aMsg) ".appendLineToURL(fileURL: logFile)
                }
                catch {
                    print("Could not write to file")
                }
            }
        }
    }
    
    func err(_ aMsg: String) {
        if #available(iOS 10.0, *) {
            os_log("*ERROR*: %@", log: Logger.ui_log, type: .error, aMsg)
        } else {
            // Fallback on earlier versions
            print(aMsg)
        }
        if(logToFile) {
            do {
                try "\(Date()): ERR - \(aMsg) ".appendLineToURL(fileURL: logFile)
            }
            catch {
                print("Could not write to file")
            }
        }
    }
}

// Helper extensions for common data types
extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
    
    // UTF8 encoding a string
    func utf8() -> String? {
        if let data = self.data(using: .utf8) {
            // also repairs the data and inserts the “�” character (a replacement character) if it can’t decode the data
            return String(decoding: data, as: UTF8.self)
        }
        return nil
    }
    
    // Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    // Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
    
    func printJSON()
    {
        if let JSONString = String(data: self, encoding: String.Encoding.utf8)
        {
            print(JSONString)
        }
    }
}
