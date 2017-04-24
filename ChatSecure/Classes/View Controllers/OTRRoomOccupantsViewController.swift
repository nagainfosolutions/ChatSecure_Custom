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
import AFNetworking

public class OTRRoomOccupantsViewController: UIViewController {
    
    let tableView = UITableView(frame: CGRectZero, style: .Plain)
    //var viewHandler:OTRYapViewHandler?
//    var account: OTRAccount!
    var roomKey: String!
    var members: [[AnyObject]]?
    
    public init(roomKey:String) {
        super.init(nibName: nil, bundle: nil)
        //viewHandler = OTRYapViewHandler(databaseConnection: databaseConnection)
       // viewHandler?.delegate = self
        //viewHandler?.setup(DatabaseExtensionName.GroupOccupantsViewName.name(), groups: [roomKey])
        self.roomKey = roomKey
//        if let appDelgate = UIApplication.sharedApplication().delegate as? OTRAppDelegate {
//            account = appDelgate.getDefaultAccount()
//        }
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
        self.getRoomUsers()
    }
    
    func getRoomUsers() {
        guard let baseUrl = NSURL(string: "http://ec2-54-169-209-47.ap-southeast-1.compute.amazonaws.com:5285") else {
            return
        }
        guard let roomId = roomKey.componentsSeparatedByString("@").first else {
            return
        }
        guard let roomDomain = roomKey.componentsSeparatedByString("@").last else {
            return
        }
        let manager = AFHTTPSessionManager(baseURL: baseUrl)
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        let params = ["key": "secret", "command": "get_room_affiliations", "args": [roomId, roomDomain]]
        manager.POST("api/admin/", parameters: params, progress: { (progress) in
            
            }, success: { (task, response) in
                if let mem = response as? [[AnyObject]] {
                    if self.members == nil {
                        self.members =  [[AnyObject]]()
                    }
                    self.members?.removeAll()
                    self.members?.appendContentsOf(mem)
                    self.tableView.reloadData()
                }
            }) { (task, error) in
                
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadData), name: OTRXMPPUserDetailsFetchedNotification, object: nil)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: OTRXMPPUserDetailsFetchedNotification, object: nil)
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
}

//extension OTRRoomOccupantsViewController:OTRYapViewHandlerDelegateProtocol {
//    public func didSetupMappings(handler: OTRYapViewHandler) {
//        self.tableView.reloadData()
//    }
//    
//    public func didReceiveChanges(handler: OTRYapViewHandler, sectionChanges: [YapDatabaseViewSectionChange], rowChanges: [YapDatabaseViewRowChange]) {
//        //TODO: pretty animations
//        self.tableView.reloadData()
//    }
//}

extension OTRRoomOccupantsViewController:UITableViewDataSource {
    //Int and UInt issue https://github.com/yapstudios/YapDatabase/issues/116
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        if let sections = self.viewHandler?.mappings?.numberOfSections() {
//            return Int(sections)
//        }
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let rows = self.viewHandler?.mappings?.numberOfItemsInSection(UInt(section)) {
//            return Int(rows)
//        }
        if let rows = self.members {
            return rows.count
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        if let member = self.members?[indexPath.row] where member.count > 0 {
            let placeHolder = (member[2] as? String) == "member" ? "" : "(Admin)"
            if let user = OTRAccount.fetchUserWithUsernameOrUserId("\(member.first!)") as? [String: AnyObject] where user["full_name"] != nil {
                cell.textLabel?.text = "\(user["full_name"]!) \(placeHolder)"
            } else {
                cell.textLabel?.text = "Unknown buddy \(placeHolder)"
            }
        } else {
            cell.detailTextLabel?.text = ""
            cell.textLabel?.text = ""

        }
//        if let roomOccupant = self.viewHandler?.object(indexPath) as? OTRXMPPRoomOccupant {
//            let roomUserId = (roomOccupant.realJID ?? roomOccupant.jid!).componentsSeparatedByString("@").first
//            if account.userId == roomUserId {
//                cell.textLabel?.text = "You"
//            } else {
//                if let user = OTRAccount.fetchUserWithUsernameOrUserId(roomUserId) as? [String: AnyObject] where user["full_name"] != nil {
//                    cell.textLabel?.text = "\(user["full_name"]!)"
//                } else {
//                    cell.textLabel?.text = "Unknown buddy"
//                }
//            }
//        } else {
//            cell.detailTextLabel?.text = ""
//            cell.textLabel?.text = ""
//        }
        
        
        
        
        cell.selectionStyle = .None
        
        return cell
    }
}

extension OTRRoomOccupantsViewController:UITableViewDelegate {
    
}
