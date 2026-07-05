//
//  HistoryPointAnnotationView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import MapKit

class HistoryPointAnnotationView: MKAnnotationView {
    private var outerCircle: UIView!
    private var middleCircle: UIView!
    private var innerCircle: UIView!
    
    var isSelectedPoint: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        self.backgroundColor = .clear
        self.zPriority = .min
        
        setupCircles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCircles() {
        outerCircle = UIView(frame: self.bounds)
        outerCircle.backgroundColor = UIColor(AppColors.accentBorder)
        outerCircle.layer.cornerRadius = 12
        self.addSubview(outerCircle)
        
        middleCircle = UIView(frame: CGRect(x: 2, y: 2, width: 20, height: 20))
        middleCircle.backgroundColor = UIColor(AppColors.circlePrimary)
        middleCircle.layer.cornerRadius = 10
        outerCircle.addSubview(middleCircle)
        
        innerCircle = UIView(frame: CGRect(x: 6, y: 6, width: 12, height: 12))
        innerCircle.backgroundColor = UIColor(isSelectedPoint ? .white : AppColors.circleSecondary)
        innerCircle.layer.cornerRadius = 6
        outerCircle.addSubview(innerCircle)
    }
    
    private func updateAppearance() {
        if isSelectedPoint {
            innerCircle.backgroundColor = .white
        } else {
            innerCircle.backgroundColor = UIColor(AppColors.circleSecondary)
        }
    }
    
    func setSelected(_ selected: Bool) {
        isSelectedPoint = selected
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isSelectedPoint = false
        updateAppearance()
    }
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
