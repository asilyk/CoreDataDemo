//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 04.10.2021.
//

import UIKit

class TaskListViewController: UITableViewController {
    // MARK: - Private Properties
    private let cellID = "task"
    private let storageManager = StorageManager.shared

    // MARK: - Life Cycles Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        storageManager.fetchData()
    }

    // MARK: - Private Methods
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }

    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?", action: save)
    }

    private func showAlert(with title: String, and message: String, action: @escaping (String) -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            action(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        if title == "New Task"
        {
            alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
        }
        else
        {
            alert.addTextField { textField in
                guard let cellIndex = self.tableView.indexPathForSelectedRow?.row else { return }
                textField.text = self.storageManager.taskList[cellIndex].title
            }
        }

        present(alert, animated: true)
    }

    private func save(_ taskName: String) {
        storageManager.save(taskName)

        let cellIndex = IndexPath(row: storageManager.taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }

    private func update(_ newTaskName: String) {
        guard let cellIndex = tableView.indexPathForSelectedRow else { return }

        tableView.deselectRow(at: cellIndex, animated: true)

        guard let cell = tableView.cellForRow(at: cellIndex) else { return }
        var content = cell.defaultContentConfiguration()

        content.text = newTaskName
        cell.contentConfiguration = content

        storageManager.resave(newTaskName, by: cellIndex.row)
    }

    private func delete(_ indexPath: IndexPath)
    {
        storageManager.delete(by: indexPath.row)

        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        storageManager.taskList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = storageManager.taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()

        content.text = task.title
        cell.contentConfiguration = content

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(with: "Update Task", and: "What do you want to do?", action: update)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        delete(indexPath)
    }
}
