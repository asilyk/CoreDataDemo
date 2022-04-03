//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Alexander on 03.04.2022.
//

import CoreData

class StorageManager {
    // MARK: - Public Properties
    static let shared = StorageManager()
    var taskList: [Task] = []

    // MARK: - Private Properties
    private var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "CoreDataDemo")
            container.loadPersistentStores(completionHandler: { (_, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
    }()

    private var context:  NSManagedObjectContext {
        persistentContainer.viewContext
    }

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
        
        saveContext()
    }

    func resave(_ newTaskName: String, by index: Int) {
        taskList[index].title = newTaskName

        saveContext()
    }

    func delete(by index: Int)
    {
        context.delete(taskList[index])
        taskList.remove(at: index)

        saveContext()
    }

    // MARK: - Private Methods
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
}
