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
// MARK: - Item Model
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

// MARK: - UIKit Controller
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tableView = UITableView()
    var selection = ItemSelection()   // データ保持
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Items"
        view.backgroundColor = .white
        
        setupTableView()
        updateNavigationBar()
    }
    
    // Navigation Bar Update
    func updateNavigationBar() {
        if selection.selectedItems.isEmpty {
            title = "Items"
            navigationItem.rightBarButtonItem = nil
        } else {
            title = "\(selection.selectedItems.count) selected"
            
            // アクション定義
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.deleteSelectedItems()
            }
            let shareAction = UIAction(title: "選択", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.shareSelectedItems()
            }
            
            // UIMenu 作成
            let menu = UIMenu(title: "", children: [deleteAction, shareAction])
            
            // UIBarButtonItem に UIMenu を付与
            let menuButton = UIBarButtonItem(title: "Actions", image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: menu)
            
            navigationItem.rightBarButtonItem = menuButton
        }
    }

    @objc func deleteSelectedItems() {
        selection.items.removeAll { selection.selectedItems.contains($0) }
        selection.selectedItems.removeAll()
        tableView.reloadData()
        updateNavigationBar()
    }

    func shareSelectedItems() {
        // 例: すべての items を選択済みに追加する
        for item in selection.items {
            selection.selectedItems.insert(item)
        }
        
        tableView.reloadData()
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
}

// MARK: - SwiftUI Bridge
struct MultiSelectTableView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = ViewController()
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

struct ContentView: View {
    var body: some View {
        MultiSelectTableView() // UIKit のナビゲーションバーをそのまま表示
            .edgesIgnoringSafeArea(.all)
    }
}
