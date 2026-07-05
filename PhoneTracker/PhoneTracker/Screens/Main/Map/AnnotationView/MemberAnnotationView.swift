//
//  MemberAnnotationView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import MapKit
import Factory

class PersonAnnotationView: MKAnnotationView {
    private var backgroundImageView: UIImageView!
    private var avatarImageView: UIImageView!
    private var batteryView: UIView!
    private var batteryImageView: UIImageView!
    private var pinSphereView: UIView!
    private var currentAvatarURL: String?
    private var lastBatteryLevel: Int?
    private var lastName: String?
    private var isCurrentUserAnnotation = false
    
    @Injected(\.userDefaultsService) private var userDefaultsService
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with annotation: PersonAnnotation) {
        self.isCurrentUserAnnotation = annotation.isCurrentUser
        
        if currentAvatarURL != annotation.avatarURL || annotation.avatarURL == nil {
            currentAvatarURL = annotation.avatarURL
            
            if let avatarURL = annotation.avatarURL, !avatarURL.isEmpty {
                loadImage(from: avatarURL) { [weak self] image in
                    self?.updateAvatarImage(image ?? UIImage(named: AssetCatalog.avatarImg))
                }
            } else {
                updateAvatarImage(UIImage(named: AssetCatalog.avatarImg))
            }
        }
        
        if lastName != annotation.title || lastBatteryLevel != annotation.batteryLevel {
            updateUserInfo(annotation: annotation)
            lastName = annotation.title
            lastBatteryLevel = annotation.batteryLevel
        }
    }
    
    private func setupView() {
        self.canShowCallout = true
        self.frame = CGRect(x: 0, y: 0, width: 54, height: 74)
        self.centerOffset = CGPoint(x: 0, y: -34) // 68 - 37 + 3
        
        backgroundImageView = UIImageView()
        backgroundImageView.frame = CGRect(x: 0, y: 0, width: 54, height: 64)
        backgroundImageView.image = UIImage(named: AssetCatalog.pinBackground)
        backgroundImageView.contentMode = .scaleAspectFit
        addSubview(backgroundImageView)
        
        avatarImageView = UIImageView()
        avatarImageView.frame = CGRect(x: 2, y: 2, width: 50, height: 50)
        avatarImageView.layer.cornerRadius = 17
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.layer.borderWidth = 1
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.backgroundColor = UIColor(AppColors.mainBG.opacity(0.8))
        addSubview(avatarImageView)
        
        pinSphereView = UIView()
        pinSphereView.frame = CGRect(x: (54 - 6) / 2, y: 68, width: 6, height: 6)
        pinSphereView.layer.cornerRadius = 3
        pinSphereView.backgroundColor = .white
        addSubview(pinSphereView)
        
        batteryView = UIView()
        batteryView.frame = CGRect(x: 38, y: 40, width: 24, height: 24)
        batteryView.layer.cornerRadius = 12
        batteryView.backgroundColor = .white
        batteryView.layer.masksToBounds = false
        batteryView.isHidden = true
        addSubview(batteryView)
        
        batteryImageView = UIImageView()
        batteryImageView.frame = CGRect(x: 3, y: 3, width: 18, height: 18)
        batteryImageView.contentMode = .scaleAspectFit
        batteryView.addSubview(batteryImageView)
    }
    
    private func updateAvatarImage(_ image: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            self?.avatarImageView.image = image?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    private func updateUserInfo(annotation: PersonAnnotation) {
        if annotation.isCurrentUser && !userDefaultsService.batteryTrackingEnabled {
            batteryView.isHidden = true
            return
        }
        
        if let batteryLevel = annotation.batteryLevel, batteryLevel != 0 {
            batteryView.isHidden = false
            batteryImageView.image = batteryImageName(for: batteryLevel)
        } else {
            batteryView.isHidden = true
        }
    }
    
    private func loadImage(
        from urlString: String,
        completion: @escaping (UIImage?) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(UIImage(named: AssetCatalog.avatarImg))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(UIImage(named: AssetCatalog.avatarImg))
            }
        }.resume()
    }
    
    public func batteryImageName(for batteryLevel: Int) -> UIImage? {
        let imageName: String
        
        switch batteryLevel {
        case 0...20:
            imageName = AssetCatalog.powerLow
        case 21...50:
            imageName = AssetCatalog.powerMid
        case 51...100:
            imageName = AssetCatalog.powerFull
        default:
            imageName = AssetCatalog.powerFull
        }
        
        return UIImage(named: imageName)
    }
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
