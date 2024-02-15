//
//  ViewController.swift
//  FinalGame
//
//  Created by Meirkhan Nishonov on 18.05.2023.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var restartButton: UIButton!
    private var shuffleButton: UIButton!
    private var timeRemaining: UILabel!
    
    private var cardArray: [Card] = []
    private var firstFlippedCardIndex: IndexPath?
    private var isGameEnded = false
    
    var timer: Timer?
    var milliseconds: Float = 35 * 1000 // 35 seconds
    
    var model = CardModel()
    let backgroundImageView = UIImageView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        backgroundImageView.image = UIImage(named: "background")
        
        setupCollectionView()
        setupButtonsAndLabel()
        
        
        startNewGame()
        
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerElapsed), userInfo: nil, repeats: true)
        
        RunLoop.main.add(timer!, forMode: .common)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        SoundManager.playSound(.shuffle)
    }
    
    // MARK: - Timer Methods
    
    @objc func timerElapsed() {
        
        milliseconds -= 1
        
        let seconds = String(format: "%.2f", milliseconds/1000)
        timeRemaining.text = "Time remaining: \(seconds)"
        
        if milliseconds <= 0 {
            
            timer?.invalidate()
            timeRemaining.textColor = UIColor.red
            
            checkGameEnded()
        }
    }
    
    private func startNewGame() {
        isGameEnded = false
        cardArray = model.getCards()
        collectionView.reloadData()
    }
    
    @objc private func restartButtonTapped() {
        // Reset game state
        milliseconds = 35 * 1000
        firstFlippedCardIndex = nil
        isGameEnded = false
        timeRemaining.textColor = .label

        // Start a new game
        startNewGame()

        // Reset timer
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(timerElapsed), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    @objc private func shuffleButtonTapped() {
        
        for card in cardArray {
            
            if card.isFlipped == true && firstFlippedCardIndex != nil{
                
                let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCollectionViewCell
                cardOneCell?.flipBack()
                card.isFlipped = false

            }
        }
        SoundManager.playSound(.shuffle)
        collectionView.isUserInteractionEnabled = false
            
        // Create a copy of the original card array
        let originalCardArray = cardArray
        
        // Generate shuffled indexes
        let shuffledIndexes = cardArray.indices.shuffled()
        
        // Create an empty array for the shuffled cards
        var shuffledCards: [Card] = []
        
        // Iterate over the shuffled indexes
        for shuffledIndex in shuffledIndexes {
            // Get the card at the shuffled index from the original card array
            let card = originalCardArray[shuffledIndex]
            // Add the card to the shuffled cards array
            shuffledCards.append(card)
        }
        
        // Perform the sliding animation
        UIView.animate(withDuration: 0.5, animations: {
            self.collectionView.performBatchUpdates({
                // Update the card array with the shuffled cards
                self.cardArray = shuffledCards
                // Perform the move item operation for each shuffled index
                for (index, shuffledIndex) in shuffledIndexes.enumerated() {
                    let indexPath = IndexPath(row: shuffledIndex, section: 0)
                    let newIndexPath = IndexPath(row: index, section: 0)
                    self.collectionView.moveItem(at: indexPath, to: newIndexPath)
                }
            }, completion: { (_) in
                // Re-enable user interaction after shuffling completes
                self.collectionView.isUserInteractionEnabled = true
            })
        })
        
                    
    }
    
    func checkForMatches(_ secondFlippedCardIndex: IndexPath) {
     
        let cardOneCell = collectionView.cellForItem(at: firstFlippedCardIndex!) as? CardCollectionViewCell
        let cardTwoCell = collectionView.cellForItem(at: secondFlippedCardIndex) as? CardCollectionViewCell
        
        let cardOne = cardArray[firstFlippedCardIndex!.row]
        let cardTwo = cardArray[secondFlippedCardIndex.row]
        
        if cardOne.imageName == cardTwo.imageName {
            
            SoundManager.playSound(.match)
            
            cardOne.isMatched = true
            cardTwo.isMatched = true
            
            cardOneCell?.remove()
            cardTwoCell?.remove()
            
            checkGameEnded()
            
        } else {
            
            SoundManager.playSound(.nomatch)
            
            cardOne.isFlipped = false
            cardTwo.isFlipped = false
            
            cardOneCell?.flipBack()
            cardTwoCell?.flipBack()
            
        }
        
        if cardOneCell == nil {
            
            collectionView.reloadItems(at: [firstFlippedCardIndex!])
        }
        
        firstFlippedCardIndex = nil
    }
    
    func checkGameEnded() {
        
        var isWon = true
        
        for card in cardArray {
            
            if card.isMatched == false {
                
                isWon = false
                break
            }
        }
        
        var title = ""
        var message = ""
        
        if isWon == true {
            
            if milliseconds > 0 {
                
                timer?.invalidate()
            }
            
            title = "Congratulations!!!"
            message = "You've won"
            
        } else {
            
            if milliseconds > 0 {
                
                return
            }
            
            title = "Game Over"
            message = "You've lost"
        }
        
        showAlert(title, message)
    }
    
    func showAlert(_ title: String, _ message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        let itemWidth = (view.frame.width - 64) / 4
        let itemHeight = itemWidth * 1.5
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = true
        
        collectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-150)
        }
    }
    
    private func setupButtonsAndLabel() {
        timeRemaining = UILabel()
        timeRemaining.textAlignment = .center
        timeRemaining.textColor = .label
        timeRemaining.font = UIFont.systemFont(ofSize: 18)
        timeRemaining.text = "Time remaining: 0.00"
        
        restartButton = UIButton(type: .system)
        restartButton.setTitle("Restart", for: .normal)
        restartButton.addTarget(self, action: #selector(restartButtonTapped), for: .touchUpInside)
        
        shuffleButton = UIButton(type: .system)
        shuffleButton.setTitle("Shuffle", for: .normal)
        shuffleButton.addTarget(self, action: #selector(shuffleButtonTapped), for: .touchUpInside)
        
        view.addSubview(timeRemaining)
        view.addSubview(restartButton)
        view.addSubview(shuffleButton)
        
        timeRemaining.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        restartButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
        }
        
        shuffleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.reuseIdentifier, for: indexPath) as! CardCollectionViewCell
        
        let card = cardArray[indexPath.row]
        cell.setCard(card)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if milliseconds <= 0 {
            return
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell {
            let card = cardArray[indexPath.row]
            
            if !card.isFlipped && !card.isMatched && firstFlippedCardIndex == nil {
                cell.flip()
                card.isFlipped = true
                firstFlippedCardIndex = indexPath
            } else if !card.isFlipped && !card.isMatched && firstFlippedCardIndex != nil {
                cell.flip()
                card.isFlipped = true
                
                if firstFlippedCardIndex != nil {
                    checkForMatches(indexPath)
                    collectionView.isUserInteractionEnabled = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.collectionView.isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
}




