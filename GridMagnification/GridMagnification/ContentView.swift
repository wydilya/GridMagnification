//
//  ContentView.swift
//  GridMagnification
//
//  Created by Ilya Zelkin on 15.08.2022.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @GestureState var location: CGPoint = .zero
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            let width = (size.width / 10)
            let itemCount = Int((size.height / width).rounded()) * 10
            
            LinearGradient(colors: [
                .red, .orange, .mint, .pink, .green
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .mask {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 10), spacing: 0) {
                    ForEach(0..<itemCount, id: \.self) { _ in
                        GeometryReader { innerProxy in
                            let rect = innerProxy.frame(in: .named("GESTURE"))
                            let scale = itemScale(rect: rect, size: size)
                            
                            let transformedRect = rect.applying(.init(scaleX: scale, y: scale))
                            
                            let transformedLocation = location.applying(.init(scaleX: scale, y: scale))
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.purple)
                                .scaleEffect(scale)
                                .offset(x: (transformedRect.midX - rect.midX), y: (transformedRect.midY - rect.midY))
                                .offset(x: location.x - transformedLocation.x, y: location.y - transformedLocation.y)
                                //.scaleEffect(scale)
                        }
                        .padding(5)
                        .frame(height: width)
                    }
                }
            }
        }
        .padding(15)
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($location, body: { value, out, _ in
                    out = value.location
                })
        )
        .coordinateSpace(name: "GESTURE")
        .preferredColorScheme(.dark)
        //.edgesIgnoringSafeArea(.all)
        .animation(.easeInOut, value: location == .zero)
    }
    
    func itemScale(rect: CGRect, size: CGSize) -> CGFloat {
        let a = location.x - rect.midX
        let b = location.y - rect.midY
        
        let root = sqrt((a * a) + (b * b)) //.root
        let diagonalValue = sqrt((size.width * size.width) + (size.height * size.height))
        
        let scale = root / (diagonalValue / 2)
        //let scale = (root - 150) / 150
        let modifiedScale = location == .zero ? 1 : (1 - scale)
        
        return modifiedScale > 0 ? modifiedScale : 0.001
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
