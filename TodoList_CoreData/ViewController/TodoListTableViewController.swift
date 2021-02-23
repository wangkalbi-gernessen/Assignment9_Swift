//
//  TodoListTableViewController.swift
//  Assignment9_ToDoList_CoreData
//
//  Created by Kazunobu Someya on 2021-02-17.
//

import UIKit
import CoreData

class TodoListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
//    func add(_ todoItem: ManagedTodoItem) {
//        let addTodoItem = AddTodoItemViewController()
//        addTodoItem.managedTodoItem = ManagedTodoItem(context: addTodoItem.context)
//
//        if let managedTodoItem = addTodoItem.managedTodoItem {
//            managedTodoItem.title = addTodoItem.titleTextField.text
//            managedTodoItem.todoDescription = addTodoItem.descriptionTextField.text
//            managedTodoItem.priorityNumber = Int16(addTodoItem.segmentedControl.selectedSegmentIndex)
//            managedTodoItem.isCompleted = true
//        }
//        (UIApplication.shared.delegate as! AppDelegate).saveContext()
//    }
//
//    func edit(_ todoItem: ManagedTodoItem) {
//        let addTodoItem = AddTodoItemViewController()
//        if let managedTodoItem = addTodoItem.managedTodoItem {
//            managedTodoItem.title = addTodoItem.titleTextField.text
//            managedTodoItem.todoDescription = addTodoItem.descriptionTextField.text
//            managedTodoItem.priorityNumber = Int16(addTodoItem.segmentedControl.selectedSegmentIndex)
//            managedTodoItem.isCompleted = true
//        }
//        (UIApplication.shared.delegate as! AppDelegate).saveContext()
//    }

    // create empty array for todoItem
    var todoItems: [ManagedTodoItem] = []
    var todoItemsToShow: [String: [ManagedTodoItem]] = ["High Priority":[],"Medium Priority":[],"Low Priority":[]]
    let sections = ["High Priority", "Medium Priority", "Low Priority"]
    let cellId = "cellId"
    
    lazy var editBtn = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonPressed))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Todo Items"
        
        navigationItem.leftBarButtonItem = editBtn
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goToAddTodoItemScreen))
        navigationItem.rightBarButtonItem = add
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    @objc func loadList(notification: NSNotification){
        getData()
        //load data here
        self.tableView.reloadData()
    }
    
    func getData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            // fetch data from coredata and store the data into array(todoItems)
            let fetchRequest: NSFetchRequest<ManagedTodoItem> = ManagedTodoItem.fetchRequest()
            todoItems = try context.fetch(fetchRequest)
            
            for key in todoItemsToShow.keys {
                todoItemsToShow[key] = []
            }
            // store fetched data into todoItemsToShow array
            for todoItem in todoItems {
                switch todoItem.priorityNumber {
                case 0:
                    todoItemsToShow[sections[0]]?.append(todoItem)
                case 1:
                    todoItemsToShow[sections[1]]?.append(todoItem)
                case 2:
                    todoItemsToShow[sections[2]]?.append(todoItem)
                default:
                    fatalError("not found")
                }
            }
        } catch {
            print("Fetching Failed.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func goToAddTodoItemScreen() {
        let addTodoItemTVC = AddTodoItemViewController()
//        addTodoItemTVC.delegate = self
        let addTodoItemNC = UINavigationController(rootViewController: addTodoItemTVC)
        self.present(addTodoItemNC, animated: true, completion: nil)
    }
    
    @objc func editButtonPressed() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing == true{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.editButtonPressed))
        }else{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.editButtonPressed))
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItemsToShow[sections[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let sectionData = todoItemsToShow[sections[indexPath.section]]
        let cellData = sectionData?[indexPath.row]
        cell.textLabel?.text = cellData!.title!
        cell.accessoryType = .detailDisclosureButton
        cell.showsReorderControl = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(hexString: "#d3d3d3")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addTodoItem = AddTodoItemViewController()
//        addTodoItem.delegate = self
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        addTodoItem.context = context
        // get title and priorityNumber you want to edit
        let editedPriority = sections[indexPath.section]
        let editedTitle = todoItemsToShow[editedPriority]?[indexPath.row].title
        let editedDescription = todoItemsToShow[editedPriority]?[indexPath.row].todoDescription
        let fetchRequest: NSFetchRequest<ManagedTodoItem> = ManagedTodoItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title = %@ and todoDescription = %@", editedTitle!, editedDescription!)
        do {
            let todoItem = try context.fetch(fetchRequest)
            addTodoItem.managedTodoItem = todoItem[0]
            
        } catch {
            print("Fetching Failed")
        }
        
        let nav = UINavigationController(rootViewController: addTodoItem)
        present(nav, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if editingStyle == .delete {
            let deletedCategory = sections[indexPath.section]
            let deletedTitle = todoItemsToShow[deletedCategory]?[indexPath.row].title
            let deletedDescription = todoItemsToShow[deletedCategory]?[indexPath.row].todoDescription
            let fetchRequest: NSFetchRequest<ManagedTodoItem> = ManagedTodoItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title = %@ and todoDescription = %@", deletedTitle!, deletedDescription!)
            do {
                let todoItem = try context.fetch(fetchRequest)
                context.delete(todoItem[0])
            } catch {
                print("Fetching Failed.")
            }
            // save data after deletion
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            // fetch all datas after deletion
            getData()
        }
        tableView.reloadData()
    }
    
    // under modifying
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //        switch sourceIndexPath.section {
        //        case 0:
        //            let removedItem = highPriorityItems.remove(at: sourceIndexPath.row)
        //            switch destinationIndexPath.section {
        //            case 0:
        //                highPriorityItems.insert(removedItem, at: destinationIndexPath.row)
        //            case 1:
        //                mediumPriorityItems.insert(removedItem, at: destinationIndexPath.row)
        //            case 2:
        //                lowPrioritItems.insert(removedItem, at: destinationIndexPath.row)
        //            default:
        //                fatalError("failure")
        //            }
        //        case 1:
        //            let removedItem = mediumPriorityItems.remove(at: sourceIndexPath.row)
        //            switch destinationIndexPath.section {
        //            case 0:
        //                highPriorityItems.insert(removedItem, at: destinationIndexPath.row)
        //            case 1:
        //                mediumPriorityItems.insert(removedItem, at: destinationIndexPath.row)
        //            case 2:
        //                lowPrioritItems.insert(removedItem, at: destinationIndexPath.row)
        //            default:
        //                fatalError("failure")
        //            }
        //        case 2:
        //            let removedItem = lowPrioritItems.remove(at: sourceIndexPath.row)
        //            print(removedItem)
        //            switch destinationIndexPath.section {
        //            case 0:
        //                highPriorityItems.insert(removedItem, at: destinationIndexPath.row)
        //            case 1:
        //                mediumPriorityItems.insert(removedItem, at: destinationIndexPath.row)
        //            case 2:
        //                lowPrioritItems.insert(removedItem, at: destinationIndexPath.row)
        //            default:
        //                fatalError("failure")
        //            }
        //        default:
        //            fatalError()
        //        }
    }
}
