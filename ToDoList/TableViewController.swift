//
//  TableViewController.swift
//  ToDoList
//
//  Created by Danya on 17.06.2021.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
    var tasks: [Task] = []
    
    
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        
        let alertControler = UIAlertController(title: "New Task", message: "Please add new task", preferredStyle: .alert)
        let seveAction = UIAlertAction(title: "Save", style: .default) { action in
            
            let tf = alertControler.textFields?.first
            if let newTaskTitle = tf?.text {
                self.saveTask(withTitle: newTaskTitle)
                
                self.tableView.reloadData()
            }
            
        }
        
        alertControler.addTextField { _ in }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        alertControler.addAction(seveAction)
        alertControler.addAction(cancelAction)
        
        present(alertControler, animated: true, completion: nil)
        
    }
    
    private func saveTask(withTitle title: String) {
        
        let context = getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
        
        let taskObject = Task(entity: entity, insertInto: context)
        taskObject.title = title
        
        do {
            try context.save()
            tasks.append(taskObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func getContext() -> NSManagedObjectContext {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        //Обратный порядок добавления элементов
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //очистка всей таблицы из памяти
    @IBAction func clearAll(_ sender: UIBarButtonItem) {
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        if let objects = try? context.fetch(fetchRequest) {
            for object in objects {
                context.delete(object)
            }
        }
        
        do {
            try context.save()
            tasks.removeAll()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title

        return cell
    }
    
    //метод проверяющий нажатие на ячейку
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alertControler = UIAlertController(title: "Информационное сообщение", message: "Вы нажали на ячейку", preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertControler.addAction(alertOk)
        present(alertControler, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true) //по indexPath
    }
    
    //метод позволяющий удалять выбранные ячейки свайпом
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
        if editingStyle == .delete {
                   self.tasks.remove(at: indexPath.row)
               }
               tableView.deleteRows(at: [indexPath], with: .fade)
        
    }
}
