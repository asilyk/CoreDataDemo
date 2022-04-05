//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 04.10.2021.
//

import UIKit

class TaskListViewController: UITableViewController {
    // MARK: - Private Properties
    private var taskList: [Task] = []
    private let cellID = "task"
    private let storageManager = StorageManager.shared

    // MARK: - Life Cycles Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        storageManager.fetchData { result in
            switch result {
            case .success(let taskList):
                self.taskList = taskList
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    // MARK: - Private Methods
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        let navBarAppearance = UINavigationBarAppearance()

        title = "Task List"

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

        navigationBar.prefersLargeTitles = true
        navigationBar.tintColor = .white
        navigationBar.standardAppearance = navBarAppearance
        navigationBar.scrollEdgeAppearance = navBarAppearance
    }

    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?", action: save)
    }

    private func showAlert(with title: String, and message: String, action: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            action(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            if title == "New Task" {
                textField.placeholder = "New Task"
            } else {
                guard let indexPath = self.tableView.indexPathForSelectedRow?.row else { return }
                textField.text = self.taskList[indexPath].title
            }
        }

        present(alert, animated: true)
    }

    private func save(_ taskName: String) {
        storageManager.save(taskName) { task in
            taskList.append(task)
            let indexPath = IndexPath(row: taskList.count - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

    private func update(_ newTaskName: String) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }

        storageManager.update(taskList[indexPath.row], with: newTaskName)

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    private func delete(_ indexPath: IndexPath) {
        let task = taskList[indexPath.row]

        storageManager.delete(task)

        taskList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
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
