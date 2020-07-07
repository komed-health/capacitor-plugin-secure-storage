import Foundation
import Capacitor
//import SAMKeychain

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@objc(CapacitorSecureStoragePlugin)
public class CapacitorSecureStoragePlugin: CAPPlugin {
    var service: String = ""
    var store: KomedSecureKeyChainDataStorage = KomedSecureKeyChainDataStorage()
    
    @objc func initPlugin(_ call: CAPPluginCall) {
        NSLog("SecureStorage, initPlugin...")
    }
    
    @objc func get(_ call: CAPPluginCall) {
        NSLog("SecureStorage, get...")
        let key: String? = call.getString("key")
        NSLog("SecureStorage, get...key: \(key)")
        DispatchQueue.global(qos: .background).async {
            do {
                var value = self.store.loadFromKeyChain(key: key!)
                call.success(["value": value])
            } catch {
                print("Unexpected error: \(error).")
                call.reject("Failure in SecureStorage.get()")
            }
        }
    }
    
    @objc func set(_ call: CAPPluginCall) {
        NSLog("SecureStorage, set...")
        let key: String? = call.getString("key")
        let value: String? = call.getString("value")
        NSLog("SecureStorage, set...key: \(key), value: \(value)")
        DispatchQueue.global(qos: .background).async {
            do {
                try self.store.saveToKeyChain(key: key!, data: value!)
                call.success()
            } catch {
                print("Unexpected error: \(error).")
                call.reject("Failure in SecureStorage.set()")
            }
        }
    }
    
    @objc func remove(_ call: CAPPluginCall) {
        NSLog("SecureStorage, remove...")
        let key: String? = call.getString("key")

        NSLog("SecureStorage, set...key: \(key)")
        DispatchQueue.global(qos: .background).async {
            do {
                try self.store.deleteKeychainItem(key: key!)
                call.success()
            } catch {
                print("Unexpected error: \(error).")
                call.reject("Failure in SecureStorage.set()")
            }
        }
    }
    
    @objc func clear(_ call: CAPPluginCall) {
        NSLog("SecureStorage, clear...")
        DispatchQueue.global(qos: .background).async {
            do {
                try self.store.clear()
                call.success()
            } catch {
                print("Unexpected error: \(error).")
                call.reject("Failure in SecureStorage.clear()")
            }
        }
    }
    
    @objc func keys(_ call: CAPPluginCall) {
        NSLog("SecureStorage, keys...")
        DispatchQueue.global(qos: .background).async {
            do {
//                try self.store.keys()
                call.success()
            } catch {
                print("Unexpected error: \(error).")
                call.reject("Failure in SecureStorage.clear()")
            }
        }
    }
}
