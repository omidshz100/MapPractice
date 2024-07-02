//
//  LocationView.swift
//  MapPractice
//
//  Created by Omid Shojaeian Zanjani on 02/07/24.
//

import SwiftUI
import MapKit

struct LocationDetailsView: View {
    @Binding var mapSelection: MKMapItem?
    @Binding var show:Bool
    @State private var lookAroundScene: MKLookAroundScene?
    @Binding var getDirections:Bool
    
    var body: some View {
        VStack{
            HStack{
                VStack(alignment: .leading){
                    Text(mapSelection?.name ?? "Place Name")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(mapSelection?.placemark.title ?? "some description for the place")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                        .padding(.trailing)
                }
                Spacer()
                Button {
                    show.toggle()
                    mapSelection = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.gray, Color(.systemGray6))
                }
            }
            
            if let scene = lookAroundScene {
                LookAroundPreview(initialScene: scene)
                    .frame(height: 200)
                    .clipShape( RoundedRectangle(cornerRadius: 12))
                    .padding()
            }else {
                ContentUnavailableView("No preview avalable", systemImage: "eye.slash")
            }
            
            HStack(spacing:24){
                Button("Open in Maps") {
                    if let mapSelection{
                        mapSelection.openInMaps()
                    }
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 170, height: 48)
                .background(.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Button("Get Direction") {
                    getDirections = true
                    show = false
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 170, height: 48)
                .background(.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                

            }
        }
        .onAppear{
            fetchlookAroundPreview()
        }
        .onChange(of: mapSelection) { oldValue, newValue in
            fetchlookAroundPreview()
        }
        .padding()
    }
}
extension LocationDetailsView {
    func fetchlookAroundPreview() {
        if let mapSelection {
            lookAroundScene = nil
            
            Task{
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
}
#Preview {
    LocationDetailsView(mapSelection: .constant(nil), show: .constant(false), getDirections: .constant(false))
}
