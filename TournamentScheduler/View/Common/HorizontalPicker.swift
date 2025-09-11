import SwiftUI

struct HorizontalPicker: View {
    let values: [(index: Int, text: String)]
    @Binding var selectedValue: Int
    @State private var horizontalPadding: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.clear
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                horizontalPadding = proxy.size.width / 3
                            }
                            .onChange(of: proxy.size.width) { _, newValue in
                                horizontalPadding = newValue / 3
                            }
                    }
                )
            
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(values, id: \.index) { i in
                        Text(i.text)
                            .foregroundStyle(.primary)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                            .scrollTransition { content, p in
                                content
                                    .opacity(p.isIdentity ? 1 : 0.3)
                                    .scaleEffect(p.isIdentity ? 1 : 0.5)
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: .init(get: {
                let position: Int? = selectedValue
                return position
            }, set: { newValue in
                if let newValue {
                    withAnimation {
                        selectedValue = newValue
                    }
                }
            }))
            .safeAreaPadding(.horizontal, horizontalPadding)
        }
    }
}

#Preview {
    struct PreviewableView: View {
        @State private var selectedValue: Int = 0
        var body: some View {
            HorizontalPicker(values: [(0, "One"), (1, "Two"), (2, "Three")], selectedValue: $selectedValue)
        }
    }
    return PreviewableView()
}
