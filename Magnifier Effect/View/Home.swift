//
//  Home.swift
//  Magnifier Effect
//
//  Created by Szymon Wnuk on 27/07/2023.
//

import SwiftUI

struct Home: View {
    @State var scale: CGFloat = 0
    @State var rotation: CGFloat = 0
    @State var size: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0){
            GeometryReader{
                let size = $0.size
                Image("SS")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
                    .magnificationEffect(scale, rotation, self.size, tint: .gray)
            }
            .padding(50)
            .contentShape(Rectangle())
            
            VStack(alignment: .leading, spacing: 0){
                Text("Customizations")
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.5))
                    .padding(.bottom, 20)
                
                HStack(spacing: 14) {
                    Text("Scale")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(width: 35, alignment: .leading)
                    Slider(value: $scale)
                    
                    
                    Text("Rotation")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Slider(value: $rotation)
                }
                .tint(.black)
                
                HStack(spacing: 14) {
                    Text("Size")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(width: 35, alignment: .leading)
                    Slider(value: $size, in: -20...100)
                    
                }
                .tint(.black)
                .padding(.top)
                
            }
            .padding(15)
            .background {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(.white)
                    .ignoresSafeArea()
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(content: {
            Color.black
                .opacity(0.08)
                .ignoresSafeArea()
        })
        .preferredColorScheme(.light)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
extension View {
    @ViewBuilder
    func magnificationEffect(_ scale: CGFloat, _ rotation: CGFloat, _ size: CGFloat = 0, tint: Color = .white) -> some View {
        MagnificationEffectHelper(scale: scale, rotation: rotation, size: size, content:  {
            self
        }, tint: tint)
    }
}

fileprivate struct MagnificationEffectHelper<Content: View>: View {
    var scale: CGFloat
    var rotation: CGFloat
    var size: CGFloat
    var content: Content
    var tint: Color = .white
    
    init(scale: CGFloat, rotation: CGFloat, size: CGFloat, @ViewBuilder content: @escaping()-> Content, tint: Color = .white) {
        self.scale = scale
        self.rotation = rotation
        self.size = size
        self.content = content()
        self.tint = tint
    }
    @State var offset: CGSize = .zero
    @State var lastStoredOffset: CGSize = .zero
    
    
    var body: some View {
        content
            .reverseMask(content: {
                let newCircleSize = 150.0 + size
                Circle().frame(width: newCircleSize, height: newCircleSize)
                    .offset(offset)
            })
        
        
            .overlay{
                GeometryReader {
                    let newCircleSize = 150.0 + size
                    let size = $0.size
                    content
                        .offset(x: -offset.width, y: -offset.height)
                        .frame(width: size.width, height: size.height)
                        .frame(width: newCircleSize, height: newCircleSize)
                        .scaleEffect(1 + scale)
                        .clipShape(Circle())
                        .offset(offset)
                        .frame(width: size.width, height: size.height)
                    
                    Circle()
                        .fill(.clear)
                        .frame(width: newCircleSize, height: newCircleSize)
                        .overlay(alignment:.topLeading) {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .renderingMode(.template)
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(1.4, anchor: .topLeading)
                                .offset(x: -10, y: -5)
                                .foregroundColor(tint)
                        }
                        .rotationEffect(.init(degrees: rotation * 360.0))
                        .offset(offset)
                        .frame(width: size.width, height: size.height)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                .onChanged({
                    value in offset = CGSize(width: value.translation.width + lastStoredOffset.width, height: value.translation.height + lastStoredOffset.height)
                })
                .onEnded ({ _ in
                    lastStoredOffset = offset
                })
            )
    }
}
extension View{
    @ViewBuilder
    func reverseMask<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .mask {
                Rectangle().overlay {
                    content()
                        .blendMode(.destinationOut)
                }
            }
    }
}
