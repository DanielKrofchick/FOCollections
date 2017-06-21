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
//            self.section("G", identifiers: ["g1", "g2", "g3", "g4"], color: .blue),
//            self.section("H", identifiers: ["h1", "h2", "h3", "h4", "h5"], color: .green),
//            self.section("Z", identifiers: ["z1", "z2"], color: .cyan),
//            self.section("Y", identifiers: ["y1", "y2", "y3"], color: .yellow),
//            self.section("W", identifiers: ["w1"], color: .magenta),
//            ]
//
//        let sections2 = [
//            self.section("YY", identifiers: ["yy1", "yy2"], color: .cyan),
//            self.section("V", identifiers: ["v1", "v2", "v3", "v4", "v5"], color: .green),
//            self.section("G", identifiers: ["g1", "g2", "g3", "g4"], color: .blue),
//            self.section("Z", identifiers: ["z1", "z2"], color: .cyan),
//            self.section("W", identifiers: ["w1"], color: .magenta),
//            self.section("Y", identifiers: ["y1", "y2", "y3"], color: .yellow),
//            self.section("H", identifiers: ["h1", "h2", "h3", "h4", "h5"], color: .green),
//            ]
//
//        queueUpdate({
//            self.insertSections(sections1, indexes: IndexSet(integersIn: 0..<sections1.count))
//        })
//
//        animateUpdate(sections2)
        
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
                
                this.dataSource.sections.forEach({ (section) in
                    print("old", section.identifier!, section.items!.count)
                })
                
                let newSections = this.mutate(this.dataSource.sections)
                
                newSections.forEach({ (section) in
                    print("new", section.identifier!, section.items!.count)
                })
                
                this.animateUpdate(newSections, with: .automatic, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        this.doMutate()
                    }
                })
            }
        }
    }
    
    let moveP = 0.2
    let deleteP = 0.3
    let insertP = 0.2
    
    var deletedSectionIdentifiers = [String]()
    
    func mutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections
        
        deletedSectionIdentifiers.removeAll()
        
        result = moveMutate(result)
        result = deleteMutate(result)
        result = insertMutate(result)
        
        return result
    }
    
    func moveMutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections

        sections.enumerated().forEach{
            s in
            let toIndex = random(range: 0..<result.count)
            let p = Double(arc4random()) / Double(UInt32.max)
            
            if toIndex != s.offset && p <= moveP {
                result = rearrange(array: result, fromIndex: s.offset, toIndex: toIndex)
            }
        }
        
        return result
    }
    
    func deleteMutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections
        
        sections.enumerated().reversed().forEach{
            s in
            let p = Double(arc4random()) / Double(UInt32.max)
            
            if p <= deleteP {
                if let identifier = s.element.identifier {
                   deletedSectionIdentifiers.append(identifier)
                }
                
                result.remove(at: s.offset)
            }
        }
        
        return result
    }
    
    let maxNewItems = Int(5)
    let maxNewSections = Int(3)
    
    func insertMutate(_ sections: [FOTableSection]) -> [FOTableSection] {
        var result = sections
        
        sections.enumerated().reversed().forEach{
            s in
            let p = Double(arc4random()) / Double(UInt32.max)
            
            if p <= insertP {
                let newSection = createSection(currentSections: result)
                result.insert(newSection, at: s.offset)
            }
        }
        
        for _ in 0..<random(range: 0..<maxNewSections) {
            let newSection = createSection(currentSections: result)
            result.insert(newSection, at: 0)
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
        
        return section(newSectionIdentifier, identifiers: itemIdentifiers, color: createSectionColor())
    }
    
    func createSectionColor() -> UIColor {
        return UIColor(red: CGFloat(Double(arc4random()) / Double(UInt32.max)),
                       green: CGFloat(Double(arc4random()) / Double(UInt32.max)),
                       blue: CGFloat(Double(arc4random()) / Double(UInt32.max)),
                       alpha: 1.0)
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
        let section = FOTableSection()
        
        section.identifier = sectionIdentifier
        section.items = identifiers.map{TableCellItem(identifier: $0, color: color)}
        
        return section
    }
    
    override func nextPageForSection(_ section: FOTableSection, tableView: UITableView) {
        print("\(#function)")
    }
    
}

enum Action {
    
    
}
