//
//  WordListVC.swift
//  100 German Words
//
//  Created by Ashley Donohoe on 9/26/16.
//  Copyright © 2016 Ashley Donohoe. All rights reserved.
//

import UIKit
import CoreData

class WordListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var controller: NSFetchedResultsController<Word>!
    
    var words = [
    WordM(germanWord: "das Haus", englishWord: "the house", germanExample: "Das Haus ist grün.", englishExample: "The house is green.", learned: false, starred: true),
        WordM(germanWord: "die Tür", englishWord: "the door", germanExample: "Die Tür ist zu.", englishExample: "The door is closed.", learned: true, starred: false)
        ]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // Get the wordslist; will be updated later for AppDelegate to load SQlite DB on first run
        getWordList()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = controller.sections {
            return sections.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = controller.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordCell
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        return cell
    }
    
    func configureCell(cell: WordCell, indexPath: NSIndexPath) {
        let word = controller.object(at: indexPath as IndexPath)
        cell.configureCell(word: word)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let objs = controller.fetchedObjects, objs.count > 0 {
            let word = objs[indexPath.row]
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "ShowWordDetail", sender: word)
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWordDetail" {
            if let controller = segue.destination as? ShowWordDetail {
                if let word = sender as? Word {
                    controller.word = word
                }
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    @IBAction func segmentChanged(_ sender: AnyObject) {
        getWordList()
        tableView.reloadData()
    }
    
    // Fetches word list from core data
    func getWordList() {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        let showAll = NSSortDescriptor(key: "germanWord", ascending: true)
        
        
        if segmentedControl.selectedSegmentIndex == 0 {
            fetchRequest.sortDescriptors = [showAll]
        } else {
            //TODO: Figure out how to filter based on the starred/learned values
            fetchRequest.sortDescriptors = [showAll]
        }
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        
        self.controller = controller
        
        do {
            try controller.performFetch()
        } catch {
            let error = error as NSError
            print(error.localizedDescription)
        }
    }

}

