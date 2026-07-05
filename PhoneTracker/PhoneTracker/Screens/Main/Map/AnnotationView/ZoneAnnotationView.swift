//
//  ZoneAnnotationView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import MapKit

class ZoneAnnotationView: MKAnnotationView {
    private var iconContainerView: UIView!
    private var overlayView: UIView!
    private var iconImageView: UIImageView!
    private var pinSphereView: UIView!
    private var currentIconName: String?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with zone: ZoneInfo) {
        guard currentIconName != zone.zoneIcon else { return }
        
        currentIconName = zone.zoneIcon
        updateIcon(with: zone.zoneIcon)
    }
    
    private func setupView() {
        self.canShowCallout = true
        self.frame = CGRect(x: 0, y: 0, width: 48, height: 62)
        self.centerOffset = CGPoint(x: 0, y: -28) // 56 - 31 + 3
        
        iconContainerView = UIView()
        iconContainerView.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        iconContainerView.layer.cornerRadius = 16
        iconContainerView.layer.masksToBounds = true
        iconContainerView.backgroundColor = UIColor(AppColors.mainBG)
        addSubview(iconContainerView)
        
        overlayView = UIView()
        overlayView.frame = iconContainerView.bounds
        overlayView.layer.cornerRadius = 16
        overlayView.layer.masksToBounds = true
        overlayView.isUserInteractionEnabled = false
        iconContainerView.addSubview(overlayView)
        
        iconImageView = UIImageView()
        iconImageView.frame = CGRect(x: 12, y: 12, width: 24, height: 24)
        iconImageView.contentMode = .scaleAspectFit
        iconContainerView.addSubview(iconImageView)
        
        pinSphereView = UIView()
        pinSphereView.frame = CGRect(x: 21, y: 56, width: 6, height: 6)
        pinSphereView.layer.cornerRadius = 3
        pinSphereView.backgroundColor = .white
        addSubview(pinSphereView)
    }
    
    private func updateIcon(with iconName: String) {
        let zoneIcon = GeofenceMarker.allCases.first(where: { $0.imageName == iconName }) ?? .residence
        let newImage = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        iconImageView.image = newImage
        iconImageView.tintColor = UIColor(zoneIcon.tintColor)
        overlayView.backgroundColor = UIColor(zoneIcon.tintColor.opacity(0.08))
    }
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

class ZoneCircle: MKCircle {
    var isPreview: Bool = false
    
    static func create(for zone: ZoneInfo, isPreview: Bool = false) -> ZoneCircle {
        guard zone.boundaryCoordinates.count >= 2 else {
            fatalError("Invalid zone coordinates")
        }
        
        let circle = ZoneCircle(
            center: CLLocationCoordinate2D(
                latitude: zone.boundaryCoordinates[1],
                longitude: zone.boundaryCoordinates[0]
            ),
            radius: CLLocationDistance(zone.radius)
        )
        circle.isPreview = isPreview
        return circle
    }
}
