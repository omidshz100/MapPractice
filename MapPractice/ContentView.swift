//
//  ContentView.swift
//  MapPractice
//
//  Created by Omid Shojaeian Zanjani on 02/07/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText:String = ""
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var route:MKRoute?
    @State private var routeDestination:MKMapItem?
    
    
    var body: some View {
        Map(position: $cameraPosition, selection: $mapSelection){
//            Marker("My Location",systemImage: "paperplane" ,coordinate: .userLocation)
//                .tint(.blue)
             //To add fully custom Marker we can use Annotation
            Annotation("My Location", coordinate: .userLocation) {
                CustomAnnotationView(title: "My Location")
            }
            
            ForEach(results, id: \.self){ item in
                
                if routeDisplaying {
                    if item == routeDestination {
                        let placeMark = item.placemark
                        Marker(placeMark.name ?? "", coordinate: placeMark.coordinate)
                    }
                }else{
                    let placeMark = item.placemark
                    Marker(placeMark.name ?? "", coordinate: placeMark.coordinate)
                }
            }
            
            if let route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 6)
            }
        }
        .mapControls {
            MapCompass()
            // bring 3dView of building to the map
            MapPitchToggle()
            MapUserLocationButton()
        }
        .overlay(alignment: .top) {
            TextField("write the location name you want", text: $searchText)
                .font(.subheadline)
                .padding(12)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding()
                .shadow(radius: 10)
        }
        .onSubmit(of: .text) {
            Task{ await searchPlaces() }
        }
        .onChange(of: getDirections, { oldValue, newValue in
            if newValue {
                fetchRoute()
            }
        })
        .onChange(of: mapSelection, { oldValue, newValue in
            showDetails = newValue != nil
        })
        .sheet(isPresented: $showDetails) {
            LocationDetailsView(mapSelection: $mapSelection, show: $showDetails, getDirections: $getDirections)
                .presentationDetents([.height(340)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
        }
    }
}



////
///A map Annotation custom View
struct CustomAnnotationView: View {
    var title: String
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.5))
                .frame(width: 50, height: 50)
            Circle()
                .fill(Color.yellow.opacity(0.5))
                .frame(width: 30, height: 30)
            Circle()
                .fill(Color.red.opacity(0.5))
                .frame(width: 10, height: 10)
        }
        .overlay(
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
                .padding(5)
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .offset(y: -30)
                .fixedSize(),
            alignment: .top
        )
    }
}

#Preview {
    ContentView()
}

extension ContentView{
    func searchPlaces() async{
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion
         
        let result = try? await MKLocalSearch(request: request).start()
        self.results = result?.mapItems ?? []
    }
    
    
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request ()
            request.source = MKMapItem(placemark: .init(coordinate: .userLocation))
            request.destination = mapSelection
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                routeDestination = mapSelection
                withAnimation (.snappy) {
                    routeDisplaying = true
                    showDetails = false
                    if let rect = route?.polyline.boundingMapRect, routeDisplaying {
                        cameraPosition = .rect(rect)
                    }
                }
            }
        }
    }
}


