//
//  DeliveryMapView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import SwiftUI
import MapKit

// MARK: - 配送地图视图


/// 配送路线地图展示组件
/// 显示餐厅到目的地的配送路径、司机实时位置标记
struct DeliveryMapView: View {
    let storeLocation: CLLocationCoordinate2D
    let customerLocation: CLLocationCoordinate2D
    let driverLocation: CLLocationCoordinate2D
    let status: DeliveryStatus
    let showCallout: Bool
    let calloutTitle: String
    let calloutDistance: String
    let calloutTime: String

    @State private var position: MapCameraPosition
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []
    @State private var traveledCoordinates: [CLLocationCoordinate2D] = []
    @State private var remainingCoordinates: [CLLocationCoordinate2D] = []

    init(
        storeLocation: CLLocationCoordinate2D,
        customerLocation: CLLocationCoordinate2D,
        driverLocation: CLLocationCoordinate2D,
        status: DeliveryStatus,
        showCallout: Bool,
        calloutTitle: String,
        calloutDistance: String,
        calloutTime: String
    ) {
        self.storeLocation = storeLocation
        self.customerLocation = customerLocation
        self.driverLocation = driverLocation
        self.status = status
        self.showCallout = showCallout
        self.calloutTitle = calloutTitle
        self.calloutDistance = calloutDistance
        self.calloutTime = calloutTime

        let centerLat = (storeLocation.latitude + customerLocation.latitude) / 2
        let centerLon = (storeLocation.longitude + customerLocation.longitude) / 2
        let latDelta = abs(storeLocation.latitude - customerLocation.latitude) * 1.8
        let lonDelta = abs(storeLocation.longitude - customerLocation.longitude) * 1.8
        _position = State(initialValue: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: max(latDelta, 0.03), longitudeDelta: max(lonDelta, 0.03))
        )))
    }

    var body: some View {
        Map(position: $position) {
            // Traveled route (solid blue)
            if !traveledCoordinates.isEmpty {
                MapPolyline(coordinates: traveledCoordinates)
                    .stroke(AppColors.theme, lineWidth: 3)
            }

            // Remaining route (dashed blue)
            if !remainingCoordinates.isEmpty {
                if status == .arrived {
                    MapPolyline(coordinates: remainingCoordinates)
                        .stroke(AppColors.theme, lineWidth: 3)
                } else {
                    MapPolyline(coordinates: remainingCoordinates)
                        .stroke(AppColors.theme, style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
                }
            }

            // Fallback straight lines if route not yet loaded
            if routeCoordinates.isEmpty {
                MapPolyline(coordinates: [storeLocation, driverLocation])
                    .stroke(AppColors.theme, lineWidth: 3)
                if status == .arrived {
                    MapPolyline(coordinates: [driverLocation, customerLocation])
                        .stroke(AppColors.theme, lineWidth: 3)
                } else {
                    MapPolyline(coordinates: [driverLocation, customerLocation])
                        .stroke(AppColors.theme, style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
                }
            }

            // Store marker
            Annotation("", coordinate: storeLocation) {
                storeMarker
            }

            // Customer marker
            Annotation("", coordinate: customerLocation) {
                customerMarker
            }

            // Driver marker + callout
            Annotation("", coordinate: driverLocation, anchor: .bottom) {
                driverMarker
            }
        }
        .mapStyle(.standard)
        .mapControls {}
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                .stroke(AppColors.line, lineWidth: 1)
        )
        .task {
            await calculateRoute()
        }
    }

    // MARK: - Route Calculation

    private func calculateRoute() async {
        let request = MKDirections.Request()
        if #available(iOS 26.0, *) {
            request.source = MKMapItem(
                location: CLLocation(latitude: storeLocation.latitude, longitude: storeLocation.longitude),
                address: nil
            )
            request.destination = MKMapItem(
                location: CLLocation(latitude: customerLocation.latitude, longitude: customerLocation.longitude),
                address: nil
            )
        } else {
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: storeLocation))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: customerLocation))
        }
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        guard let response = try? await directions.calculate(),
              let route = response.routes.first else {
            return
        }

        let polyline = route.polyline
        let pointCount = polyline.pointCount
        var coords: [CLLocationCoordinate2D] = Array(repeating: CLLocationCoordinate2D(), count: pointCount)
        polyline.getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))

        routeCoordinates = coords
        splitRouteAtDriver(coords)
    }

    private func splitRouteAtDriver(_ coords: [CLLocationCoordinate2D]) {
        guard !coords.isEmpty else { return }

        // Find the closest point on the route to the driver
        var closestIndex = 0
        var minDist = Double.greatestFiniteMagnitude

        for (index, coord) in coords.enumerated() {
            let dist = distanceBetween(coord, driverLocation)
            if dist < minDist {
                minDist = dist
                closestIndex = index
            }
        }

        // Split: traveled = start...closestIndex+driver, remaining = driver...end
        var traveled = Array(coords[0...closestIndex])
        traveled.append(driverLocation)

        var remaining = [driverLocation]
        if closestIndex < coords.count - 1 {
            remaining.append(contentsOf: coords[(closestIndex + 1)...])
        }

        traveledCoordinates = traveled
        remainingCoordinates = remaining
    }

    private func distanceBetween(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Double {
        let latDiff = a.latitude - b.latitude
        let lonDiff = a.longitude - b.longitude
        return latDiff * latDiff + lonDiff * lonDiff
    }

    // MARK: - Markers

    private var storeMarker: some View {
        Circle()
            .fill(AppColors.theme)
            .frame(width: 14, height: 14)
            .overlay(
                Circle()
                    .stroke(AppColors.white100, lineWidth: 2)
            )
    }

    private var customerMarker: some View {
        ZStack {
            Circle()
                .fill(AppColors.theme)
                .frame(width: 26, height: 26)
            Image(systemName: "person.fill")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.white100)
        }
    }

    private var driverMarker: some View {
        VStack(spacing: Spacing.xxs) {
            if showCallout {
                calloutBubble
            }
            Image(systemName: "truck.box.fill")
                .font(.system(size: 20))
                .foregroundStyle(AppColors.theme)
        }
    }

    private var calloutBubble: some View {
        VStack(spacing: 2) {
            Text(calloutTitle)
                .font(AppFont.tabletCaption1Regular)
                .foregroundStyle(AppColors.textPrimary)
            Text(calloutDistance)
                .font(AppFont.tabletCaption1Regular)
                .foregroundStyle(AppColors.textSecondary)
            Text(calloutTime)
                .font(AppFont.tabletCaption1Regular)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
        .shadow(color: AppColors.black20, radius: 4, x: 0, y: 2)
    }
}

