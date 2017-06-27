//
//  TableViewController.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-12.
//  Copyright © 2015 Figure1. All rights reserved.
//

import UIKit

class TableViewController: FOTableViewController {
    
    let refresh = UIButton(type: .system)
    var stop = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.orange
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(TableViewController.play))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stop = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        stop = false
        play()
    }
    
    func play() {
        queueUpdate({
            self.clearAllItems()
        })
        
//        let sections1 = [
//            self.section("A", identifiers: ["a0", "a1", "a2"], color: createSectionColor()),
//            self.section("Z", identifiers: ["z0", "z1", "z2"], color: createSectionColor()),
//            ]
//
//        let sections2 = [
//            self.section("L", identifiers: ["l0", "l1"], color: createSectionColor()),
//            self.section("I", identifiers: ["i0"], color: createSectionColor()),
//            ]
//
//        queueUpdate({
//            self.insertSections(sections1, indexes: IndexSet(integersIn: 0..<sections1.count))
//        })
//
//        animateUpdate(sections1)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.animateUpdate(sections2)
//        }
        
        doMutate()
    }
    
    var count = Int(0)
    
    func doMutate() {
        queueWork {
            [weak self] in
            if let this = self {
                
                if this.stop {
                    return
                }
                
                this.count += 1
                print("-\(this.count)-")
                
                this.dataSource.sections.log(title: " ")
                
                let newSections = this.mutate(this.dataSource.sections)

                newSections.log(title: ">")
                
                this.animateUpdate(newSections, with: .automatic, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        this.doMutate()
                    }
                })
            }
        }
    }
    
    let sectionMoveP = 0.2
    let sectionDeleteP = 0.2
    let sectionInsertP = 0.2
    let itemMoveP = 0.4
    let itemDeleteP = 0.2
    let itemInsertP = 0.2
    let maxNewItems = Int(3)
    let maxNewSections = Int(3)
    
    var deletedSectionIdentifiers = [String]()
    
    func mutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections
        
        deletedSectionIdentifiers.removeAll()
        
        result = sectionDeleteMutate(result)
        result = sectionMoveMutate(result)
        result = itemMoveMutate(result)
        result = itemInsertMutate(result)
        result = itemDeleteMutate(result)
        result = sectionInsertMutate(result)
        
        return result
    }
        
    func sectionMoveMutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections

        sections.enumerated().forEach{
            s in
            let toIndex = random(range: 0..<result.count)
            let p = Double(arc4random()) / Double(UInt32.max)
            
            if toIndex != s.offset && p <= sectionMoveP {
                print("section move: \(s.element.identifier!) from: \(s.offset) to: \(toIndex)")

                result = rearrange(array: result, fromIndex: s.offset, toIndex: toIndex)
            }
        }
        
        return result
    }
    
    func sectionDeleteMutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections
        
        sections.enumerated().reversed().forEach{
            s in
            let p = Double(arc4random()) / Double(UInt32.max)
            
            if p <= sectionDeleteP {
                if let identifier = s.element.identifier {
                   deletedSectionIdentifiers.append(identifier)
                }
                
                result.remove(at: s.offset)
                
                print("section delete: \(s.element.identifier!)")
            }
        }
        
        return result
    }
    
    func sectionInsertMutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections
        
        if sections.count > 0 {
            sections.enumerated().reversed().forEach{
                s in
                let p = Double(arc4random()) / Double(UInt32.max)
                
                if p <= sectionInsertP {
                    let newSection = createSection(currentSections: result)
                    result.insert(newSection, at: s.offset)
                    
                    print("section insert: \(newSection.identifier!) (\(newSection.items!.count))")
                }
            }
        } else {
            for _ in 0..<random(range: 0..<maxNewSections) {
                let newSection = createSection(currentSections: result)
                result.insert(newSection, at: 0)
                
                print("section insert: \(newSection.identifier!) (\(newSection.items!.count))")
            }
        }
        
        return result
    }
    
    func createSection(currentSections: [FOTableSection]) -> FOTableSection {
        let sectionIdentifiers = currentSections.map{$0.identifier!}
        let newSectionCharacter = createSectionIdentifier().uppercased()
        var newSectionIdentifier = newSectionCharacter
        
        while sectionIdentifiers.contains(newSectionIdentifier) || deletedSectionIdentifiers.contains(newSectionIdentifier) {
            newSectionIdentifier = newSectionIdentifier + newSectionCharacter
        }
        
        var itemIdentifiers = [String]()
        
        for i in 0..<random(range: 1..<maxNewItems + 1) {
            itemIdentifiers.append("\(newSectionIdentifier.lowercased())\(i)")
        }
        
        return section(newSectionIdentifier, identifiers: itemIdentifiers, color: .random())
    }
    
    func createSectionIdentifier() -> String {
        let sectionCharacters = "abcdefghijklmnopqrstuvwxyz"
        let characterIndex = random(range: 0..<sectionCharacters.characters.count)
        let index = sectionCharacters.index(sectionCharacters.startIndex, offsetBy: characterIndex)
        let character = sectionCharacters[index]
        
        return "\(character)"
    }
    
    func random(range: Range<Int>) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        
        return Int(arc4random_uniform(UInt32(max - min))) + min
    }
    
    fileprivate func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T> {
        var arr = array
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        
        return arr
    }
    
    func section(_ sectionIdentifier: String, identifiers: [String], color: UIColor) -> FOTableSection {
        let section = DemoTableSection(identifier: sectionIdentifier, color: color)
        
        section.items = identifiers.map{DemoTableItem(identifier: $0, color: color)}
        
        return section
    }
    
}

