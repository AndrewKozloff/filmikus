//
//  LaunchViewController.swift
//  Filmikus
//
//  Created by Андрей Козлов on 27.07.2020.
//  Copyright © 2020 Андрей Козлов. All rights reserved.
//

import UIKit
import SnapKit

protocol LaunchViewControllerDelegate: class {
    func launchViewController(_ viewController: LaunchViewController, didReceiveAccess type: WelcomeTypeModel)
    func launchViewControllerDidShowAllContent(_ viewController: LaunchViewController)
}

class LaunchViewController: UIViewController {
    
    weak var delegate: LaunchViewControllerDelegate?
    
    private let userFacade: UserFacadeType = UserFacade()
    
    private lazy var logoImageView = UIImageView(image: UIImage(named: "logo"))
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .appDarkBlue
        view.addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userFacade.isLaunchedBefore {
            delegate?.launchViewControllerDidShowAllContent(self)
        } else {
            userFacade.setLaunchBefore()
            userFacade.welcomeType { (result) in
                switch result {
                case .success(let accessType):
                    self.delegate?.launchViewController(self, didReceiveAccess: accessType)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}