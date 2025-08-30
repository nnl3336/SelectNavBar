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
    
    // 表示データ
    var items: [SelectableItem] = [
        SelectableItem(name: "Apple"),
        SelectableItem(name: "Banana"),
        SelectableItem(name: "Cherry")
    ]
    
    // 選択アイテム
    var selectedItems = Set<SelectableItem>()
    
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
    
    // 以下、tableView delegate/datasource とナビバー更新はそのまま
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        
        // 選択済みはチェックマーク
        if selectedItems.contains(item) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        selectedItems.insert(item)
        updateNavigationBar()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        selectedItems.remove(item)
        updateNavigationBar()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Navigation Bar Update
    
    func updateNavigationBar() {
        if selectedItems.isEmpty {
            title = "Items"
            navigationItem.rightBarButtonItem = nil
        } else {
            title = "\(selectedItems.count) selected"
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Delete",
                style: .plain,
                target: self,
                action: #selector(deleteSelectedItems)
            )
        }
    }
    
    @objc func deleteSelectedItems() {
        items.removeAll { selectedItems.contains($0) }
        selectedItems.removeAll()
        tableView.reloadData()
        updateNavigationBar()
    }
}

struct MultiSelectTableView: UIViewRepresentable {
    @ObservedObject var selection: ItemSelection

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView()
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.allowsMultipleSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }

    func updateUIView(_ uiView: UITableView, context: Context) {
        uiView.reloadData()
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        var parent: MultiSelectTableView

        init(_ parent: MultiSelectTableView) { self.parent = parent }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            parent.selection.items.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let item = parent.selection.items[indexPath.row] // ← ここがポイント
            cell.textLabel?.text = item.name
            cell.accessoryType = parent.selection.selectedItems.contains(item) ? .checkmark : .none
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let item = parent.selection.items[indexPath.row]
            parent.selection.selectedItems.insert(item)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }

        func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            let item = parent.selection.items[indexPath.row]
            parent.selection.selectedItems.remove(item)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

struct ContentView: View {
    @StateObject var selection = ItemSelection()
    
    var body: some View {
        NavigationView {
            MultiSelectTableView(selection: selection)
                .navigationTitle(selection.selectedItems.isEmpty ? "Items" : "\(selection.selectedItems.count) selected")
                .toolbar {
                    if !selection.selectedItems.isEmpty {
                        Button("Delete") {
                            selection.items.removeAll { selection.selectedItems.contains($0) }
                            selection.selectedItems.removeAll()
                        }
                    }
                }
        }
    }
}
