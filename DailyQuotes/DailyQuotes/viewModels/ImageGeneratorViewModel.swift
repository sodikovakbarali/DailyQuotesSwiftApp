import Foundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import UniformTypeIdentifiers

class ImageGeneratorViewModel: ObservableObject {
    @Published var generatedImage: UIImage?
    @Published var isGenerating = false
    @Published var selectedStyle: QuoteImageStyle = .modern
    @Published var showCustomization = false
    @Published var showShareSheet = false
    
    enum QuoteImageStyle: String, CaseIterable, Identifiable {
        case modern = "Modern"
        case vintage = "Vintage"
        case nature = "Nature"
        case minimal = "Minimal"
        case gradient = "Gradient"
        
        var id: String { self.rawValue }
        
        var backgroundName: String {
            switch self {
            case .modern: return "modern_bg"
            case .vintage: return "vintage_bg"
            case .nature: return "nature_bg"
            case .minimal: return "minimal_bg"
            case .gradient: return "gradient_bg"
            }
        }
        
        var fontName: String {
            switch self {
            case .modern: return "HelveticaNeue-Bold"
            case .vintage: return "Baskerville-Bold"
            case .nature: return "AvenirNext-Bold"
            case .minimal: return "Futura-Medium"
            case .gradient: return "GillSans-Bold"
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .modern: return .white
            case .vintage: return UIColor(red: 0.95, green: 0.95, blue: 0.9, alpha: 1.0)
            case .nature: return .white
            case .minimal: return .black
            case .gradient: return .white
            }
        }
        
        var authorFontName: String {
            switch self {
            case .modern: return "HelveticaNeue-Italic"
            case .vintage: return "Baskerville-Italic"
            case .nature: return "AvenirNext-Italic"
            case .minimal: return "Futura-MediumItalic"
            case .gradient: return "GillSans-Italic"
            }
        }
        
        var overlayOpacity: Double {
            switch self {
            case .modern: return 0.5
            case .vintage: return 0.6
            case .nature: return 0.4
            case .minimal: return 0.1
            case .gradient: return 0.3
            }
        }
    }
    
    // Генерирует изображение цитаты
    func generateQuoteImage(quote: Quote, theme: Theme) {
        isGenerating = true
        
        // Обработка в фоне для избежания лагов UI
        DispatchQueue.global(qos: .userInitiated).async {
            // Создаем изображение нужного размера
            let width: CGFloat = 1200
            let height: CGFloat = 1200
            let imageSize = CGSize(width: width, height: height)
            
            let renderer = UIGraphicsImageRenderer(size: imageSize)
            let generatedImage = renderer.image { (context) in
                // Заливка фоном
                self.drawBackground(for: self.selectedStyle, in: context, size: imageSize)
                
                // Добавляем текст цитаты
                self.drawQuoteText(quote: quote, context: context, size: imageSize)
                
                // Добавляем декоративные элементы
                self.drawDecorations(for: self.selectedStyle, in: context, size: imageSize)
                
                // Добавляем эффекты фильтра
                self.applyFilters(context: context)
            }
            
            // Переключаемся обратно на главный поток для обновления UI
            DispatchQueue.main.async {
                self.generatedImage = generatedImage
                self.isGenerating = false
            }
        }
    }
    
