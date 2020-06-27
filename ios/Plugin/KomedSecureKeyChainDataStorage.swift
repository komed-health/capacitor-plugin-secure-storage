//
//  KomedSecureKeyChainDataStorage.swift
//  KomedPushExtension
//
//  Created by Laszlo Blum on 2020. 06. 24.
//

import Foundation
import CommonCrypto

class KomedSecureKeyChainDataStorage : NSObject {
    var appDefaults: UserDefaults!
    let keychainAccess: CFString = kSecAttrAccessibleAfterFirstUnlock
    let appBundleId: String = "com.komedhealth.frontend"
    let appIdPrefix: String = "6UV97C79YF"
    
    struct copy_from_AES256 {
        static let SECURE_KEY_LENGTH = 16;
        static let SECURE_IV_LENGTH = 8;
        static let PBKDF2_ITERATION_COUNT = 1001;
    }
    
    override init() {
        appDefaults = UserDefaults.init(suiteName: STORAGE_SUITE_NAME)
    }
    
    public func getDefaultsStorage() ->  UserDefaults {
        return self.appDefaults
    }
    
    public func loadIntValFromDefaults(key: String) -> Int {
        return self.appDefaults.integer(forKey: key)
    }
    
    public func loadJsonDataFromDefaults(key: String) -> Any! {
        let jsonRawData = self.appDefaults.object(forKey: key)
        return jsonRawData
    }
    
