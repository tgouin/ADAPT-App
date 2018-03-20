//
//  APIController.swift
//  Adapt
//
//  Created by Timmy Gouin on 3/12/18.
//  Copyright © 2018 Timmy Gouin. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

typealias ServiceResponse = (JSON?, NSError?) -> Void

extension String {
    var url: String { return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! }
}

class APIController: NSObject {
    // static let rootURL = "http://192.168.1.152:3000"
    static let rootURL = "http://52.53.90.187"
    
    override init() {
        super.init()
        getPlayers()
    }
    
    func createPlayer(player: Player) {
        let url = "\(APIController.rootURL)/players/create?name=\(player.name!.url)&number=\(player.number)&position=\(player.position!.url)&height=\(player.height)&weight=\(player.weight)"
        makeHTTPGetRequest(path: url) { (data, error) in
            guard error == nil else {
                print("Error creating player")
                return
            }
            print("Player successfully created!")
        }
    }
    
    func updatePlayer(player: Player) {
        var url = "\(APIController.rootURL)/players/edit?id=\(player.id)&number=\(player.number)&height=\(player.height)&weight=\(player.weight)"
        if let unwrappedName = player.name {
            url += "&name=\(unwrappedName.url)"
        }
        if let unwrappedPosition = player.position {
            url += "&position=\(unwrappedPosition.url)"
        }
        makeHTTPGetRequest(path: url) { (data, error) in
            guard error == nil else {
                print("Error editing player")
                return
            }
            print("Player successfully edited!")
        }
    }
    
    func deletePlayer(id: Int32) {
        let url = "\(APIController.rootURL)/players/delete?id=\(id)"
        makeHTTPGetRequest(path: url) { (data, error) in
            guard error == nil else {
                print("Error deleting player from server")
                return
            }
            print("Player successfully deleted!")
        }
    }
    
    func getPlayers() {
        var players: [Player] = []
        let url = "\(APIController.rootURL)/players"
        print(url)
        makeHTTPGetRequest(path: url) { (data, error) in
            guard let json = data else { return }
            let array = json.array
            var players: [Player] = []
            let allPlayersFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")
            let allFetchedPlayers:[Player]
            var newPlayerNames: [String] = []
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            do {
                allFetchedPlayers = try appDelegate.dataController.managedObjectContext.fetch(allPlayersFetch) as! [Player]
            } catch {
                fatalError("Failed to fetch players: \(error)")
            }
            array?.forEach({ (jsonPlayer) in
                guard let dict = jsonPlayer.dictionaryObject as? [String: Any] else { return }
                guard let name = dict["name"] as? String else { return }
                newPlayerNames.append(name)
                let playersFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")
                playersFetch.predicate = NSPredicate(format: "name == %@", name)
                let fetchedPlayers:[Player]
                do {
                    fetchedPlayers = try appDelegate.dataController.managedObjectContext.fetch(playersFetch) as! [Player]
                } catch {
                    fatalError("Failed to fetch players: \(error)")
                }
                let player: Player
                if fetchedPlayers.count == 0 {
                    player = NSEntityDescription.insertNewObject(forEntityName: "Player", into: appDelegate.dataController.managedObjectContext) as! Player
                } else if fetchedPlayers.count == 1 {
                    player = fetchedPlayers[0]
                } else {
                    fetchedPlayers.forEach({ (player) in
                        appDelegate.dataController.managedObjectContext.delete(player)
                    })
                    player = NSEntityDescription.insertNewObject(forEntityName: "Player", into: appDelegate.dataController.managedObjectContext) as! Player
                }
                
                player.name = name
               
                if let id = dict["id"] as? Int32 {
                    player.id = id
                }
                if let number = dict["number"] as? Int16 {
                    player.number = number
                }
                if let position = dict["position"] as? String {
                    player.position = position
                }
                if let height = dict["height"] as? Int16 {
                    player.height = height
                }
                if let weight = dict["weight"] as? Double {
                    player.weight = weight
                }
                players.append(player)
            })
            allFetchedPlayers.forEach({ (oldPlayer) in
                var foundName = false
                for i in 0..<newPlayerNames.count {
                    if oldPlayer.name == newPlayerNames[i] {
                        foundName = true
                    }
                }
                if !foundName {
                    appDelegate.dataController.managedObjectContext.delete(oldPlayer)
                }
            })
            do {
                try appDelegate.dataController.managedObjectContext.save()
            } catch {
                print("Unable to save players from server")
            }
            print("got players!!!", players)
        }
    }
    
    func makeHTTPGetRequest(path: String, onCompletion: @escaping ServiceResponse) {
        let request = URLRequest(url: URL(string: path)!)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
            guard error == nil else {
                onCompletion(nil, error as! NSError)
                return
            }
            guard let unwrappedData = data else {
                onCompletion(nil, nil)
                return
            }
            let json = try? JSON(data: unwrappedData)
            guard let unwrappedJSON = json else {
                onCompletion(nil, error as! NSError)
                return
            }
            onCompletion(unwrappedJSON, nil)
            
        })
        task.resume()
    }
}
