//
//  ContentView.swift
//  WordScramble
//
//  Created by Arthur Mendonça Sasse on 31/07/20.
//  Copyright © 2020 Arthur Mendonça Sasse. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var newWord = ""
    @State private var rootWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0.0
    
    var body: some View {
        NavigationView{
            VStack{
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                List(usedWords, id: \.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                
                Text("Score: \(score, specifier: "%g")")
                    .font(.title)
                
            }
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame).alert(isPresented: $showingError){
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarItems(trailing:
                Button(action: startGame){
                    Text("Shuffle")
                }
            )
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word already used", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "Use just the letters from the original word!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Not a real word", message: "Use just words that exist in the dictionary!")
            return
        }
        
        guard hasEnoughLetters(word: answer) else {
            wordError(title: "Too easy", message: "Use words with 3 letters or more!")
            return
        }
        
        guard isDifferent(word: answer) else {
            wordError(title: "Too easy", message: "You can't use the same word!")
            return
        }
        
        usedWords.insert(answer, at: 0)
        addScore(word: answer)
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                
                rootWord = allWords.randomElement() ?? "Capybara"
                usedWords = []
                
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    // guard functions START
    func isOriginal(word: String) -> Bool {
        !(usedWords.contains(word))
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }
            else{
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return mispelledRange.location == NSNotFound
    }
    
    func hasEnoughLetters(word: String) -> Bool {
        word.count > 2
    }
    
    func isDifferent(word: String) -> Bool {
        word != rootWord
    }
    
    // guard functions END
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func addScore(word: String) {
            score = score + pow(2, Double(word.count - 3))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
