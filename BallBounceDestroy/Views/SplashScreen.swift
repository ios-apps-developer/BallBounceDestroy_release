import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Image("bg_splash")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()

            Spinner()
        }
    }
}

struct Spinner: View {
    let rotationTime: Double = 0.75
    let animationTime: Double = 1.9
    let fullRotation: Angle = .degrees(360)
    static let initialDegree: Angle = .degrees(270)

    @State var spinnerStart: CGFloat = 0.0
    @State var spinnerEndS1: CGFloat = 0.03
    @State var spinnerEndS2S3: CGFloat = 0.03

    @State var rotationDegreeS1 = initialDegree
    @State var rotationDegreeS2 = initialDegree
    @State var rotationDegreeS3 = initialDegree

    var body: some View {
        ZStack {
            SpinnerCircle(
                start: spinnerStart,
                end: spinnerEndS2S3,
                rotation: rotationDegreeS3,
                color: Color.blue.opacity(0.8)
            )

            SpinnerCircle(
                start: spinnerStart,
                end: spinnerEndS2S3,
                rotation: rotationDegreeS2,
                color: Color.pink.opacity(0.8)
            )

            SpinnerCircle(
                start: spinnerStart,
                end: spinnerEndS1,
                rotation: rotationDegreeS1,
                color: Color.purple.opacity(0.8)
            )
        }
        .frame(width: 100, height: 100)
        .onAppear {
            self.animateSpinner()
            Timer.scheduledTimer(withTimeInterval: animationTime, repeats: true) { _ in
                self.animateSpinner()
            }
        }
    }

    func animateSpinner(with duration: Double, completion: @escaping (() -> Void)) {
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            withAnimation(Animation.easeInOut(duration: self.rotationTime)) {
                completion()
            }
        }
    }

    func animateSpinner() {
        animateSpinner(with: rotationTime) { self.spinnerEndS1 = 1.0 }

        animateSpinner(with: (rotationTime * 2) - 0.025) {
            self.rotationDegreeS1 += fullRotation
            self.spinnerEndS2S3 = 0.8
        }

        animateSpinner(with: rotationTime * 2) {
            self.spinnerEndS1 = 0.03
            self.spinnerEndS2S3 = 0.03
        }

        animateSpinner(with: (rotationTime * 2) + 0.0525) { self.rotationDegreeS2 += fullRotation }

        animateSpinner(with: (rotationTime * 2) + 0.225) { self.rotationDegreeS3 += fullRotation }
    }
}

struct SpinnerCircle: View {
    var start: CGFloat
    var end: CGFloat
    var rotation: Angle
    var color: Color

    var body: some View {
        Circle()
            .trim(from: start, to: end)
            .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
            .foregroundColor(color)
            .rotationEffect(rotation)
    }
}
