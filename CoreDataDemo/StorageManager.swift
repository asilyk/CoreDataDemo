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

    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "CoreDataDemo")
            container.loadPersistentStores(completionHandler: { (_, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
    }()

    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Initializers
    private init() {}

    // MARK: - Public Methods
    func fetchData(completion: (Result<[Task], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

        do {
            let taskList = try context.fetch(fetchRequest)
            completion(.success(taskList))
        } catch let error {
            completion(.failure(error))
        }
    }

    func save(_ taskName: String, completion: (Task) -> Void) {
        let task = Task(context: context)

        task.title = taskName
        completion(task)
        saveContext()
    }

    func update(_ task: Task, with newTaskName: String) {
        task.title = newTaskName
        saveContext()
    }

    func delete(_ task: Task) {
        context.delete(task)
        saveContext()
    }

    // MARK: - Core Data Saving support
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
