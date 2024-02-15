//
//  CardModel.swift
//  FinalGame
//
//  Created by Meirkhan Nishonov on 19.05.2023.
//

import Foundation

class CardModel {
    
    func getCards() -> [Card] {
        
        var generatedNumbersArray = [Int]() // 4
        
        var generatedCardsArray = [Card]()
        
        while generatedNumbersArray.count < 8 {
            
            let randomNumber = arc4random_uniform(13) + 1 //
            
            if generatedNumbersArray.contains(Int(randomNumber)) == false {
                
                generatedNumbersArray.append(Int(randomNumber))
                
                let cardOne = Card()
                cardOne.imageName = "card\(randomNumber)"
                generatedCardsArray.append(cardOne)
                
                let cardTwo = Card()
                cardTwo.imageName = "card\(randomNumber)"
                generatedCardsArray.append(cardTwo)
            }
        }
        
        generatedCardsArray.shuffle()
        
        return generatedCardsArray
    }
    
}