    /**
     * Loads and decrypt encrypted data from UserDefaults as a JSON object.
     */
    public func loadAndDecryptDataFromDefaults(key: String) -> Any! {
        // Encrypted data is always stored as a string
        if var encryptedStr = loadStringValFromDefaults(key: key) {
            // After a looooong debugging session these two lines finally convert the data into decryptable format
            // String has extra " at the beginning and end, remove those
            encryptedStr = encryptedStr.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range:nil)
            // String needs to be utf8 encoded
            encryptedStr = encryptedStr.utf8()!
            // decrypt data
            let secureKey: String = getSecureKey(baseKey: key);
            let secureIV: String = getSecureIV(baseKey: key);
            let decryptedString: String = AES256CBC.decryptString(encryptedStr, password: secureKey, iv: secureIV) ?? ""
            // Transform decrypted string data to JSON object data
            return KomedUtils.jsonStringToData(from: decryptedString)
        }
        return nil
    }

    /**
     * Transforms data into JSON and encrypts, and saves it to UserDefaults storage under given key.
     * Same key is used for encrypting data.
     * @param data Data to be encrypted
     * @param key for encryption and saving
     */
    public func encryptAndSaveToDefaults(data: Any, key: String) {
        let secureKey: String = getSecureKey(baseKey: key);
        let secureIV: String = getSecureIV(baseKey: key);
        if let dataAsJson: String = KomedUtils.dataToJsonString(from: data) {
            // returns a base64EncodedString
            var encryptedData: String = AES256CBC.encryptString(dataAsJson, password: secureKey, iv: secureIV) ?? ""
            // This is not nice but absolutely needed in order for native storage plugin (on JS side),
            // which tries to convert the string into JSON and that will throw exception without these extra '\"' pre- and post fixes.
            // (the triple """ handles the string inside without a need to escape chars)
            encryptedData =
            """
            \"\(encryptedData)\"
            """
            saveToDefaults(key: key, value: encryptedData)
        }
    }

    /**
     * Returns a saved secure key value from the keychain. If no entry exists a new secure key is generated.
     * @param baseKey Postfix "-key" will be appended at the end of this key
     */
    public func getSecureKey(baseKey: String) -> String {
        let fullStorageKey: String = baseKey + SECURE_STORAGE_KEY_POSTFIX;
        let savedKey: String = loadFromKeyChain(key: fullStorageKey) ?? "";
        
        if (savedKey.isEmpty) {
            // No saved key, generate new
            let key: String = generateNewSecureKey();
            saveToKeyChain(key: fullStorageKey, data: key)
            return key;
        } else {
            return savedKey;
        }
    }
    
    // ENCRYPT / DECRYPT USING AES256 PLUGIN CLASS (PBKDF2), bypassing the AES256.swift cordova plugin interface
    private func generateNewSecureKey() -> String {
        let passwordSecureKey: String = SECURE_STORAGE_KEY_PASSWORD_PREFIX + newDateStr()
        let secureKey: String? = PBKDF2.pbkdf2(hash: CCPBKDFAlgorithm(kCCPRFHmacAlgSHA1), password: passwordSecureKey, salt: AES256CBC.generateSalt(), keyByteCount: copy_from_AES256.SECURE_KEY_LENGTH, rounds: copy_from_AES256.PBKDF2_ITERATION_COUNT)
        return secureKey ?? ""
    }
    
    private func generateNewSecureIV() -> String {
        let passwordSecureIV: String = SECURE_STORAGE_IV_PASSWORD_PREFIX + newDateStr()
        let secureIV: String? = PBKDF2.pbkdf2(hash: CCPBKDFAlgorithm(kCCPRFHmacAlgSHA1), password: passwordSecureIV, salt: AES256CBC.generateSalt(), keyByteCount: copy_from_AES256.SECURE_IV_LENGTH, rounds: copy_from_AES256.PBKDF2_ITERATION_COUNT)
        return secureIV ?? ""
    }

    /**
     * Returns a saved IV from the secure storage. If no entry exists a new secure key is generated.
     * @param baseKey Postfix "-iv" will be appended at the end of this key
     * @throws ERROR_INITIALIZING_SECURE_STORAGE from secureStorage in case there is no secure storage available
     */
    private func getSecureIV(baseKey: String) -> String {
        let fullStorageKey: String = baseKey + SECURE_STORAGE_IV_POSTFIX;
        let savedIV: String = loadFromKeyChain(key: fullStorageKey) ?? "";
        
        if (savedIV.isEmpty) {
            // No saved IV, generate new
            let iv: String = generateNewSecureIV();
            saveToKeyChain(key: fullStorageKey, data: iv)
            return iv;
        } else {
            return savedIV;
        }
    }

    /**
     * Creates a new keychain entry OR updates a current value if already exists
     */
    public func saveToKeyChain(key: String, data: String, useSharedKeyChain: Bool = false) {
        if let dataFromString = data.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            // Keychain query with overwriting default access to "kSecAttrAccessibleAfterFirstUnlock"
            // to allow access when device is locked
            let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, KEY_KEYCHAIN_SERVICE, key, dataFromString, keychainAccess], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue, kSecAttrAccessibleValue])
            
            if(useSharedKeyChain) {
                let sharedAccessGroup = [kSecAttrAccessGroup: appIdPrefix + "." + appBundleId] as [String: Any]
                keychainQuery.addEntries(from: sharedAccessGroup)
            }
            
            // Try adding the keychain item, check the status.
            var status = SecItemAdd(keychainQuery as CFDictionary, nil)
            
            // Duplicated item error is expected when updating existing value.
            if (status != errSecSuccess) {
                // Due to a chance that the existing value has been written with a different kSecAttrAccessible security attribute value (!= kSecAttrAccessibleAfterFirstUnlock) it is safer to delete the old value and add as a new, instead of trying to update the value, which fails if the security access doesn't match the old value.
                if(status == errSecDuplicateItem) {
                    status = deleteKeychainItem(key: key)
                    if (status == errSecSuccess) {
                        // Old item was deleted, now the add should work 100%
                        status = SecItemAdd(keychainQuery as CFDictionary, nil)
                    }
                }
            }
            
            if (status != errSecSuccess) {
                // Unexpected error to log when all attempts failed
                Logger().err("Sec item add/delete failed with status: \(status)")
                if #available(iOS 11.3, *) {
                    if let err = SecCopyErrorMessageString(status, nil) {
                        Logger().err("Sec item add/delete failed: \(err)")
                    }
                }
            }
        }
    }

    /**
     * Loads a string value data from (komed app) keychain with the given key
     */
    public func loadFromKeyChain(key: String, useSharedKeyChain: Bool = false) -> String? {
        // Keychain query limiting result to one item. Do not limit any access value when reading.
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, KEY_KEYCHAIN_SERVICE, key, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        if(useSharedKeyChain) {
            let sharedAccessGroup = [kSecAttrAccessGroup: appIdPrefix + "." + appBundleId] as [String: Any]
            keychainQuery.addEntries(from: sharedAccessGroup)
        }
        
        var dataTypeRef: AnyObject?
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var valueFromKeychain: String?
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                valueFromKeychain = String(data: retrievedData, encoding: String.Encoding.utf8)
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }
        return valueFromKeychain
    }

    /**
     * Removes an item from a keychain for given key
     */
    public func deleteKeychainItem(key: String) -> OSStatus {
        // It's important not to include kSecAttrAccessible attribute here so that in any case the item will be deleted
        let delQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, KEY_KEYCHAIN_SERVICE, key], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue])
        return SecItemDelete(delQuery as CFDictionary)
    }
    
    /**
     * Clears all the items from a keychain
     */
    public func clear() -> OSStatus {
        // It's important not to include kSecAttrAccessible attribute here so that in any case the item will be deleted
        let delQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, KEY_KEYCHAIN_SERVICE], forKeys: [kSecClassValue, kSecAttrServiceValue])
        return SecItemDelete(delQuery as CFDictionary)
    }

    /**
     * Loads a value string from defaults storage
     */
    func loadStringValFromDefaults(key: String) -> String? {
        return self.appDefaults.string(forKey: key)
    }

    /**
     * Saves a string value to user defauls for given key
     */
    func saveToDefaults(key: String, value: String) {
        self.appDefaults.set(value , forKey: key)
        // self.appDefaults.synchronize()
    }
    
    // Gets a current date as string in a date format used in encryption key generation
    private func newDateStr() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        // Must match exactly the same date format as on FE encryption
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.string(from: currentDateTime)
    }
}
