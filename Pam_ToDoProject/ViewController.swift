
import UIKit

class ViewController: UIViewController {
  
  var tasks = [
    Todo(title: "Task-ul 1"),
  ]

  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  @IBAction func startEditing(_ sender: Any) {
    tableView.isEditing = !tableView.isEditing
  }
  
  @IBSegueAction func todoViewcontroller(_ coder: NSCoder) -> TodoViewController? {
    let vc = TodoViewController(coder: coder)
    
    if let indexpath = tableView.indexPathForSelectedRow {
      let todo = tasks[indexpath.row]
      vc?.todo = todo
    }
    
    vc?.delegate = self
    vc?.presentationController?.delegate = self
    
    return vc
  }
  
}

extension ViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
    let action = UIContextualAction(style: .normal, title: "Complete") { action, view, complete in
      
      let todo = self.tasks[indexPath.row].completeToggled()
      self.tasks[indexPath.row] = todo
      
      let cell = tableView.cellForRow(at: indexPath) as! CheckTableViewCell
      cell.set(checked: todo.isComplete)
      
      complete(true)
      
      print("complete")
    }
    
    return UISwipeActionsConfiguration(actions: [action])
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .delete
  }
  
}

extension ViewController: UITableViewDataSource {

  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tasks.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "checked cell", for: indexPath) as! CheckTableViewCell
    
    cell.delegate = self
    
    let todo = tasks[indexPath.row]
    
    cell.set(title: todo.title, checked: todo.isComplete)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      tasks.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
  
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let todo = tasks.remove(at: sourceIndexPath.row)
    tasks.insert(todo, at: destinationIndexPath.row)
  }
  
}

extension ViewController: CheckTableViewCellDelegate {
  
  func checkTableViewCell(_ cell: CheckTableViewCell, didChagneCheckedState checked: Bool) {
    guard let indexPath = tableView.indexPath(for: cell) else {
      return
    }
    let todo = tasks[indexPath.row]
    let newTodo = Todo(title: todo.title, isComplete: checked)
    
    tasks[indexPath.row] = newTodo
  }
  
}

extension ViewController: TodoViewControllerDelegate {
  
  func todoViewController(_ vc: TodoViewController, didSaveTodo todo: Todo) {
    
    
    
    dismiss(animated: true) {
      if let indexPath = self.tableView.indexPathForSelectedRow {
        // update
        self.tasks[indexPath.row] = todo
        self.tableView.reloadRows(at: [indexPath], with: .none)
      } else {
        // create
        self.tasks.append(todo)
        self.tableView.insertRows(at: [IndexPath(row: self.tasks.count-1, section: 0)], with: .automatic)
      }
    }
  
  }
  
}


extension ViewController: UIAdaptivePresentationControllerDelegate {
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
}
