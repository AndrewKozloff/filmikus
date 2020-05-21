//
//  ProfileViewController.swift
//  Filmikus
//
//  Created by Андрей Козлов on 13.05.2020.
//  Copyright © 2020 Андрей Козлов. All rights reserved.
//

import UIKit
import SnapKit

class ProfileViewController: UIViewController {
	
	private lazy var scrollView = UIScrollView()
	private lazy var containerView = UIView()
	
	private lazy var segmentControl: UISegmentedControl = {
		let segment = UISegmentedControl(items: ["По логину", "По номеру телефона"])
		segment.addTarget(self, action: #selector(segmentControlChanged), for: .valueChanged)
		segment.backgroundColor = .white
		segment.selectedSegmentIndex = 0
		segment.selectedSegmentTintColor = .appBlue
		segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
		return segment
	}()
	
	private lazy var loginTextField: UnderlinedTextField = {
		let textField = UnderlinedTextField(placeholder: "Введите логин")
		textField.textContentType = .nickname
		textField.delegate = self
		return textField
	}()
	private lazy var passwordTextField: PasswordUnderlinedTextField = {
		let textField = PasswordUnderlinedTextField(placeholder: "Введите пароль")
		textField.delegate = self
		return textField
	}()
	private lazy var phoneTextField: UnderlinedTextField = {
		let textField = UnderlinedTextField(placeholder: "Введите номер телефона")
		textField.delegate = self
		textField.keyboardType = .phonePad
		textField.textContentType = .telephoneNumber
		textField.isHidden = true
		return textField
	}()
	
	private lazy var signUpButton = BlueButton(title: "РЕГИСТРАЦИЯ", target: self, action: #selector(onSignUpButtonTap))
	private lazy var signInButton = BlueButton(title: "ВОЙТИ", target: self, action: #selector(onSignInButtonTap))
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .white
		scrollView.keyboardDismissMode = .interactive
		view.addSubview(scrollView)
		scrollView.addSubview(containerView)
		
		containerView.addSubview(segmentControl)
		containerView.addSubview(loginTextField)
		containerView.addSubview(passwordTextField)
		containerView.addSubview(phoneTextField)
		containerView.addSubview(signUpButton)
		containerView.addSubview(signInButton)
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		let frameGuide = scrollView.frameLayoutGuide
		let contentGuide = scrollView.contentLayoutGuide
		
		frameGuide.snp.makeConstraints {
			$0.edges.equalTo(view)
			$0.width.equalTo(contentGuide)
		}
		containerView.snp.makeConstraints {
			$0.edges.equalTo(contentGuide)
		}
		
		segmentControl.snp.makeConstraints {
			$0.top.equalToSuperview().offset(30)
			$0.centerX.equalToSuperview()
		}

		loginTextField.snp.makeConstraints {
			$0.top.equalTo(segmentControl.snp.bottom).offset(40)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
		}
		passwordTextField.snp.makeConstraints {
			$0.top.equalTo(loginTextField.snp.bottom).offset(20)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
		}
		phoneTextField.snp.makeConstraints {
			$0.top.equalTo(segmentControl.snp.bottom).offset(40)
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
		}
		signUpButton.snp.makeConstraints {
			$0.top.equalTo(passwordTextField.snp.bottom).offset(20)
			$0.centerX.equalToSuperview()
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.height.equalTo(44)
		}
		signInButton.snp.makeConstraints {
			$0.top.equalTo(signUpButton.snp.bottom).offset(20)
			$0.centerX.bottom.equalToSuperview()
			$0.leading.equalToSuperview().offset(20)
			$0.trailing.equalToSuperview().offset(-20)
			$0.height.equalTo(44)
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		title = "Профиль"
		

	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillShow),
			name: UIResponder.keyboardWillShowNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(keyboardWillHide),
			name: UIResponder.keyboardWillHideNotification,
			object: nil
		)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		view.endEditing(true)
	}
	
	@objc
	private func keyboardWillShow(notification: Notification) {
		guard let userInfo = notification.userInfo else { return }
		guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
		scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
	}
	
	@objc
	private func keyboardWillHide(notification: Notification) {
		scrollView.contentInset = .zero
	}
	
	@objc
	private func segmentControlChanged(sender: UISegmentedControl) {
		let isLoginAuth = sender.selectedSegmentIndex == 0
		self.loginTextField.isHidden = !isLoginAuth
		self.passwordTextField.isHidden = !isLoginAuth
		self.phoneTextField.isHidden = isLoginAuth
	}
	
	@objc
	private func onSignUpButtonTap(sender: UIButton) {
		let signUpVC = SignUpViewController()
		navigationController?.pushViewController(signUpVC, animated: true)
	}
    
	@objc
	private func onSignInButtonTap(sender: UIButton) {
		
	}

}

extension ProfileViewController: UITextFieldDelegate {
//	func textFieldDidBeginEditing(_ textField: UITextField) {
//		scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 500, right: 0)
//	}
//
//	func textFieldDidEndEditing(_ textField: UITextField) {
//		scrollView.contentInset = .zero
//	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}