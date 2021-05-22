//
//  CustomAlertView.swift
//  Video Editor
//
//  Created by Krish Shah on 21/05/21.
//

import UIKit

class CustomAlertView: UIView {

    let textBox = UITextView()
    let cancelButton = UIButton(type: .system)
    let defualtButton = UIButton(type: .system)
    
    var defualtAction: ((String) -> Void)
    
    let titleLabel = UILabel()
    let messageLabel = UILabel()
    
    init(defualtAction: @escaping ((String)-> Void), actionTitle: String, title: String, message: String) {
        defualtButton.setTitle(actionTitle, for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        self.defualtAction = defualtAction
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 300, height: 500)))
        titleLabel.text = title
        messageLabel.text = message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        
        self.layer.cornerRadius = 20
        
        // adding other views
        self.addSubview(titleLabel)
        self.addSubview(messageLabel)
        self.addSubview(textBox)
        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, defualtButton])
        self.addSubview(buttonStack)
        
        // Setting up the required constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        messageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        messageLabel.font = .systemFont(ofSize: 18)
        messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        messageLabel.numberOfLines = 100
        
        defualtButton.translatesAutoresizingMaskIntoConstraints = false
        defualtButton.addTarget(self, action: #selector(buttonAction), for: .touchDown)
        defualtButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(dismiss), for: .touchDown)
        cancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        textBox.isEditable = true
        textBox.text = "OVERLAY"
        textBox.backgroundColor = .black
        textBox.textColor = .white
        textBox.translatesAutoresizingMaskIntoConstraints = false
        textBox.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        textBox.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        textBox.topAnchor.constraint(equalTo: self.messageLabel.bottomAnchor, constant: 20).isActive = true
        textBox.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -20).isActive = true
        textBox.backgroundColor = UIColor(white: 1, alpha: 0.4)
        textBox.layer.cornerRadius = 20
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .vertical
        buttonStack.alignment = .center
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 0
        buttonStack.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        buttonStack.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        buttonStack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        buttonStack.heightAnchor.constraint(equalToConstant: 100).isActive = true
    
        self.backgroundColor = .black
    }
    
    @objc func buttonAction() {
        defualtAction(textBox.text)
        dismiss()
    }
    
    @objc func dismiss() {
        self.removeFromSuperview()
    }

}
