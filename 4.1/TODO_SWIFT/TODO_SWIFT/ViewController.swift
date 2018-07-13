//
//  ViewController.swift
//  TODO_SWIFT
//
//  Created by Cast on 04/04/18.
//  Copyright © 2018 Cast. All rights reserved.
//

import UIKit



class ViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var deleteComp: UIButton!
    
    var idArray = [String]()
    var completedArray = [Int]()
    var titleArray = [String]()
    var toggleCompleted = "true"
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData()
        textField.addTarget(self, action: #selector(enterPressed), for: .editingDidEndOnExit)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: Actions
    
    @IBAction func deleteComp(_ sender: UIButton) {
        deleteCompleted()
    }
    
    @IBAction func updateItem(_ sender: UIButton) {
        if let buttonId = sender.title(for: .normal) {
            let buttonState = sender.isSelected
            updateTodo(str: buttonId, state: buttonState)
        }
    }
    
    @IBAction func deleteItem(_ sender: UIButton) {
        if let buttonId = sender.title(for: .normal) {
            deleteTodo(str: buttonId)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func enterPressed() {
        textField.resignFirstResponder()
        if let textValue = textField.text {
            postTodo(str: textValue)
        }
    }
    
    @IBAction func toggleList(_ sender: UIButton) {
        toggleTodo()
    }
    
    @IBAction func exitApp(_ sender: UIButton) {
        exit(0)
    }
    
    func refreshData() {
        DispatchQueue.main.async {
        self.tableView.reloadData()
        }
        getTodo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTodo() {
        self.completedArray.removeAll()
        self.idArray.removeAll()
        self.titleArray.removeAll()
        
        let urlString = "http://localhost:8001/rest/todos"
        
        let url = NSURL(string: urlString)
        
        var getTask = URLRequest(url: (url as URL?)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 20)
        
        getTask.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: getTask, completionHandler: {(data, response, error) -> Void in
            if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary {
                print(jsonData.value(forKey: "todos") as Any)
                
                if let todoArray = jsonData.value(forKey: "todos") as? NSArray {
                    for todo in todoArray{
                        if let todoDict = todo as? NSDictionary {
                            
                            if let completed = todoDict.value(forKey: "completed") {
                                self.completedArray.append(completed as! Int)
                            }
                            if let id = todoDict.value(forKey: "id") {
                                self.idArray.append(id as! String)
                            }
                            if let title = todoDict.value(forKey: "title") {
                                self.titleArray.append(title as! String)
                            }
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }).resume()
    }
    
    func postTodo(str: String) {
        let urlString = "http://localhost:8001/rest/todos"
        
        let data = ["title":str, "completed":0] as NSDictionary
        
        guard let url = URL(string: urlString) else { return }
        
        var postTask = URLRequest(url: url)
        
        postTask.httpMethod = "POST"
        postTask.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else { return }
        postTask.httpBody = jsonData
        
        URLSession.shared.dataTask(with: postTask) {(data, response, error) in
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                print("Post Todo Element done")
            }
        }.resume()
        self.textField.text =  ""
        refreshData()
    }
    
    func deleteTodo(str: String) {
        var urlString = "http://localhost:8001/rest/todos/" + str;
        
        guard let url = URL(string: urlString) else { return }
        
        var deleteTask = URLRequest(url: (url as URL?)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 20)
        
        deleteTask.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: deleteTask) {(data, response, error) in
            if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: []) {
                print("Delete Todo Element done")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }.resume()
        refreshData()
    }
    
    func updateTodo(str: String, state: Bool) {
        var complete = "1"
        if state == true {
            complete = "0"
        }
        else
        {
            complete = "1"
        }
        
        let urlString = "http://localhost:8001/rest/todos/" + str + "?completed=" + complete;
        
        guard let url = URL(string: urlString) else { return }
        
        var toggleTask = URLRequest(url: (url as URL?)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 20)
        
        toggleTask.httpMethod = "PUT"
        
        URLSession.shared.dataTask(with: toggleTask) {(data, response, error) in
            if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: []) {
                print("Update task done")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                }
            }.resume()
        refreshData()
    }
    
    func deleteCompleted() {
        let urlString = "http://localhost:8001/rest/todos/"
        
        guard let url = URL(string: urlString) else { return }
        
        var deleteCompleteTask = URLRequest(url: (url as URL?)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 20)
        
        deleteCompleteTask.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: deleteCompleteTask) {(data, response, error) in
            if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: []) {
                print("Delete Todo Element done")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }.resume()
        refreshData()
    }
    
    func toggleTodo() {
        var urlString = "http://localhost:8001/rest/todos?toggleCompleted="
        urlString = urlString + toggleCompleted
        
        guard let url = URL(string: urlString) else { return }
        
        var toggleTask = URLRequest(url: (url as URL?)!,cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 20)
        
        toggleTask.httpMethod = "PUT"
        
        URLSession.shared.dataTask(with: toggleTask) {(data, response, error) in
            if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: []) {
                print("Toggle task done")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                }
            }.resume()
        
        if (toggleCompleted == "true") {
            toggleCompleted = "false" }
        else {
            toggleCompleted = "true" }
        
        refreshData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        self.tableView.rowHeight = 40.0
        let compURL = String(completedArray[indexPath.row])
        let comp = String(1)
        if compURL == comp {
            cell.completeButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            cell.completeButton.setImage(UIImage(named: "done.png")?.withRenderingMode(.alwaysOriginal), for: UIControlState.normal)
            cell.completeButton.isSelected = true
        }
        else {
            cell.completeButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            cell.completeButton.setImage(UIImage(named: "notdone.png")?.withRenderingMode(.alwaysOriginal), for: UIControlState.normal)
            cell.completeButton.isSelected = false
        }
        cell.completeButton.setTitle(idArray[indexPath.row], for: .normal)
        cell.titleLabel.text = titleArray[indexPath.row]
        cell.deleteButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        cell.deleteButton.setImage(UIImage(named: "delete.png")?.withRenderingMode(.alwaysOriginal), for: UIControlState.normal)
        cell.deleteButton.setTitle(idArray[indexPath.row], for: .normal)
        
        return cell
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let content = self.textField.text
        
        if((content) != nil) {
            self.postTodo(str: content!)
        }
    }
}
