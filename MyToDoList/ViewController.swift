

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var todoList = [MyTodo]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults.standard
        if let storedTodoList = userDefaults.object(forKey: "todoList") as? Data{
            if let unarchiveTodoList = NSKeyedUnarchiver.unarchiveObject(
                with: storedTodoList) as? [MyTodo]{
            todoList.append(contentsOf: unarchiveTodoList)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

        
    @IBAction func tapAddButton(_ sender: Any) {
        
        let alertController = UIAlertController(title: "TODO追加",
                                                message: "TODOを入力してください",preferredStyle:UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: nil)
        
        let okAction = UIAlertAction(title: "OK",style: UIAlertActionStyle.default) { (action:UIAlertAction) in
            if let textField = alertController.textFields?.first{
                
                let myTodo = MyTodo()
                myTodo.todoTitle = textField.text!
                self.todoList.insert(myTodo, at:0)
                
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.right)
                
                let userDefaults = UserDefaults.standard
                let data = NSKeyedArchiver.archivedData(withRootObject: self.todoList)
                userDefaults.set(data, forKey: "todoList")
                userDefaults.synchronize()
            }
        }
        
        
        alertController.addAction(okAction)
        
        let cancelButton = UIAlertAction(title: "CANCEL",style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true,completion: nil)
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        let myTodo = todoList[indexPath.row]
        cell.textLabel?.text = myTodo.todoTitle
        if myTodo.todoDone {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let myTodo = todoList[indexPath.row]
        if myTodo.todoDone{
            myTodo.todoDone = false
        } else {
            myTodo.todoDone = true
        }
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: todoList)
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "todoList")
        userDefaults.synchronize()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCellEditingStyle,
        forRowAt indexPath: IndexPath) {
        if editingStyle ==  UITableViewCellEditingStyle.delete{
            todoList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            let data: Data = NSKeyedArchiver.archivedData(withRootObject: todoList)
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: "todoList")
            userDefaults.synchronize()
        }
        
    }

}

class MyTodo: NSObject,NSCoding {
    var todoTitle: String?
    var todoDone: Bool = false
    override init(){
    }
    
    required init?(coder aDecoder: NSCoder){
        todoTitle = aDecoder.decodeObject(forKey: "todoTitle") as? String
        todoDone = aDecoder.decodeBool(forKey: "todoDone")
        }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(todoTitle, forKey: "todoTitle")
        aCoder.encode(todoDone, forKey: "todoDone")
     }
}
