//
//  CardCollectionViewCell.swift
//  FinalGame
//
//  Created by Meirkhan Nishonov on 19.05.2023.
//

import UIKit
import SnapKit

class CardCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CardCell"
    
    private let cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    private let backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "back")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(cardImageView)
        cardImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(backImageView)
        backImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backgroundColor = .clear
        
        layer.cornerRadius = 8
//        layer.borderColor = UIColor.lightGray.cgColor
//        backgroundColor = .systemGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var card: Card?
    func setCard(_ card: Card) {
        
        if card.isMatched {
            
            backImageView.alpha = 0
            cardImageView.alpha = 0
            
            return
            
        } else {
            
            backImageView.alpha = 1
            cardImageView.alpha = 1
        }
        
        self.card = card
        
        cardImageView.image = UIImage(named: card.imageName)
        
        if card.isFlipped {
            
            UIView.transition(from: backImageView, to: cardImageView, duration: 0, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
            
        } else {
            
            UIView.transition(from: cardImageView, to: backImageView, duration: 0, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        }
    }
    
    func flip() {
        
        UIView.transition(from: backImageView, to: cardImageView, duration: 0.3, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
    }
    
    func flipBack() {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            
            UIView.transition(from: self.cardImageView, to: self.backImageView, duration: 0.3, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        })
    }
    
    func remove() {
        
        backImageView.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseOut, animations: {
            
            self.cardImageView.alpha = 0
            
        }, completion: nil)
        
        
    }
}
