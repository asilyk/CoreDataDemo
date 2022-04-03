//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Alexander on 03.04.2022.
//

import UIKit
import CoreData

class StorageManager {
    // MARK: - Public Properties
    static let shared = StorageManager()
    var taskList: [Task] = []

    // MARK: - Private Properties
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // MARK: - Initializers
    private init() {}

    // MARK: - Public Methods
    func fetchData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            taskList = try context.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
        }
    }

    func save(_ taskName: String) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        
        task.title = taskName
        taskList.append(task)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
}
