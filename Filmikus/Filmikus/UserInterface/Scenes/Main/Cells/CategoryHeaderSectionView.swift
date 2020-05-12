//
//  CategoryHeaderSectionView.swift
//  Filmikus
//
//  Created by Андрей Козлов on 12.05.2020.
//  Copyright © 2020 Андрей Козлов. All rights reserved.
//

import UIKit

class CategoryHeaderSectionView: ReusableTableHeaderFooterView {
	
	private let labelTitle: UILabel = {
		let label = UILabel()
		label.font = .boldSystemFont(ofSize: 17)
		label.textColor = .white
		return label
	}()
	
	private lazy var buttonMore: MoreButton = {
		let button = MoreButton()
		button.addTarget(self, action: #selector(onButtonMoreTap), for: .touchUpInside)
		return button
	}()

	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		backgroundView = UIView()
		
		contentView.addSubview(labelTitle)
		contentView.addSubview(buttonMore)
		
		labelTitle.snp.makeConstraints {
			$0.left.equalToSuperview().offset(12)
			$0.centerY.equalToSuperview()
		}
		buttonMore.snp.makeConstraints {
			$0.right.equalToSuperview().offset(-12)
			$0.centerY.equalToSuperview()
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		labelTitle.text = nil
	}
	
	func fill(title: String) {
		labelTitle.text = title
	}
	
	@objc
	private func onButtonMoreTap(sender: UIButton) {
		print("More")
	}
	
}
