//
//  OTRRoomOccupantsViewController.swift
//  ChatSecure
//
//  Created by David Chiles on 10/28/15.
//  Copyright © 2015 Chris Ballinger. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

public class OTRRoomOccupantsViewController: UIViewController {
    
    let tableView = UITableView(frame: CGRectZero, style: .Plain)
    var viewHandler:OTRYapViewHandler?
    var account: OTRAccount!
    
    public init(databaseConnection:YapDatabaseConnection, roomKey:String) {
        super.init(nibName: nil, bundle: nil)
        viewHandler = OTRYapViewHandler(databaseConnection: databaseConnection)
        viewHandler?.delegate = self
        viewHandler?.setup(DatabaseExtensionName.GroupOccupantsViewName.name(), groups: [roomKey])
        if let appDelgate = UIApplication.sharedApplication().delegate as? OTRAppDelegate {
            account = appDelgate.getDefaultAccount()
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup Table View
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(self.tableView)
        self.tableView.autoPinEdgesToSuperviewEdges()
    }
    
}

extension OTRRoomOccupantsViewController:OTRYapViewHandlerDelegateProtocol {
    public func didSetupMappings(handler: OTRYapViewHandler) {
        self.tableView.reloadData()
    }
    
    public func didReceiveChanges(handler: OTRYapViewHandler, sectionChanges: [YapDatabaseViewSectionChange], rowChanges: [YapDatabaseViewRowChange]) {
        //TODO: pretty animations
        self.tableView.reloadData()
    }
}

extension OTRRoomOccupantsViewController:UITableViewDataSource {
    //Int and UInt issue https://github.com/yapstudios/YapDatabase/issues/116
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = self.viewHandler?.mappings?.numberOfSections() {
            return Int(sections)
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rows = self.viewHandler?.mappings?.numberOfItemsInSection(UInt(section)) {
            return Int(rows)
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        if let roomOccupant = self.viewHandler?.object(indexPath) as? OTRXMPPRoomOccupant {
            let roomUserId = (roomOccupant.realJID ?? roomOccupant.jid!).componentsSeparatedByString("@").first
            if account.userId == roomUserId {
                cell.textLabel?.text = "You"
            } else {
                if let users = account?.allFriends as? [OTRXMPPBuddy] {
                    let user = users.filter({ (buddy) -> Bool in
                        let buddyUserId = buddy.username.componentsSeparatedByString("@").first
                        return buddyUserId == roomUserId
                    })
                    if user.count > 0 {
                        cell.textLabel?.text = user.first!.displayName
                    } else {
                        cell.textLabel?.text = "Unknown buddy"
                    }
                } else {
                    cell.textLabel?.text = "Unknown buddy"
                }
            }
        } else {
            cell.detailTextLabel?.text = ""
            cell.textLabel?.text = ""
        }
        
        cell.selectionStyle = .None
        
        return cell
    }
}

extension OTRRoomOccupantsViewController:UITableViewDelegate {
    
}
