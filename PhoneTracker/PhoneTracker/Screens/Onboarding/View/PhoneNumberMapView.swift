//
//  PhoneNumberMapView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import MapKit
import SwiftUI

struct PhoneNumberMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var verticalOffsetPercent: CLLocationDegrees = -0.2
    var showUserAnnotation: Bool = false
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.isUserInteractionEnabled = false
        mapView.alpha = 0.8
        mapView.showsUserLocation = false
        let offsetRegion = calculateOffsetRegion(for: region, in: mapView)
        mapView.setRegion(offsetRegion, animated: false)
        
        return mapView
    }
    
    private func calculateOffsetRegion(for region: MKCoordinateRegion, in mapView: MKMapView) -> MKCoordinateRegion {
            let offsetInDegrees = region.span.latitudeDelta * verticalOffsetPercent * 2
            
            let offsetCoordinate = CLLocationCoordinate2D(
                latitude: region.center.latitude + offsetInDegrees,
                longitude: region.center.longitude
            )
            
            return MKCoordinateRegion(
                center: offsetCoordinate,
                span: region.span
            )
        }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        let offsetRegion = calculateOffsetRegion(for: region, in: mapView)
        mapView.setRegion(offsetRegion, animated: true)
        
        updateUserAnnotation(on: mapView)
    }
    
    private func updateUserAnnotation(on mapView: MKMapView) {
        let annotationsToRemove = mapView.annotations.filter {
            $0 is UserAnnotation
        }
        mapView.removeAnnotations(annotationsToRemove)
        
        if showUserAnnotation {
            let userAnnotation = UserAnnotation(coordinate: region.center)
            mapView.addAnnotation(userAnnotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: PhoneNumberMapView
        
        init(_ parent: PhoneNumberMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let userAnnotation = annotation as? UserAnnotation {
                return createUserAnnotationView(for: userAnnotation, in: mapView)
            }
            
            return nil
        }
        
        private func createUserAnnotationView(for annotation: UserAnnotation, in mapView: MKMapView) -> MKAnnotationView {
            let identifier = "userLocation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
                
                let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
                containerView.backgroundColor = .clear
                
                let zoneDiameter: CGFloat = 16
                let zoneView = UIView(frame: CGRect(
                    x: (containerView.bounds.width - zoneDiameter) / 2,
                    y: (containerView.bounds.height - zoneDiameter) / 2,
                    width: zoneDiameter,
                    height: zoneDiameter
                ))
                zoneView.layer.cornerRadius = zoneDiameter / 2
                zoneView.backgroundColor = UIColor(AppColors.accentBlue)
                zoneView.layer.borderColor = UIColor.white.cgColor
                zoneView.layer.borderWidth = 2
                zoneView.isUserInteractionEnabled = false
                
                containerView.addSubview(zoneView)
                
                annotationView?.addSubview(containerView)
                annotationView?.frame = containerView.frame
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView!
        }
    }
}

class UserAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
