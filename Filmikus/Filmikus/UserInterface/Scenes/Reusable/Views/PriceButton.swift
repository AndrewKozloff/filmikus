//
//  PriceButton.swift
//  Filmikus
//
//  Created by Андрей Козлов on 03.06.2020.
//  Copyright © 2020 Андрей Козлов. All rights reserved.
//

import UIKit

class PriceButton: UIButton {
		
	private let insets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
	
	override var intrinsicContentSize: CGSize {
		let defaultSize = super.intrinsicContentSize
		let width = defaultSize.width + insets.left + insets.right
		let height = defaultSize.height + insets.top + insets.bottom
		return CGSize(width: width, height: height)
	}
	
	override var isSelected: Bool {
		didSet {
			backgroundColor = isSelected ? .appBlue : .appQualityBackground
		}
	}
	
	init(text: String, target: Any?, action: Selector) {
		super.init(frame: .zero)
		addTarget(target, action: action, for: .touchUpInside)
		titleLabel?.font = .boldSystemFont(ofSize: 12)
		titleLabel?.lineBreakMode = .byWordWrapping
		titleLabel?.textAlignment = .center
		setTitle(text, for: .normal)
		backgroundColor = .appQualityBackground
		setTitleColor(.appQualityTextColor, for: .normal)
		setTitleColor(.white, for: .selected)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		rounded(radius: bounds.height / 2)
	}
}
