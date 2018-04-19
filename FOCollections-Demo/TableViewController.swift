//
//  TableViewController.swift
//  FOCollectionsExamples
//
//  Created by Daniel Krofchick on 2015-11-12.
//  Copyright © 2015 Figure 1 Inc. All rights reserved.
//

import UIKit

let sectionMoveP = 0.5
let sectionDeleteP = 0.2
let sectionInsertP = 0.6
let itemMoveP = 0.4
let itemDeleteP = 0.2
let itemInsertP = 0.2
let newItemP = 0.7
let newSectionP = 0.99
let sliderMin = Float(0.0)
let sliderMax = Float(1.0)

class TableViewController: FOTableViewController {
    
    let refresh = UIButton(type: .system)
    let slider = UISlider()
    var autoPlay = true {
        didSet {
            play = autoPlay
        }
    }
    var play = false {
        didSet {
            configureBarItems()
            
            if play {
                doMutate()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.orange
        
        slider.minimumValue = sliderMin
        slider.maximumValue = sliderMax
        slider.value = (sliderMax - sliderMin) * 0.5
        navigationItem.titleView = slider
        
        play = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        play = false
    }
    
    func configureBarItems() {
        var items = [UIBarButtonItem]()
        
        let autoPlayItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(didSelectAutoPlay))

        if !autoPlay {
            autoPlayItem.tintColor = .red
        }

        items.append(autoPlayItem)
        
        if play {
            items.append(UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(didSelectPlay)))
        } else {
            items.append(UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(didSelectPlay)))
        }
        
        navigationItem.rightBarButtonItems = items
    }
    
    func didSelectPlay() {
        play = !play
    }
    
    func didSelectAutoPlay() {
        autoPlay = !autoPlay
    }
    
    var count = Int(0)
    
    func doMutate() {
        queueWork {
            [weak self] in
            if
                let this = self,
                this.play
            {
                let oldSections = this.dataSource.sections
                var newSections = [FOTableSection]()
                
                while newSections.isEmpty || newSections.compare(oldSections) {
                    newSections = this.mutate(oldSections)
                }
                
                this.count += 1
                print("-\(this.count)-")
                oldSections.log(title: " ")
                newSections.log(title: ">")
                
                let date = Date()
                this.animateUpdate(newSections, with: .automatic, duration: TimeInterval(this.slider.value), completion: {
                    print("animateUpdate", Date().timeIntervalSince(date), "slider", TimeInterval(this.slider.value))
                    
                    if this.autoPlay {
                        this.doMutate()
                    } else {
                        this.play = false
                    }
                })
            }
        }
    }
    
    func mutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections
        
        result = sectionDeleteMutate(result)
        result = sectionMoveMutate(result)
        result = sectionInsertMutate(result)
        result = itemDeleteMutate(result)
        result = itemMoveMutate(result)
        result = itemInsertMutate(result)
        
        return result
    }
    
}

extension TableViewController {
    
    func sectionMoveMutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections
        
        sections.enumerated().forEach{
            s in
            let toIndex = random(range: 0..<result.count)
            
            if toIndex != s.offset && randomP() <= sectionMoveP {
                result = rearrange(array: result, fromIndex: s.offset, toIndex: toIndex)
            }
        }
        
        return result
    }
    
    func sectionDeleteMutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections
        
        sections.enumerated().reversed().forEach{
            s in
            if randomP() <= sectionDeleteP {
                result.remove(at: s.offset)
            }
        }
        
        return result
    }
    
    func sectionInsertMutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections
        
        if sections.count > 0 {
            sections.enumerated().reversed().forEach{
                s in
                if randomP() <= sectionInsertP {
                    let newSection = result.createSection()
                    result.insert(newSection, at: s.offset)
                }
            }
        } else {
            while randomP() <= newSectionP {
                let newSection =  result.createSection()
                result.insert(newSection, at: 0)
            }
        }
        
        return result
    }

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
    
    fileprivate func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T> {
        var arr = array
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        
        return arr
    }

}

extension Array where Element:FOTableSection {
    
    func log(title: String) {
        forEach({ (section) in
            print(title, section.identifier!, section.items!.reduce([String](), { (result, item) -> [String] in
                return result + [item.identifier!]
            }))
        })
    }
    
}

private extension Array where Element:FOTableSection {
    
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
            section.items?.insert(item ?? DemoTableItem(identifier: result.newItemIdentifier(sectionIdentifier: section.identifier!), color: section.color), at: indexPath.item)
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
    
    func newItemIdentifier(sectionIdentifier: String, omit: [String] = [String]()) -> String {
        let iIdentifiers = itemIdentifiers() + omit
        var count = 0
        var result = ""
        
        repeat {
            result = sectionIdentifier.lowercased() + String(count)
            count += 1
        } while iIdentifiers.contains(result)
        
        return result
    }
    
    func newSectionIdentifier() -> String {
        let sIdentifiers = sectionIdentifiers()
        let sectionCharacters = "abcdefghijklmnopqrstuvwxyz"
        let characterIndex = Int(random(range: 0..<sectionCharacters.characters.count))
        let index = sectionCharacters.index(sectionCharacters.startIndex, offsetBy: characterIndex)
        let character = String(sectionCharacters[index]).uppercased()
        
        var result = character

        while sIdentifiers.contains(result) {
            result = result + character
        }
        
        return result
    }
    
    func createSection() -> FOTableSection {
        let sectionIdentifier = newSectionIdentifier()
        var itemIdentifiers = [String]()
        
        while randomP() <= newItemP {
            itemIdentifiers.append(newItemIdentifier(sectionIdentifier: sectionIdentifier, omit: itemIdentifiers))
        }
        
        return section(sectionIdentifier, identifiers: itemIdentifiers, color: .random())
    }
    
    func compare(_ sections: [FOTableSection]) -> Bool {
        let aItemIdentifiers = itemIdentifiers()
        let bItemIdentifiers = sections.itemIdentifiers()
        let aSectionIdentifiers = sectionIdentifiers()
        let bSectionIdentifiers = sections.sectionIdentifiers()
        
        return aItemIdentifiers == bItemIdentifiers && aSectionIdentifiers == bSectionIdentifiers
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

private func random(range: Range<Int>) -> Int {
    return Int(range.lowerBound) + Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound)))
}

private func section(_ sectionIdentifier: String, identifiers: [String], color: UIColor) -> FOTableSection {
    let section = DemoTableSection(identifier: sectionIdentifier, color: color)
    
    section.items = identifiers.map{DemoTableItem(identifier: $0, color: color)}
    
    return section
}
