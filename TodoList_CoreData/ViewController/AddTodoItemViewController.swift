//
//  AddTodoItemTableViewController.swift
//  Assignment9_ToDoList_CoreData
//
//  Created by Kazunobu Someya on 2021-02-18.
//

import UIKit

class AddTodoItemViewController: UIViewController {
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var managedTodoItem: ManagedTodoItem?
    
    
    let titleTextField: UITextField = {
        let title = UITextField()
//        title.widthAnchor.constraint(equalToConstant: 200).isActive = true
//        title.heightAnchor.constraint(equalToConstant: 50).isActive = true
        title.borderStyle = .roundedRect
        title.placeholder = "Add new title here"
        return title
    }()

    let descriptionTextField: UITextField = {
        let title = UITextField()
        title.widthAnchor.constraint(equalToConstant: 200).isActive = true
        title.heightAnchor.constraint(equalToConstant: 50).isActive = true
        title.borderStyle = .roundedRect
        title.placeholder = "Add new description here"
        return title
    }()
    
    let segmentedControl: UISegmentedControl = {
        let segC = UISegmentedControl(items: ["High Priority","Medium Priority","Low Priority"])
        segC.selectedSegmentIndex = 0
        segC.backgroundColor = .green
        segC.tintColor = .white
        return segC
    }()
    
    lazy var vStackView: UIStackView = {
        let vStack = UIStackView(arrangedSubviews: [titleTextField,descriptionTextField,segmentedControl])
        vStack.axis = .vertical
        vStack.spacing = 10
        vStack.distribution = .fill
        vStack.alignment = .center
        vStack.translatesAutoresizingMaskIntoConstraints = false
        return vStack
    }()

    
//    weak var delegate: AddEditTodoItemTVCDelegate?
    var todoItem: ManagedTodoItem?
    
    // create "Done" button
    lazy var doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(saveTodoItem))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(vStackView)
        setupLayout()
        if let managedTodoItem = managedTodoItem {
            title = "Edit Todo Item"
            titleTextField.text = managedTodoItem.title
            descriptionTextField.text = managedTodoItem.todoDescription
            segmentedControl.selectedSegmentIndex = Int(managedTodoItem.priorityNumber)
        } else {
            title = "Add Todo Item"
        }
        
        // create "Cancel" button
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAddTodoItem))
        navigationItem.rightBarButtonItem = doneBtn
        titleTextField.addTarget(self, action: #selector(changeTextField(_:)), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(changeTextField(_:)), for: .editingChanged)
        segmentedControl.addTarget(self, action: #selector(changePriority(_:)), for: .valueChanged)
        updateDoneButtonState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupLayout() {
        titleTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descriptionTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        vStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        vStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        vStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    @objc func cancelAddTodoItem() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func changeTextField(_ sender: UITextField) {
        updateDoneButtonState()
    }
    
    @objc func changePriority(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            segmentedControl.tintColor = .systemPink
            segmentedControl.selectedSegmentIndex = sender.selectedSegmentIndex
        case 1:
            segmentedControl.tintColor = .systemOrange
        case 2:
            segmentedControl.tintColor = .systemYellow
        default:
            fatalError("not chosen")
        }
    }
    
    @objc func saveTodoItem() {
        if managedTodoItem == nil {
            managedTodoItem = ManagedTodoItem(context: context)
        }
        
        if let managedTodoItem = managedTodoItem {
            managedTodoItem.title = titleTextField.text!
            managedTodoItem.todoDescription = descriptionTextField.text!
            managedTodoItem.priorityNumber = Int16(segmentedControl.selectedSegmentIndex)
            managedTodoItem.isCompleted = true
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        dismiss(animated: true, completion: nil)
    }
    
    private func updateDoneButtonState() {
        if !titleTextField.text!.isEmpty && !descriptionTextField.text!.isEmpty {
            doneBtn.isEnabled = true
        } else {
            doneBtn.isEnabled = false
        }
    }
}
