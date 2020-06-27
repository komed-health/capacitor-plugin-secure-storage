//
//  KomedDefinitions.swift
//  Komed Health
//  Copyright © 2019 Komed Health. All rights reserved.
//

import Foundation

// API CONSTS
let API_VERSION_URL_STRING = "/api/v1";
let API_END_POINT_NOTIFICATIONS_BASE = "/notifications/"
let API_END_POINT_UNSEEN_NOTIFICATIONS = API_END_POINT_NOTIFICATIONS_BASE + "unseen"
let API_END_POINT_REGISTER_PUSH = API_END_POINT_NOTIFICATIONS_BASE + "push-subscription"
let API_END_POINT_MARK_AS_DELIVERED = API_END_POINT_NOTIFICATIONS_BASE + "mark-as-delivered"

let SESSION_COOKIE_NAME = "connect.sid"
// This name has be set in the project "Capabilities -> App Groups"
let STORAGE_SUITE_NAME = "group.com.komedhealth.frontend"
// This must match the FE key!
let KEY_SHOWN_NOTIFICATIONS: String = "com.komedhealth.frontend.shown-notifications"
// These keys are defined (and values stored) on FE
// FE Key for getting the logged in user stored on FE
let KEY_LOGGED_IN_USER: String = "com.komedhealth.frontend.loggedInUser"
// FE Keys for stored team to get the base URL
let KEY_TEAMS_STORAGE = "com.komed-health.frontend.teams"
let KEY_CURRENT_TEAM_INDEX = "com.komedhealth.frontend.current-team-index"

// iOS internal key to store the session cookie
let KEY_SESSION_COOKIE_STORAGE = "com.komedhealth.ios.cookie"
// iOS internal service key for keychain
let KEY_KEYCHAIN_SERVICE: String = "komedSecureStorage"
// iOS internal key for VoIP token
let KEY_DEVICE_VOIP_TOKEN: String = "com.komedhealth.ios.voiptoken"
let KEY_DEVICE_APN_TOKEN: String = "com.komedhealth.ios.apntoken"

// Push attribute keys
let PUSH_KEY_APS: String = "aps"
let PUSH_KEY_BADGE: String = "badge"
let PUSH_KEY_UNSEEN_NOTIFICATION_IDS: String = "unseenNotificationIds"
let PUSH_KEY_CONTENT_AVAILABLE: String = "content-available"

// GROUP DATA
// this needs to be defined in all targets as "App Groups"
let KOMED_GROUP_DATA_KEY_NAME: String = "group.com.komedhealth.frontend"
let DATA_KEY_BASEURL: String = "komed_data_baseurl"
let DATA_KEY_SESSION_COOKIE: String = "komed_data_session_cookie"

// Arguments for the keychain queries
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
let kSecAttrAccessibleValue = NSString(format: kSecAttrAccessible)

// Keys for encryption, from FE
let SECURE_STORAGE_KEY_POSTFIX: String = "-key"
let SECURE_STORAGE_IV_POSTFIX: String = "-iv"
let SECURE_STORAGE_KEY_PASSWORD_PREFIX: String = "password_secure_key_fix_value"
let SECURE_STORAGE_IV_PASSWORD_PREFIX: String = "password_secure_iv_fix_value"

// Shared object attributes to parse data
let ATTR_ID: String = "id"
let ATTR_NOTIFICATION_TITLE: String = "title"
let ATTR_NOTIFICATION_BODY: String = "body"
let ATTR_CHAT: String = "chat"
let ATTR_CHAT_ID: String = "chatId"
let ATTR_CHAT_TYPE: String = "chatType"
let ATTR_CHAT_TOPIC: String = "topic"
let ATTR_CHAT_PATIENT: String = "patient"
let ATTR_GIVEN_NAME: String = "givenName"
let ATTR_FAMILY_NAME: String = "familyName"
let ATTR_MESSAGE: String = "message"
let ATTR_TYPE: String = "type"
let ATTR_MESSAGE_TEXT: String = "text"
let ATTR_MESSAGE_CREATED: String = "created"
let ATTR_USERS: String = "users"
let ATTR_DISPLAY_NAME: String = "displayName"


enum ChatType: String {
    case Group = "group"
    case Direct = "direct"
    case Patient = "patient"
}
/**
 * LocalNotification object to display notification
 */
struct LocalNotification {
    var id: String?
    var title: String?
    var body: String?
    var data: NSDictionary? // chat is stored as data, decoded JSON data
    var message: NSDictionary? // message data, decoded JSON data
    
    init(id: String? = nil,
         title: String? = nil,
         body: String? = nil,
         data: NSDictionary? = nil,
         message: NSDictionary? = nil) {
        
        self.id = id
        self.title = title
        self.body = body
        self.data = data
        self.message = message
    }
    
    init(notification: LocalNotification) {
        self.id = notification.id
        self.title = notification.title
        self.body = notification.body
        self.data = notification.data
        self.message = notification.message
    }
}

/**
 * Data content from push notification
 */
struct KomedPushContent {
    let unseenNotificationIds: [String]
    let badge: Int?
    
    init(unseenNotifications: [String], badge: Int) {
        self.unseenNotificationIds = unseenNotifications
        self.badge = badge
    }
}
