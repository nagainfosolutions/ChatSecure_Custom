//
//  OTRSignalTest.swift
//  ChatSecure
//
//  Created by David Chiles on 8/2/16.
//  Copyright © 2016 Chris Ballinger. All rights reserved.
//

import XCTest
@testable import ChatSecureCore

class OTRSignalTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetupSignal() {
        let ourDatabaseManager = OTRTestDatabaseManager.setupDatabaseWithName(#function)
        let otherDatbaseManager = OTRTestDatabaseManager.setupDatabaseWithName("\(#function)-other")
        
        let ourAccount = TestXMPPAccount()
        ourAccount.username = "ourAccount@something.com"
        let otherAccount = TestXMPPAccount()
        otherAccount.username = "otherAccount@something.com"
        
        let ourDatabaseConnection = ourDatabaseManager.newConnection()!
        let otherDatabaseConnection = otherDatbaseManager.newConnection()!
        
        ourDatabaseConnection.readWriteWithBlock { (transaction) in
            ourAccount.saveWithTransaction(transaction)
        }
        otherDatabaseConnection.readWriteWithBlock { (transaction) in
            otherAccount.saveWithTransaction(transaction)
        }
        
        let ourEncryptionManager = try! OTRAccountSignalEncryptionManager(accountKey: ourAccount.uniqueId, databaseConnection: ourDatabaseConnection)
        let ourOutgoingBundle = ourEncryptionManager.generateOutgoingBundle(10)
        
        let otherEncryptionManager = try! OTRAccountSignalEncryptionManager(accountKey: otherAccount.uniqueId, databaseConnection: otherDatabaseConnection)
        
        otherDatabaseConnection.readWriteWithBlock { (transaction) in
            let buddy = OTRBuddy()
            buddy.accountUniqueId = otherAccount.uniqueId
            buddy.username = ourAccount.username
            buddy.saveWithTransaction(transaction)
            
            let device = OTROMEMODevice(deviceId: NSNumber(unsignedInt:ourOutgoingBundle!.bundle.deviceId), trustLevel: .TrustedTofu, parentKey: buddy.uniqueId, parentCollection: OTRBuddy.collection(), publicIdentityKeyData: nil, lastSeenDate:nil)
            device.saveWithTransaction(transaction)
        }
        ourDatabaseConnection.readWriteWithBlock { (transaction) in
            let buddy = OTRBuddy()
            buddy.accountUniqueId = ourAccount.uniqueId
            buddy.username = otherAccount.username
            buddy.saveWithTransaction(transaction)
            
            let device = OTROMEMODevice(deviceId: NSNumber(unsignedInt:otherEncryptionManager.registrationId), trustLevel: .TrustedTofu, parentKey: buddy.uniqueId, parentCollection: OTRBuddy.collection(), publicIdentityKeyData: nil, lastSeenDate:nil)
            device.saveWithTransaction(transaction)
        }
        
        XCTAssertNotNil(ourOutgoingBundle,"Created our bundle")
        //At this point int 'real' world we could post or outgoing bundle to OMEMO
        
        //Convert our outgoing bundle to an incoming bundle
        let preKeyInfo = ourOutgoingBundle!.preKeys.first!
        let incomingBundle = OTROMEMOBundleIncoming(bundle: ourOutgoingBundle!.bundle, preKeyId: preKeyInfo.0, preKeyData: preKeyInfo.1)
        // 'Other' device is now able to send messages to 'Our' device
        otherEncryptionManager.consumeIncomingBundle(ourAccount.username, bundle: incomingBundle)
        
        let firstString = "Hi buddy"
        let data = firstString.dataUsingEncoding(NSUTF8StringEncoding)!
        let encryptedData = try! otherEncryptionManager.encryptToAddress(data, name: ourAccount.username, deviceId: incomingBundle.bundle.deviceId)
        XCTAssertNotNil(encryptedData, "Created encrypted data")
        print("\(encryptedData.data)")
        
        // In the real world this encrypted data would be sent over the wire
        let decryptedData = try! ourEncryptionManager.decryptFromAddress(encryptedData.data, name: otherAccount.username, deviceId: otherEncryptionManager.registrationId)
        let secondString = NSString(data: decryptedData, encoding: NSUTF8StringEncoding) as! String
        
        XCTAssertEqual(firstString, secondString,"Equal Strings")
    
    }
    
}
