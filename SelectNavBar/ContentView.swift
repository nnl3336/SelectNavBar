//
//  ContentView.swift
//  SelectNavBar
//
//  Created by Yuki Sasaki on 2025/08/30.
//

import SwiftUI
import CoreData

import UIKit

// サンプルの Item 型
// 元: struct Item
struct SelectableItem: Hashable, Identifiable {
    let id = UUID()
    let name: String
}

class ItemSelection: ObservableObject {
    @Published var items: [SelectableItem] = [
        SelectableItem(name: "Apple"),
        SelectableItem(name: "Banana"),
        SelectableItem(name: "Cherry")
    ]
    @Published var selectedItems = Set<SelectableItem>()
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tableView = UITableView()

    // ItemSelection をここに持たせる
    var selection = ItemSelection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Items"
        view.backgroundColor = .white
        
        setupTableView()
        updateNavigationBar()
    }
    
    func setupTableView() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
    }

    // DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selection.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = selection.items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.accessoryType = selection.selectedItems.contains(item) ? .checkmark : .none
        return cell
    }

    // Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = selection.items[indexPath.row]
        if selection.selectedItems.contains(item) {
            selection.selectedItems.remove(item)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            selection.selectedItems.insert(item)
        }
        updateNavigationBar()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let item = selection.items[indexPath.row]
        selection.selectedItems.remove(item)
        updateNavigationBar()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    // Navigation Bar Update
    func updateNavigationBar() {
        if selection.selectedItems.isEmpty {
            title = "Items"
            navigationItem.rightBarButtonItem = nil
        } else {
            title = "\(selection.selectedItems.count) selected"
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Delete",
                style: .plain,
                target: self,
                action: #selector(deleteSelectedItems)
            )
        }
    }

    @objc func deleteSelectedItems() {
        selection.items.removeAll { selection.selectedItems.contains($0) }
        selection.selectedItems.removeAll()
        tableView.reloadData()
        updateNavigationBar()
    }
}

struct MultiSelectTableView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // SwiftUI 側の状態と同期したいときにここを書く（今回は不要）
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            MultiSelectTableView() // ここはダミー渡しも可能
        }
    }
}
