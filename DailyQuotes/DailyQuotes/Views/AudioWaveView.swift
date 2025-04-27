import SwiftUI

struct AudioWaveView: View {
    @Binding var audioLevel: CGFloat
    let barCount: Int
    let spacing: CGFloat
    let cornerRadius: CGFloat
    let minBarHeight: CGFloat
    var color: Color
    
    // Геренирует случайные начальные высоты для баров
    private var initialHeights: [CGFloat] {
        (0..<barCount).map { _ in CGFloat.random(in: 0.1...0.6) }
    }
    
    init(
        audioLevel: Binding<CGFloat>,
        barCount: Int = 8,
        spacing: CGFloat = 5,
        cornerRadius: CGFloat = 4,
        minBarHeight: CGFloat = 0.1,
        color: Color = .blue
    ) {
        self._audioLevel = audioLevel
        self.barCount = barCount
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.minBarHeight = minBarHeight
        self.color = color
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: spacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    AudioBar(
                        index: index,
                        barCount: barCount,
                        audioLevel: audioLevel,
                        barWidth: (geometry.size.width - (spacing * CGFloat(barCount - 1))) / CGFloat(barCount),
                        maxHeight: geometry.size.height,
                        minBarHeight: minBarHeight,
                        cornerRadius: cornerRadius,
                        color: color
                    )
                    .animation(
                        Animation.easeInOut(duration: 0.2)
                            .delay(Double(index) * 0.05),
                        value: audioLevel
                    )
                }
            }
        }
    }
}

struct AudioBar: View {
    let index: Int
    let barCount: Int
    let audioLevel: CGFloat
    let barWidth: CGFloat
    let maxHeight: CGFloat
    let minBarHeight: CGFloat
    let cornerRadius: CGFloat
    let color: Color
    
    private var heightPercentage: CGFloat {
        if audioLevel == 0 {
            return minBarHeight
        }
        
        // Создаем эффект волны между соседними барами
        let midPoint = CGFloat(barCount) / 2.0
        let distanceFromMid = abs(CGFloat(index) - midPoint)
        let variance = max(0, 1.0 - distanceFromMid / midPoint)
        
        // Добавляем случайность для реалистичного отображения звуковой волны
        let randomness = CGFloat.random(in: -0.1...0.1)
        
        return max(
            minBarHeight,
            audioLevel * variance + randomness
        )
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(color)
            .frame(width: barWidth, height: maxHeight * heightPercentage)
            .frame(height: maxHeight, alignment: .center)
    }
}

// Предварительный просмотр
struct AudioWaveView_Previews: PreviewProvider {
    @State static var audioLevel: CGFloat = 0.7
    
    static var previews: some View {
        VStack {
            AudioWaveView(audioLevel: $audioLevel, color: .blue)
                .frame(height: 50)
                .padding()
                .background(Color.black.opacity(0.1))
                .cornerRadius(10)
            
            Slider(value: $audioLevel, in: 0...1)
                .padding()
        }
        .padding()
    }
} 