extension TableViewController {

    func itemDeleteMutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections.duplicate()
        let items = result.itemIdentifiers().select(itemDeleteP)

        items.forEach{result = result.deleteItem($0)}
        result = result.removeEmpty()
        
        return result
    }
    
    func itemInsertMutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections.map{$0.copy()} as! [FOTableSection]
        let items = result.itemIdentifiers().select(itemInsertP)
        let sections = result.sectionIdentifiers().select(itemInsertP)

        items.forEach{result = result.insertAtItem($0)}
        sections.forEach{result = result.insertAtSectionEnd($0)}
        result = result.removeEmpty()
        
        return result
    }
    
    func itemMoveMutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections.map{$0.copy()} as! [FOTableSection]
        let items = result.itemIdentifiers().select(itemMoveP)
        
        items.forEach{result = result.moveItem($0)}
        result = result.removeEmpty()
        
        return result
    }

}

private extension Array where Element:FOTableSection {
    
    func log(title: String) {
        forEach({ (section) in
            print(title, section.identifier!, section.items!.reduce([String](), { (result, item) -> [String] in
                return result + [item.identifier!]
            }))
        })
    }
    
    func duplicate() -> [FOTableSection] {
        return map{$0.copy()} as! [FOTableSection]
    }
    
    func removeEmpty() -> [FOTableSection] {
        return  filter{$0.items!.count > 0}
    }
    
    func randomIndexPath() -> IndexPath {
        let sectionIndex = Int(random(range: 0..<UInt32(count)))
        let section = self[sectionIndex]
        let itemIndex = Int(random(range: 0..<UInt32(section.items!.count)))
        
        return IndexPath(item: itemIndex, section: sectionIndex)
    }
    
    func findItem(_ identifier: String) -> IndexPath? {
        for s in enumerated() {
            if let items = s.element.items {
                for i in items.enumerated() {
                    if identifier == i.element.identifier {
                        return IndexPath(item: i.offset, section: s.offset)
                    }
                }
            }
        }
        
        return nil
    }
    
    func findSection(_ identifier: String) -> Int? {
        for s in enumerated() {
            if s.element.identifier! == identifier {
                return s.offset
            }
        }
        
        return nil
    }
    
