//
//  EditLocationView.swift
//  Xpense
//
//  Created by Paul Schmiedmayer on 3/20/20.
//  Copyright © 2020 TUM LS1. All rights reserved.
//

import SwiftUI
import MapKit
import XpenseModel


// MARK: - EditLocationView
/// A view that enables a user to select a location on a map view
struct EditLocationView: View {
    /// The presentation mode used to dismiss the view once the user cancels the view or saves the selection
    @Environment(\.presentationMode) var presentationMode
    
    /// The coordinate that is selected by the user
    @Binding var coordinate: CLLocationCoordinate2D?
    
    /// The current coordinate region displayed by the map
    @State var coordinateRegion: MKCoordinateRegion = MKMapView().region

    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $coordinateRegion, showsUserLocation: true)
                ZStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.white)
                    Image(systemName: "arrowtriangle.down.fill")
                        .scaleEffect(0.25)
                        .offset(x: 0, y: 17.0)
                        .shadow(color: .black, radius: 4)
                    Image(systemName: "mappin.circle.fill")
                }
                    .alignmentGuide(VerticalAlignment.center) { dimension in
                        dimension[.bottom]
                    }
                    .font(.largeTitle)
                    .foregroundColor(.red)
            }
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    if let coordinate = coordinate {
                        coordinateRegion.center = coordinate
                        coordinateRegion.span = LocationView.Defaults.span
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            coordinate = coordinateRegion.center
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
    }
}


// MARK: - EditLocationView Previews
struct EditLocationView_Previews: PreviewProvider {
    @State private static var coordinate: CLLocationCoordinate2D?
    
    static var previews: some View {
        EditLocationView(coordinate: $coordinate)
    }
}
