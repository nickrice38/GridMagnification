//
//  Home.swift
//  GridMagnification
//
//  Created by Nick Rice on 03/10/2022.
//

import SwiftUI

struct Home: View {
    @GestureState var location: CGPoint = .zero
    @State private var isReversed = false
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                let size = proxy.size
                let width = (size.width / 10)
                let itemCount = Int((size.height / width).rounded()) * 10
                
                LinearGradient(colors: [Color("lightBlue"), Color("darkBlue")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 10), spacing: 0) {
                            ForEach(0..<itemCount, id: \.self) { _ in
                                GeometryReader { innerProxy in
                                    let rect = innerProxy.frame(in: .named("GESTURE"))
                                    let scale = itemScale(rect: rect, size: size)
                                    
                                    let transformedRect = rect.applying(.init(scaleX: scale, y: scale))
                                    
                                    // MARK: Transforming Location
                                    let transformedLocation = location.applying(.init(scaleX: scale, y: scale))
                                    
                                    if isReversed {
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(.orange)
                                        
                                        // MARK: For First Effect
                                        // We need to relocate every item to current drag position
                                            .offset(x: (transformedRect.midX - rect.midX), y: (transformedRect.midY - rect.midY))
                                            .offset(x: location.x - transformedLocation.x, y: location.y - transformedLocation.y)
                                            .scaleEffect(scale)
                                        
                                    } else {
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(.orange)
                                            .scaleEffect(scale)
                                        
                                            .offset(x: (transformedRect.midX - rect.midX), y: (transformedRect.midY - rect.midY))
                                            .offset(x: location.x - transformedLocation.x, y: location.y - transformedLocation.y)
                                    }
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
            .animation(.easeInOut, value: location == .zero)
            
            Toggle("Reverse Effect", isOn: $isReversed)
                .fontWeight(.semibold)
                .toggleStyle(SwitchToggleStyle(tint: Color("darkBlue")))
                .padding(.horizontal, 20)
        }
    }
    
    func itemScale(rect: CGRect, size: CGSize) -> CGFloat {
        let a = location.x - rect.midX
        let b = location.y - rect.midY
        
        let root = sqrt((a * a) + (b * b))
        let diagonalValue = sqrt((size.width * size.width) + (size.height * size.height))
        
        let scale = root / (diagonalValue / 2)
        let modifiedScale = location == .zero ? 1 : (1 - scale)
        return modifiedScale > 0 ? modifiedScale : 0.001
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