    func getAt(_ indexPath: IndexPath) -> FOTableItem? {
        return self[indexPath.section].items?[indexPath.row]
    }
    
    func deleteItem(_ identifier: String) -> [FOTableSection] {
        var result = self as [FOTableSection]
        
        if let indexPath = findItem(identifier)  {
            result = deleteAt(indexPath)

            print("delete item: \(identifier)")
        }
        
        return result
    }
    
    func deleteAt(_ indexPath: IndexPath) -> [FOTableSection] {
        var result = self
        
        if indexPath.section < result.count {
            let section = result[indexPath.section]
            
            if
                let items = section.items,
                indexPath.item < items.count
            {
                section.items?.remove(at: indexPath.item)
            }
        }
        
        return result
    }
    
    func insertAtItem(_ identifier: String, item: FOTableItem? = nil) -> [FOTableSection] {
        var result = self as [FOTableSection]
        
        if let indexPath = findItem(identifier)  {
            result = insertAt(indexPath, item: item)
        }
        
        return result
    }
    
    func insertAtSectionEnd(_ identifier: String, item: FOTableItem? = nil) -> [FOTableSection] {
        var result = self as [FOTableSection]
        
        if let index = findSection(identifier)  {
            let section = result[index]
            let indexPath = IndexPath(item: section.items!.count, section: index)
            result = result.insertAt(indexPath, item: item)
        }
        
        return result
    }
    
    func insertAt(_ indexPath: IndexPath, item: FOTableItem? = nil) -> [FOTableSection] {
        var result = self
        
        if
            indexPath.section < result.count,
            let section = result[indexPath.section] as? DemoTableSection,
            let items = section.items,
            indexPath.item <= items.count
        {
            section.items?.insert(item ?? DemoTableItem(identifier: result.newItemIdentifier(section: section), color: section.color), at: indexPath.item)
        }
        
        return result
    }
    
    func moveItem(_ identifier: String) -> [FOTableSection] {
        var result = self as [FOTableSection]
        
        if
            let indexPath = findItem(identifier),
            let item = getAt(indexPath)
        {
            result = result.deleteAt(indexPath)
            result = result.insertAt(result.randomIndexPath(), item: item)
        }
        
        return result
    }
    
    func itemIdentifiers() -> [String] {
        return reduce([String](), { (sResult, section) -> [String] in
            if let items = section.items {
                return sResult + items.reduce([String](), { (iResult, item) -> [String] in
                    if let identifier = item.identifier {
                        return iResult + [identifier]
                    } else {
                        return iResult
                    }
                })
            } else {
                return sResult
            }
        })
    }
    
    func sectionIdentifiers() -> [String] {
        return reduce([String](), { (sResult, section) -> [String] in
            if let identifier = section.identifier {
                return sResult + [identifier]
            } else {
                return sResult
            }
        })
    }
    
    func newItemIdentifier(section: FOTableSection) -> String {
        let iIdentifiers = itemIdentifiers()
        let sIdentifiers = section.items!.map{$0.identifier!}
        var result = sIdentifiers.first!
        var count = Int(0)
        
        while iIdentifiers.contains(result) {
            result = section.identifier!.lowercased() + String(count)
            count += 1
        }
        
        return result
    }
    
}

private extension Array {
    
    func select(_ p: Double) -> [String] {
        return filter{
            _ in
            randomP() <= p
        } as! [String]
    }
    
}

private extension UIColor {

    class func random() -> UIColor {
        return UIColor(red: CGFloat(randomP()),
                       green: CGFloat(randomP()),
                       blue: CGFloat(randomP()),
                       alpha: 1.0)
    }
    
}

private func randomP() -> Double {
    return Double(arc4random()) / Double(UInt32.max)
}

private func random(range: CountableRange<UInt32>) -> UInt32 {
    return range.lowerBound + arc4random_uniform(range.upperBound - range.lowerBound)
}
