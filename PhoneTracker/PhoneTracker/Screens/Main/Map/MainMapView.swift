//
//  MainMapView.swift
//  PhoneTracker
//
//  Created by Игорь Николаев on 16.03.2026.
//

import SwiftUI
import MapKit

struct UnifiedMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var mapType: MKMapType
    @Binding var mode: MapMode

    @Binding var currentUser: MemberInfo?
    @Binding var previewZone: ZoneInfo?
    @Binding var previewHistory: MemberInfo?
    @Binding var selectedHistoryPosition: LocationData?
    
    @Binding var people: [MemberInfo]
    var zones: [ZoneInfo] = []
    var peopleHistory: [LocationData] = []
    
    private let minSpanDelta: CLLocationDegrees = 0.001
    private let maxSpanDelta: CLLocationDegrees = 360.0
    private let defaultSpanDelta: CLLocationDegrees = 0.01
    
    private var currentUserID: Int? {
        currentUser?.id
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.overrideUserInterfaceStyle = .dark
        mapView.showsUserLocation = false
        
        mapView.register(
            PersonAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: PersonAnnotationView.reuseIdentifier
        )
        mapView.register(
            ZoneAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: ZoneAnnotationView.reuseIdentifier
        )
        mapView.register(
            HistoryPointAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: HistoryPointAnnotationView.reuseIdentifier
        )
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        guard isValidRegion(region) else {
            setSafeDefaultRegion(uiView, context: context)
            return
        }
        
        if context.coordinator.lastMode != mode {
            uiView.removeAnnotations(uiView.annotations)
            uiView.removeOverlays(uiView.overlays)
            context.coordinator.lastMode = mode
            context.coordinator.hasCenteredOnPreview = false
            context.coordinator.lastZones = []
            context.coordinator.lastPreviewZone = nil
        }
        
        if context.coordinator.lastRegion != region {
            uiView.setRegion(region, animated: context.coordinator.shouldAnimate)
            context.coordinator.lastRegion = region
        }
        
        if context.coordinator.lastMapType != mapType {
            uiView.mapType = mapType
            context.coordinator.lastMapType = mapType
        }
        
        handlePreviewsAndCentering(uiView: uiView, context: context)
        updateAnnotationsIfNeeded(on: uiView, context: context)
    }
    
    private func handlePreviewsAndCentering(uiView: MKMapView, context: Context) {
        switch mode {
        case .history:
            context.coordinator.handlePreviewHistoryChange(previewHistory)
            
            if let position = selectedHistoryPosition,
               position.coordinatesList.count >= 2,
               !context.coordinator.isBuildingRoutes {
                
                let coordinate = CLLocationCoordinate2D(
                    latitude: position.coordinatesList[1],
                    longitude: position.coordinatesList[0]
                )
                
                centerOnPreview(
                    coordinate: coordinate,
                    uiView: uiView,
                    context: context
                )
                
                DispatchQueue.main.async {
                    selectedHistoryPosition = nil
                }
                context.coordinator.selectedHistoryPosition = position
            }
            
            if let previewHistory = previewHistory, !context.coordinator.hasCenteredOnPreview {
                centerOnPreview(
                    coordinate: previewHistory.centerCoords,
                    uiView: uiView,
                    context: context
                )
            }
        default:
            break
        }
    }
    
    private func isValidRegion(_ region: MKCoordinateRegion) -> Bool {
        guard CLLocationCoordinate2DIsValid(region.center) else {
            return false
        }
        
        let maxLatitudeDelta: CLLocationDegrees = 90.0
        let maxLongitudeDelta: CLLocationDegrees = 360.0
        let minDelta: CLLocationDegrees = 0.001
        
        return region.span.latitudeDelta >= minDelta &&
        region.span.latitudeDelta <= maxLatitudeDelta &&
        region.span.longitudeDelta >= minDelta &&
        region.span.longitudeDelta <= maxLongitudeDelta
    }
    
    private func setSafeDefaultRegion(_ mapView: MKMapView, context: Context) {
        let safeRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.715, longitude: -74.001),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
        
        mapView.setRegion(safeRegion, animated: false)
        context.coordinator.lastRegion = safeRegion
        context.coordinator.shouldAnimate = true
    }
    
    private func centerOnPreview(
        coordinate: CLLocationCoordinate2D,
        uiView: MKMapView,
        context: Context,
        spanDelta: Double = 0.01
    ) {
        guard CLLocationCoordinate2DIsValid(coordinate) else { return }
        
        let baseRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        )
        
        let offsetInMeters = UIScreen.main.bounds.height * 0.15 * metersPerPixel(at: baseRegion, mapView: uiView)
        let offsetLatitude = offsetInMeters / 111111.0
        
        let offsetCenter = CLLocationCoordinate2D(
            latitude: coordinate.latitude - offsetLatitude,
            longitude: coordinate.longitude
        )
        
        let offsetRegion = MKCoordinateRegion(
            center: offsetCenter,
            span: baseRegion.span
        )
        
        if uiView.region.center.separation(from: coordinate) > 20 {
            uiView.setRegion(offsetRegion, animated: true)
            context.coordinator.shouldAnimate = true
            context.coordinator.lastRegion = region
            context.coordinator.hasCenteredOnPreview = true
        }
    }
    
    private func metersPerPixel(at region: MKCoordinateRegion, mapView: MKMapView) -> Double {
        let mapBounds = mapView.bounds
        let mapCenter = region.center
        let mapCenterPoint = mapView.convert(mapCenter, toPointTo: mapView)
        
        let offsetPoint = CGPoint(x: mapCenterPoint.x + 100, y: mapCenterPoint.y)
        let offsetCoordinate = mapView.convert(offsetPoint, toCoordinateFrom: mapView)
        
        let location1 = CLLocation(latitude: mapCenter.latitude, longitude: mapCenter.longitude)
        let location2 = CLLocation(latitude: offsetCoordinate.latitude, longitude: offsetCoordinate.longitude)
        let distanceInMeters = location1.distance(from: location2)
        
        return distanceInMeters / 100.0
    }
    
    private func centeringMap(
        coordinate: CLLocationCoordinate2D,
        uiView: MKMapView
    ) {
        let region = MKCoordinateRegion(
            center: coordinate,
            span: region.span
        )
        uiView.setRegion(region, animated: true)
    }
    
    private func updateAnnotationsIfNeeded(on mapView: MKMapView, context: Context) {
        removeIrrelevantAnnotations(from: mapView, for: mode)
        
        switch mode {
        case .members:
            updatePersonAnnotations(on: mapView, context: context)
        case .zones:
            if shouldUpdateZones(context: context) {
                updateZoneAnnotations(on: mapView, context: context)
            }
        case .history:
            updateHistoryRoute(on: mapView, context: context)
            updateHistoryAnnotations(on: mapView, context: context)
        }
    }
    
    private func shouldUpdateZones(context: Context) -> Bool {
        defer {
            context.coordinator.lastZones = zones
            context.coordinator.lastPreviewZone = previewZone
        }
        
        let lastZones = context.coordinator.lastZones
        let newZones = zones
        let lastPreview = context.coordinator.lastPreviewZone
        let newPreview = previewZone
        
        return lastZones != newZones || lastPreview != newPreview
    }
    
    private func removeIrrelevantAnnotations(from mapView: MKMapView, for currentMode: MapMode) {
        let annotationsToRemove: [MKAnnotation]
        
        switch currentMode {
        case .members:
            annotationsToRemove = mapView.annotations.filter {
                !($0 is PersonAnnotation) && !isCurrentUserAnnotation($0)
            }
        case .zones:
            annotationsToRemove = mapView.annotations.filter {
                !($0 is ZoneAnnotation)
            }
        case .history:
            annotationsToRemove = mapView.annotations.filter {
                !($0 is PersonAnnotation) && !($0 is HistoryPointAnnotation)
            }
        }
        
        if !annotationsToRemove.isEmpty {
            mapView.removeAnnotations(annotationsToRemove)
        }
        
        mapView.removeAnnotations(annotationsToRemove)
        
        let overlaysToRemove: [MKOverlay]
        switch currentMode {
        case .zones:
            overlaysToRemove = mapView.overlays.filter {
                !($0 is MKCircle)
            }
        case .history:
            overlaysToRemove = mapView.overlays.filter {
                !($0 is MKPolyline)
            }
        default:
            overlaysToRemove = mapView.overlays
        }
        
        mapView.removeOverlays(overlaysToRemove)
    }
    
    private func isCurrentUserAnnotation(_ annotation: MKAnnotation) -> Bool {
        guard let personAnnotation = annotation as? PersonAnnotation else { return false }
        return personAnnotation.personID == currentUserID
    }
    
    private func updateHistoryRoute(on mapView: MKMapView, context: Context) {
        let currentCoordinates = getCoordinatesFromHistory()
        
        guard !currentCoordinates.isEmpty else {
            removeHistoryPointsAndRoutes(from: mapView)
            context.coordinator.lastHistoryCoordinates = []
            return
        }
        
        updateHistoryPoints(currentCoordinates, on: mapView)
        
        if previewHistory != nil && currentCoordinates != context.coordinator.lastHistoryCoordinates {
            context.coordinator.isBuildingRoutes = true
            context.coordinator.lastHistoryCoordinates = currentCoordinates
            
            calculateRoutes(for: currentCoordinates, mapView: mapView) {
                context.coordinator.isBuildingRoutes = false
            }
        }
    }

    private func removeHistoryPointsAndRoutes(from mapView: MKMapView) {
        let historyPoints = mapView.annotations.compactMap { $0 as? HistoryPointAnnotation }
        mapView.removeAnnotations(historyPoints)
        
        let historyRoutes = mapView.overlays.filter { $0 is MKPolyline }
        mapView.removeOverlays(historyRoutes)
    }

    private func updateHistoryPoints(_ coordinates: [CLLocationCoordinate2D], on mapView: MKMapView) {
        let existingAnnotations = mapView.annotations.compactMap { $0 as? HistoryPointAnnotation }
        
        let toRemove = existingAnnotations.filter { annotation in
            !coordinates.contains(where: { $0.latitude == annotation.coordinate.latitude &&
                                         $0.longitude == annotation.coordinate.longitude })
        }
        mapView.removeAnnotations(toRemove)
        
        for coordinate in coordinates {
            if !existingAnnotations.contains(where: { $0.coordinate.latitude == coordinate.latitude &&
                                                   $0.coordinate.longitude == coordinate.longitude }) {
                let annotation = HistoryPointAnnotation()
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
            }
        }
    }

    private func isZoneOverlay(_ overlay: MKOverlay, zones: [ZoneInfo]) -> Bool {
        guard let circle = overlay as? MKCircle else { return false }
        return zones.contains { zone in
            circle.coordinate.latitude == zone.boundaryCoordinates[1] &&
            circle.coordinate.longitude == zone.boundaryCoordinates[0] &&
            circle.radius == Double(zone.radius)
        }
    }

    private func getCoordinatesFromHistory() -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        
        for position in peopleHistory {
            guard position.coordinatesList.count >= 2,
                  position.coordinatesList.count % 2 == 0 else { continue }
            
            for i in stride(from: 0, to: position.coordinatesList.count, by: 2) {
                let lat = position.coordinatesList[i+1]
                let lon = position.coordinatesList[i]
                coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
            }
        }
        
        return coordinates
    }

    private func calculateRoutes(for coordinates: [CLLocationCoordinate2D],
                               mapView: MKMapView,
                               completion: @escaping () -> Void) {
        guard coordinates.count > 1 else {
            completion()
            return
        }
        
        let oldRoutes = mapView.overlays.filter { $0 is MKPolyline }
        mapView.removeOverlays(oldRoutes)
        
        var polylines: [MKPolyline] = []
        let group = DispatchGroup()
        
        let step = max(1, coordinates.count / 10)
        
        for i in stride(from: 0, to: coordinates.count-1, by: step) {
            let endIndex = min(i+step, coordinates.count-1)
            group.enter()
            
            let source = MKMapItem(placemark: MKPlacemark(coordinate: coordinates[i]))
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates[endIndex]))
            
            let request = MKDirections.Request()
            request.source = source
            request.destination = destination
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            directions.calculate { response, _ in
                defer { group.leave() }
                
                if let route = response?.routes.first {
                    polylines.append(route.polyline)
                } else {
                    let polyline = MKPolyline(coordinates: [coordinates[i], coordinates[endIndex]], count: 2)
                    polylines.append(polyline)
                }
            }
        }
        
        group.notify(queue: .main) {
            mapView.addOverlays(polylines)
            completion()
        }
    }
    
    private func updatePersonAnnotations(on mapView: MKMapView, context: Context) {
        let currentPeopleIds = Set(people.map(\.id))
        
        let toRemove = mapView.annotations.compactMap { $0 as? PersonAnnotation }
            .filter { annotation in
                annotation.personID != currentUserID && !currentPeopleIds.contains(annotation.personID)
            }
        
        if !toRemove.isEmpty {
            mapView.removeAnnotations(toRemove)
        }
        
        var peopleToAdd: [MemberInfo] = people
        
        if let currentUser = currentUser {
            peopleToAdd.append(currentUser)
        }
        
        for person in peopleToAdd {
            if let existingAnnotation = mapView.annotations.compactMap({ $0 as? PersonAnnotation })
                .first(where: { $0.personID == person.id }) {
                
                existingAnnotation.isCurrentUser = (person.id == currentUserID)
                existingAnnotation.update(with: person)
                
                if let view = mapView.view(for: existingAnnotation) as? PersonAnnotationView {
                    view.configure(with: existingAnnotation)
                }
                
            } else {
                let isCurrentUser = (person.id == currentUserID)
                let annotation = PersonAnnotation(person: person, isCurrentUser: isCurrentUser)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    private func updateZoneAnnotations(on mapView: MKMapView, context: Context) {
        let realZones = zones.filter { $0.id != previewZone?.id }
        let currentZoneIds = Set(realZones.map(\.id))
        
        let annotationsToRemove = mapView.annotations.compactMap { $0 as? ZoneAnnotation }
            .filter { annotation in
                annotation.zone.id != previewZone?.id && !currentZoneIds.contains(annotation.zone.id)
            }
        
        if !annotationsToRemove.isEmpty {
            mapView.removeAnnotations(annotationsToRemove)
        }
        
        let overlaysToRemove = mapView.overlays.compactMap { $0 as? MKCircle }
            .filter { circle in
                let isExistingZoneCircle = realZones.contains { zone in
                    circle.coordinate.latitude == zone.boundaryCoordinates[1] &&
                    circle.coordinate.longitude == zone.boundaryCoordinates[0]
                }
                
                let isPreviewCircle = previewZone != nil &&
                    circle.coordinate.latitude == previewZone!.boundaryCoordinates[1] &&
                    circle.coordinate.longitude == previewZone!.boundaryCoordinates[0]
                
                return !isExistingZoneCircle && !isPreviewCircle
            }
        
        if !overlaysToRemove.isEmpty {
            mapView.removeOverlays(overlaysToRemove)
        }
        
        for zone in realZones {
            if let existingAnnotation = mapView.annotations.compactMap({ $0 as? ZoneAnnotation })
                .first(where: { $0.zone.id == zone.id }) {
                
                existingAnnotation.zone = zone
                existingAnnotation.coordinate = CLLocationCoordinate2D(
                    latitude: zone.boundaryCoordinates[1],
                    longitude: zone.boundaryCoordinates[0]
                )
                existingAnnotation.title = zone.zoneName
                
                if let view = mapView.view(for: existingAnnotation) as? ZoneAnnotationView {
                    view.configure(with: zone)
                }
                
            } else {
                let annotation = ZoneAnnotation(zone: zone)
                mapView.addAnnotation(annotation)
            }
            
            updateCircle(for: zone, on: mapView, isPreview: false)
        }
        
        removePreviewZoneAnnotationsAndOverlays(from: mapView)
    }
    
    private func updateHistoryAnnotations(on mapView: MKMapView, context: Context) {
        if let previewHistory = previewHistory {
            let annotationsToRemove = mapView.annotations.compactMap { $0 as? PersonAnnotation }
                .filter { $0.personID != previewHistory.id }
            mapView.removeAnnotations(annotationsToRemove)
            
            let existingAnnotation = mapView.annotations.first {
                ($0 as? PersonAnnotation)?.personID == previewHistory.id
            } as? PersonAnnotation
            
            if existingAnnotation == nil {
                let isCurrentUser = (previewHistory.id == currentUserID)
                let annotation = PersonAnnotation(person: previewHistory, isCurrentUser: isCurrentUser)
                mapView.addAnnotation(annotation)
            } else {
                existingAnnotation?.isCurrentUser = (previewHistory.id == currentUserID)
                existingAnnotation?.title = previewHistory.displayName
                existingAnnotation?.avatarURL = previewHistory.avatar?.url
                if let view = mapView.view(for: existingAnnotation!) as? PersonAnnotationView {
                    view.configure(with: existingAnnotation!)
                }
            }
        } else {
            updatePersonAnnotations(on: mapView, context: context)
            
            removeHistoryPointsAndRoutes(from: mapView)
        }
        
        context.coordinator.updateSelectedHistoryPoint(uiView: mapView)
    }

    private func removePreviewZoneAnnotationsAndOverlays(from mapView: MKMapView) {
        guard let previewZone = previewZone else { return }
        
        let previewAnnotations = mapView.annotations.compactMap { $0 as? ZoneAnnotation }
            .filter { $0.zone.id == previewZone.id }
        
        if !previewAnnotations.isEmpty {
            mapView.removeAnnotations(previewAnnotations)
        }
        
        let previewCircles = mapView.overlays.compactMap { $0 as? MKCircle }
            .filter { circle in
                circle.coordinate.latitude == previewZone.boundaryCoordinates[1] &&
                circle.coordinate.longitude == previewZone.boundaryCoordinates[0]
            }
        
        if !previewCircles.isEmpty {
            mapView.removeOverlays(previewCircles)
        }
    }
    
    private func updateCircle(for zone: ZoneInfo, on mapView: MKMapView, isPreview: Bool = false) {
        let existingCircles = mapView.overlays.compactMap { $0 as? MKCircle }
            .filter { circle in
                circle.coordinate.latitude == zone.boundaryCoordinates[1] &&
                circle.coordinate.longitude == zone.boundaryCoordinates[0]
            }
        
        if !existingCircles.isEmpty {
            mapView.removeOverlays(existingCircles)
        }
        
        addCircle(for: zone, to: mapView, isPreview: isPreview)
    }


    private func addCircle(for zone: ZoneInfo, to mapView: MKMapView, isPreview: Bool = false) {
        let circle = ZoneCircle.create(for: zone, isPreview: isPreview)
        mapView.addOverlay(circle)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: UnifiedMapView
        var lastRegion: MKCoordinateRegion?
        var lastMapType: MKMapType?
        var lastPreviewHistoryId: Int?
        var lastHistoryCoordinates: [CLLocationCoordinate2D] = []
        var lastMode: MapMode?
        var lastZones: [ZoneInfo] = []
        var lastPreviewZone: ZoneInfo?
        var isBuildingRoutes = false
        var shouldAnimate = false
        var hasCenteredOnPreview = false
        let imageCache = NSCache<NSString, UIImage>()
        var shouldPreserveRoutes = false
        var selectedHistoryPosition: LocationData?

        init(_ parent: UnifiedMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            else if let personAnnotation = annotation as? PersonAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: PersonAnnotationView.reuseIdentifier,
                    for: personAnnotation
                ) as! PersonAnnotationView
                view.configure(with: personAnnotation)
                return view
            }
            else if let zoneAnnotation = annotation as? ZoneAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: ZoneAnnotationView.reuseIdentifier,
                    for: zoneAnnotation
                ) as! ZoneAnnotationView
                view.configure(with: zoneAnnotation.zone)
                return view
            }
            else if let pointAnnotation = annotation as? HistoryPointAnnotation {
                var view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: HistoryPointAnnotationView.reuseIdentifier) as? HistoryPointAnnotationView
                if view == nil {
                    view = HistoryPointAnnotationView(
                        annotation: pointAnnotation,
                        reuseIdentifier: HistoryPointAnnotationView.reuseIdentifier
                    )
                }
                
                if let position = selectedHistoryPosition,
                   position.coordinatesList.count >= 2 {
                    let selectedCoord = CLLocationCoordinate2D(
                        latitude: position.coordinatesList[1],
                        longitude: position.coordinatesList[0]
                    )
                    
                    if pointAnnotation.coordinate.latitude == selectedCoord.latitude &&
                        pointAnnotation.coordinate.longitude == selectedCoord.longitude {
                        view?.setSelected(true)
                    } else {
                        view?.setSelected(false)
                    }
                } else {
                    view?.setSelected(false)
                }
                
                return view
            }
            
            return nil
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor(AppColors.accentBlue)
                renderer.lineWidth = 10
                renderer.lineCap = .round
                renderer.lineJoin = .round
                return renderer
            }
            
            guard let circle = overlay as? MKCircle else {
                return MKOverlayRenderer(overlay: overlay)
            }
            
            if let zoneCircle = circle as? ZoneCircle, zoneCircle.isPreview {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.fillColor = UIColor.white.withAlphaComponent(0.35)
                renderer.strokeColor = UIColor.white.withAlphaComponent(0.7)
                renderer.lineWidth = 1.0
                renderer.alpha = 0.4
                return renderer
            } else {
                return GradientCircleRenderer(circle: circle)
            }
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            shouldAnimate = true
            shouldPreserveRoutes = false
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            switch parent.mode {
            case .members:
                guard let personAnnotation = view.annotation as? PersonAnnotation else { return }
                let personCoord = personAnnotation.person.centerCoords
                parent.centeringMap(coordinate: personCoord, uiView: mapView)
            case .zones:
                guard let zoneAnnotation = view.annotation as? ZoneAnnotation else { return }
                let zoneCoord = zoneAnnotation.zone.centerCoords
                parent.centeringMap(coordinate: zoneCoord, uiView: mapView)
            case .history:
                guard let historyAnnotation = view.annotation as? PersonAnnotation else { return }
                let personCoord = historyAnnotation.person.centerCoords
                parent.centeringMap(coordinate: personCoord, uiView: mapView)
                hasCenteredOnPreview = false
            }
        }
        
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            shouldPreserveRoutes = true
            
            let newRegion = mapView.region
            if newRegion.span.latitudeDelta < parent.minSpanDelta || newRegion.span.longitudeDelta < parent.minSpanDelta {
                
                let limitedRegion = MKCoordinateRegion(
                    center: newRegion.center,
                    span: MKCoordinateSpan(
                        latitudeDelta: max(parent.minSpanDelta, newRegion.span.latitudeDelta),
                        longitudeDelta: max(parent.minSpanDelta, newRegion.span.longitudeDelta)
                    )
                )
                
                DispatchQueue.main.async {
                    mapView.setRegion(limitedRegion, animated: true)
                }
            }
        }
        
        func updateSelectedHistoryPoint(uiView: MKMapView) {
            var selectedCoordinate: CLLocationCoordinate2D?
            
            if let position = selectedHistoryPosition,
               position.coordinatesList.count >= 2 {
                selectedCoordinate = CLLocationCoordinate2D(
                    latitude: position.coordinatesList[1],
                    longitude: position.coordinatesList[0]
                )
            }
            
            for annotation in uiView.annotations where annotation is HistoryPointAnnotation {
                if let view = uiView.view(for: annotation) as? HistoryPointAnnotationView {
                    if let selectedCoord = selectedCoordinate,
                       annotation.coordinate.latitude == selectedCoord.latitude &&
                        annotation.coordinate.longitude == selectedCoord.longitude {
                        view.setSelected(true)
                    } else {
                        view.setSelected(false)
                    }
                }
            }
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            DispatchQueue.main.async {
                self.parent.region = mapView.region
            }
            lastRegion = mapView.region
        }
        
        func handlePreviewHistoryChange(_ newPreview: MemberInfo?) {
            let newId = newPreview?.id
            if newId != lastPreviewHistoryId {
                hasCenteredOnPreview = false
                lastPreviewHistoryId = newId
            }
        }
        
        class GradientCircleRenderer: MKCircleRenderer {
            override init(circle: MKCircle) {
                super.init(circle: circle)
                self.alpha = 0.4
            }
            
            override func fillPath(_ path: CGPath, in context: CGContext) {
                let boundingBox = path.boundingBox
                let center = CGPoint(x: boundingBox.midX, y: boundingBox.midY)
                let radius = max(boundingBox.width, boundingBox.height) / 2.0
                
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let locations: [CGFloat] = [0.0, 0.5, 1.0]
                let colors = [
                    UIColor.white.withAlphaComponent(0.0).cgColor,
                    UIColor.white.withAlphaComponent(0.0).cgColor,
                    UIColor.white.withAlphaComponent(0.7).cgColor
                ]
                
                guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations) else {
                    super.fillPath(path, in: context)
                    return
                }
                
                context.saveGState()
                context.addPath(path)
                context.clip()
                
                context.drawRadialGradient(
                    gradient,
                    startCenter: center,
                    startRadius: 0,
                    endCenter: center,
                    endRadius: radius,
                    options: .drawsAfterEndLocation
                )
                
                context.restoreGState()
            }
        }
    }
}