    private func drawBackground(for style: QuoteImageStyle, in context: UIGraphicsImageRendererContext, size: CGSize) {
        // Попытка загрузки предустановленного фона
        if let backgroundImage = UIImage(named: style.backgroundName) {
            backgroundImage.draw(in: CGRect(origin: .zero, size: size))
        } else {
            // Резервный вариант - градиентный фон
            let context = context.cgContext
            let colors: [CGColor]
            
            switch style {
            case .modern:
                colors = [UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1.0).cgColor,
                          UIColor(red: 0.2, green: 0.3, blue: 0.4, alpha: 1.0).cgColor]
            case .vintage:
                colors = [UIColor(red: 0.8, green: 0.7, blue: 0.6, alpha: 1.0).cgColor,
                          UIColor(red: 0.6, green: 0.5, blue: 0.4, alpha: 1.0).cgColor]
            case .nature:
                colors = [UIColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 1.0).cgColor,
                          UIColor(red: 0.1, green: 0.3, blue: 0.2, alpha: 1.0).cgColor]
            case .minimal:
                colors = [UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0).cgColor,
                          UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor]
            case .gradient:
                colors = [UIColor(red: 0.8, green: 0.3, blue: 0.5, alpha: 1.0).cgColor,
                          UIColor(red: 0.3, green: 0.2, blue: 0.5, alpha: 1.0).cgColor]
            }
            
            // Создание градиента
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 1.0])!
            
            // Рисуем градиент
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // Добавляем полупрозрачное наложение для контраста с текстом
            context.setFillColor(UIColor.black.withAlphaComponent(style.overlayOpacity).cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    private func drawQuoteText(quote: Quote, context: UIGraphicsImageRendererContext, size: CGSize) {
        let style = self.selectedStyle
        
        // Параметры текста
        let textColor = style.textColor
        let quoteFont = UIFont(name: style.fontName, size: 50) ?? UIFont.systemFont(ofSize: 50, weight: .bold)
        let authorFont = UIFont(name: style.authorFontName, size: 30) ?? UIFont.italicSystemFont(ofSize: 30)
        
        // Добавляем кавычки к тексту
        let displayText = "\"\(quote.text)\""
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 10
        
        // Атрибуты для текста цитаты
        let quoteAttributes: [NSAttributedString.Key: Any] = [
            .font: quoteFont,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        // Атрибуты для автора
        let authorAttributes: [NSAttributedString.Key: Any] = [
            .font: authorFont,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        // Рассчитываем размеры для центрирования текста
        let textRect = CGRect(x: 100, y: 0, width: size.width - 200, height: size.height)
        let textSize = (displayText as NSString).boundingRect(
            with: CGSize(width: textRect.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: quoteAttributes,
            context: nil
        )
        
        // Рисуем текст цитаты
        let quoteCenteredRect = CGRect(
            x: textRect.origin.x,
            y: (size.height - textSize.height - 80) / 2,
            width: textRect.width,
            height: textSize.height
        )
        (displayText as NSString).draw(in: quoteCenteredRect, withAttributes: quoteAttributes)
        
        // Рисуем имя автора
        let authorText = "- \(quote.author)"
        let authorTextSize = (authorText as NSString).boundingRect(
            with: CGSize(width: textRect.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: authorAttributes,
            context: nil
        )
        
        let authorCenteredRect = CGRect(
            x: textRect.origin.x,
            y: quoteCenteredRect.maxY + 40,
            width: textRect.width,
            height: authorTextSize.height
        )
        (authorText as NSString).draw(in: authorCenteredRect, withAttributes: authorAttributes)
    }
    
    private func drawDecorations(for style: QuoteImageStyle, in context: UIGraphicsImageRendererContext, size: CGSize) {
        let cgContext = context.cgContext
        
        switch style {
        case .modern:
            // Современные декоративные линии
            cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.5).cgColor)
            cgContext.setLineWidth(4)
            cgContext.move(to: CGPoint(x: 80, y: 80))
            cgContext.addLine(to: CGPoint(x: size.width - 80, y: 80))
            cgContext.strokePath()
            
            cgContext.move(to: CGPoint(x: 80, y: size.height - 80))
            cgContext.addLine(to: CGPoint(x: size.width - 80, y: size.height - 80))
            cgContext.strokePath()
            
        case .vintage:
            // Винтажная рамка
            let borderWidth: CGFloat = 40
            let borderRect = CGRect(x: borderWidth, y: borderWidth, width: size.width - borderWidth * 2, height: size.height - borderWidth * 2)
            cgContext.setStrokeColor(UIColor(red: 0.8, green: 0.7, blue: 0.6, alpha: 0.8).cgColor)
            cgContext.setLineWidth(3)
            cgContext.stroke(borderRect)
            
            // Дополнительная внутренняя рамка
            let innerBorderRect = CGRect(x: borderWidth + 15, y: borderWidth + 15, width: size.width - (borderWidth + 15) * 2, height: size.height - (borderWidth + 15) * 2)
            cgContext.setLineWidth(1)
            cgContext.stroke(innerBorderRect)
            
        case .nature:
            // Природные орнаменты - стилизованные листья в углах
            drawLeafInCorner(context: cgContext, center: CGPoint(x: 120, y: 120), size: 80, rotation: 0)
            drawLeafInCorner(context: cgContext, center: CGPoint(x: size.width - 120, y: 120), size: 80, rotation: .pi/2)
            drawLeafInCorner(context: cgContext, center: CGPoint(x: 120, y: size.height - 120), size: 80, rotation: -.pi/2)
            drawLeafInCorner(context: cgContext, center: CGPoint(x: size.width - 120, y: size.height - 120), size: 80, rotation: .pi)
            
        case .minimal:
            // Минималистичные декоративные элементы - тонкие линии
            cgContext.setStrokeColor(UIColor.black.withAlphaComponent(0.2).cgColor)
            cgContext.setLineWidth(1)
            
            // Горизонтальные линии сверху и снизу
            let margin: CGFloat = 150
            cgContext.move(to: CGPoint(x: margin, y: margin))
            cgContext.addLine(to: CGPoint(x: size.width - margin, y: margin))
            cgContext.strokePath()
            
            cgContext.move(to: CGPoint(x: margin, y: size.height - margin))
            cgContext.addLine(to: CGPoint(x: size.width - margin, y: size.height - margin))
            cgContext.strokePath()
            
        case .gradient:
            // Добавляем стилизованные кавычки
            let quoteSize: CGFloat = 120
            let quoteColor = UIColor.white.withAlphaComponent(0.3)
            
            // Левая кавычка
            drawQuoteMark(context: cgContext, position: CGPoint(x: 120, y: 250), size: quoteSize, color: quoteColor, isOpening: true)
            
            // Правая кавычка
            drawQuoteMark(context: cgContext, position: CGPoint(x: size.width - 120, y: size.height - 250), size: quoteSize, color: quoteColor, isOpening: false)
        }
    }
    
    private func drawLeafInCorner(context: CGContext, center: CGPoint, size: CGFloat, rotation: CGFloat) {
        context.saveGState()
        context.translateBy(x: center.x, y: center.y)
        context.rotate(by: rotation)
        
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.7).cgColor)
        context.setLineWidth(2)
        
        let leafPath = UIBezierPath()
        leafPath.move(to: CGPoint(x: 0, y: -size/2))
        leafPath.addCurve(to: CGPoint(x: 0, y: size/2),
                          controlPoint1: CGPoint(x: size/2, y: 0),
                          controlPoint2: CGPoint(x: size/3, y: size/2))
        leafPath.addCurve(to: CGPoint(x: 0, y: -size/2),
                          controlPoint1: CGPoint(x: -size/3, y: size/2),
                          controlPoint2: CGPoint(x: -size/2, y: 0))
        
        context.addPath(leafPath.cgPath)
        context.strokePath()
        
        context.restoreGState()
    }
    
    private func drawQuoteMark(context: CGContext, position: CGPoint, size: CGFloat, color: UIColor, isOpening: Bool) {
        context.saveGState()
        context.translateBy(x: position.x, y: position.y)
        if !isOpening {
            context.rotate(by: .pi)
        }
        
        context.setFillColor(color.cgColor)
        
        let quotePath = UIBezierPath()
        let quarterSize = size / 4
        
        // Первая кавычка
        quotePath.move(to: CGPoint(x: 0, y: 0))
        quotePath.addCurve(to: CGPoint(x: quarterSize, y: -quarterSize),
                           controlPoint1: CGPoint(x: 0, y: -quarterSize/2),
                           controlPoint2: CGPoint(x: quarterSize/2, y: -quarterSize))
        quotePath.addCurve(to: CGPoint(x: 0, y: -size/2),
                           controlPoint1: CGPoint(x: quarterSize * 1.5, y: -quarterSize),
                           controlPoint2: CGPoint(x: quarterSize, y: -size/2))
        quotePath.addLine(to: CGPoint(x: -quarterSize, y: -size/2))
        quotePath.addCurve(to: CGPoint(x: -quarterSize, y: 0),
                           controlPoint1: CGPoint(x: -quarterSize, y: -size/4),
                           controlPoint2: CGPoint(x: -quarterSize, y: -size/8))
        quotePath.close()
        
        // Вторая кавычка (смещена вправо)
        quotePath.move(to: CGPoint(x: size/2, y: 0))
        quotePath.addCurve(to: CGPoint(x: size/2 + quarterSize, y: -quarterSize),
                           controlPoint1: CGPoint(x: size/2, y: -quarterSize/2),
                           controlPoint2: CGPoint(x: size/2 + quarterSize/2, y: -quarterSize))
        quotePath.addCurve(to: CGPoint(x: size/2, y: -size/2),
                           controlPoint1: CGPoint(x: size/2 + quarterSize * 1.5, y: -quarterSize),
                           controlPoint2: CGPoint(x: size/2 + quarterSize, y: -size/2))
        quotePath.addLine(to: CGPoint(x: size/2 - quarterSize, y: -size/2))
        quotePath.addCurve(to: CGPoint(x: size/2 - quarterSize, y: 0),
                           controlPoint1: CGPoint(x: size/2 - quarterSize, y: -size/4),
                           controlPoint2: CGPoint(x: size/2 - quarterSize, y: -size/8))
        quotePath.close()
        
        context.addPath(quotePath.cgPath)
        context.fillPath()
        
        context.restoreGState()
    }
    
    private func applyFilters(context: UIGraphicsImageRendererContext) {
        // Применение эффектов фильтра будет зависеть от стиля
        // В этой реализации фильтры применяются непосредственно к контексту рисования
        // Это упрощенный вариант, так как применение CIFilter напрямую к контексту сложнее
    }
    
    // Сохраняет изображение в фотопленку
    func saveImageToPhotoLibrary() {
        guard let image = generatedImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully")
        }
    }
    
    // Создает временный URL для шаринга изображения
    func getImageURL() -> URL? {
        guard let image = generatedImage, let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error creating temporary file: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Настраивает генератор изображений
    func setupGenerator() {
        // Можно будет добавить дополнительные настройки инициализации
    }
} 