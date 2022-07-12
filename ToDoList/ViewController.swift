//
//  ViewController.swift
//  ToDoList
//
//  Created by nelson tapia on 12-07-22.
//

import UIKit
import CoreData


class ViewController: UIViewController {

    @IBOutlet weak var tablaTareas: UITableView!
    
    var listaTareas = [Tareas]()
    
    //Referencia al contenedor de core Data
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tablaTareas.delegate = self
        tablaTareas.dataSource = self
        
        leerTareas()
    }

    @IBAction func nuevaTarea(_ sender: UIBarButtonItem) {
        var nombreTarea = UITextField()
        
        let alerta = UIAlertController(title: "Nueva", message: "Tarea", preferredStyle: .alert)
        
        let accionAceptar = UIAlertAction(title: "Agregar", style: .default) { (_) in
            let nuevaTarea = Tareas(context: self.contexto)
            nuevaTarea.nombre = nombreTarea.text
            nuevaTarea.realizada = false
            
            self.listaTareas.append(nuevaTarea)
            
            self.guardar()
        }
        
        alerta.addTextField { textFieldAlerta in
            textFieldAlerta.placeholder = "Escribe tu tarea aquí..."
            nombreTarea = textFieldAlerta
        }
        
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
    }
    
    func guardar() {
        do {
            try contexto.save()
        } catch  {
            print(error.localizedDescription)
        }
        
        self.tablaTareas.reloadData()
    }
    
    func leerTareas() {
        let solicitud : NSFetchRequest<Tareas> = Tareas.fetchRequest()
        
        do {
            listaTareas = try contexto.fetch(solicitud)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaTareas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tablaTareas.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        
        let tarea = listaTareas[indexPath.row]
        
        //Operador ternario validar
        celda.textLabel?.text = tarea.nombre
        celda.textLabel?.textColor = tarea.realizada ? .black : .blue
        
        celda.detailTextLabel?.text = tarea.realizada ? "Completada" : "Pendiente"
        
        //Marcas de tareas completas
        celda.accessoryType = tarea.realizada ? .checkmark : .none
        
        
        return celda
    }
    
    //Seleccion del usuario
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Palomear Tarea
        if tablaTareas.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .none
        }else {
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        
        //Editar en Core Data
        listaTareas[indexPath.row].realizada = !listaTareas[indexPath.row].realizada
        guardar()
        
//        Deseleccionar la Tarea
        tablaTareas.deselectRow(at: indexPath, animated: true)
    }
    
    //Eliminar Task
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accionEliminar = UIContextualAction(style: .normal, title: "Eliminar") { _, _, _ in
            self.contexto.delete(self.listaTareas[indexPath.row])
            
            self.listaTareas.remove(at: indexPath.row)
            self.guardar()
        }
        
        accionEliminar.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [accionEliminar])
    }
    
    
}

