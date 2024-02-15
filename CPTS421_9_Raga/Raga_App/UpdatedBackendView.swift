//
//  TestView.swift
//  Raga_App
//
//  Created by Aiden Walker on 9/17/23.
//




import SwiftUI
import UIKit
import Keyboard

struct TestView: View {
    var body: some View {
        VStack {
            PlayScreenView()
        }
        
    }
}

struct PlayScreenView : View {
    @StateObject var uiData : UIData = UIData.shared
    
    var body : some View {
        ZStack {
            VStack {
                //NewKeyboardView(touchHandler: touchHandler, instrumentData: instrumentData, audioEngine: audioEngine)
                TapView()
                //Spacer()
                //SwarasView()
            }
        }
    }
}

struct TapView : View {
    @StateObject var data : UIData = UIData.shared
    //@StateObject var tapHandler : TapHandler = TapHandler(xSpacing: 5, ySpacing: 50,width: 25, xCount: 13, yCount: 3)
    @StateObject var touchHandler : TouchHandler = TouchHandler.shared
    @StateObject var instrumentData: KeyboardData = KeyboardData()
    @StateObject var audioEngine : InstrumentConductor = InstrumentConductor()
    
    var x = 13
    var y = 3
    @State var height : CGFloat = 0
    
    func getSize() -> Int {
        var xCount = 13
        var xWidth = 25
        var spacing = 10
        return xWidth*xCount + spacing*(xCount - 1)
    }
    
    func isActivated(xs: Int, ys:Int) -> Bool {
        return touchHandler.selectedKeys.contains(xs*self.y + ys)
    }
    
    func setHeight(g: CGFloat) {
        self.height = g
    }
    
    func getYBounds() -> Array<Int> {
        var ret = [Int]()
        if (touchHandler.yBounds.isEmpty) {
            return ret
        }
        
        for i in 0..<y {
            ret.append(touchHandler.yBounds[i])
        }
        
        return ret
    }
    
    func getXBounds() -> [Int] {
        var ret = [Int]()
        if (touchHandler.bounds.isEmpty) {
            return ret
        }
        
        for i in 0..<x {
            ret.append(touchHandler.bounds[i])
        }
        
        return ret
    }
    
    var body : some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            ZStack {
                let bnds = getYBounds()
                ForEach(0..<bnds.count, id: \.self) { yIndex in
                    if (!touchHandler.containsY(y: yIndex)) {
                        let control1 = CGPoint(x:0,y:bnds[yIndex])
                        let control2 = CGPoint(x:0,y:bnds[yIndex])
                        Path { path in
                            path.move(to: CGPoint(x:0, y:bnds[yIndex]))
                            path.addCurve(to: CGPoint(x: Int(width),y:bnds[yIndex]), control1: control1, control2: control2)
                            //path.closeSubpath()
                        }.stroke(Color.blue,lineWidth: 10)
                    }
                    else {
                        let touchLocation = touchHandler.getMaxBend(y: yIndex)
                        let control1 = CGPoint(x:touchLocation.x*0.75, y:touchLocation.y)
                        let control2 = CGPoint(x:touchLocation.x*1.25,y:touchLocation.y)
                        Path { path in
                            path.move(to: CGPoint(x:0, y:bnds[yIndex]))
                            path.addCurve(to: CGPoint(x: Int(width),y:bnds[yIndex]), control1: control1, control2: control2)
                            //path.closeSubpath()
                        }.stroke(Color.blue,lineWidth: 10)
                    }
                    
                    
                }
                
                VStack(spacing:CGFloat(touchHandler.ySpacing)) {
                    ForEach(0..<touchHandler.yCount, id: \.self) { yIndex in
                        HStack(spacing:CGFloat(touchHandler.xSpacing)) {
                            ForEach(0..<touchHandler.xCount, id: \.self) { xIndex in
                                ZStack {
                                    KeyboardKey(pitch: Pitch(intValue: 5), isActivated: isActivated(xs: xIndex, ys: yIndex), text:"", whiteKeyColor: .black, blackKeyColor: .black)
                                        .frame(width: 25, height: 50)
                                        .opacity(0.8)

                                    Text(instrumentData.currentKeyboard[xIndex].name)
                                }
                            }
                        }
                    }
                
                }
                
                let frame = geometry.frame(in: CoordinateSpace.local)
                TouchView(frame:frame, engine: audioEngine)
                
            }
        }
        
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            PlayScreenView()
        }
        
    }
    
}

struct TouchView : UIViewRepresentable {
    var engine: InstrumentConductor
    var f: CGRect
    
    init(frame:CGRect, engine:InstrumentConductor) {
        f = frame
        self.engine = engine
    }
    func makeUIView(context: Context) -> TouchableView {
        TouchableView(frame: f,engine: engine)
    }
    
    func updateUIView(_ view: TouchableView, context: Context) {
        print("here")
    }
}

class TouchHandler : ObservableObject, Identifiable {
    static var shared = TouchHandler()
    @Published var points = [CGPoint]()
    @Published var touches = [UITouch]()
    @Published var initialY = [CGFloat]()
    
    @Published var limits:Array<Int> = Array(repeating: 1, count: 13)
    @Published var selectedKeys: Array<Int> = Array()
    
    @Published var bounds: Array<Int> = Array()
    @Published var yBounds: Array<Int> = Array()
    
    @Published var xSpacing: Int = 0
    @Published var ySpacing: Int = 150
    
    @Published var xCount: Int = 13
    @Published var yCount: Int = 3
    
    @Published var xPadding: Int = 0
    @Published var yPadding: Int = 0
    
    @Published var xSize: Int = 25
    @Published var ySize: Int = 50
    @Published var currentBendAmount: CGFloat = 0
    var keyboardData = KeyboardData.shared
    
    let id = UUID()
    
    func containsY(y:Int) -> Bool {
        for i in 0..<points.count {
            if selectedKeys[i] % yCount == y {
                return true
            }
        }
        
        return false
    }
    
    func getMaxBend(y:Int) -> CGPoint {
        if (points.isEmpty) {
            return CGPoint()
        }
        var max:CGFloat = 0
        var maxIndex = 0
        for i in 0..<points.count {
            if selectedKeys[i] % yCount != y {
                continue
            }
            let diff = initialY[i] - points[i].y
            if (abs(diff) > abs(max)) {
                max = diff
                maxIndex = i
            }
        }
        
        return points[maxIndex]
    }
    
    func isSelected(index: Int) -> Bool{
        return selectedKeys.contains(index)
    }
    
    func getWidth() -> Int {
        return (xSize*xCount) + (xSpacing*(xCount-1))
    }
    
    func touchIndex(location: CGPoint) -> Int {
        for i in 0..<bounds.count {
            let bound = bounds[i]
            let yBound = yBounds[i]
            
            if (abs(bound - Int(location.x)) <= xSize / 2) {
                if (abs(yBound - Int(location.y)) <= ySize / 2) {
                    return i
                }
                
            }
        }
        return -1
    }
    
    // updates the current coords of the user drag
    func updateDrag(index:Int) {
        // checks if above or below drag start, gets limit based on that
        if points[index].y > initialY[index] {
            limits[index] = getLowerBendLimit(index: index)
        }
        else {
            limits[index] = getUpperBendLimit(index: index)
        }
    }
    
    func getUpperBendLimit(index:Int) -> Int {
        if index == keyboardData.totalSwaras - 1 {
            return 1
        }
        
        return keyboardData.currentKeyboard[index + 1].getPitch() - keyboardData.currentKeyboard[index].getPitch()
    }
    
    func getLowerBendLimit(index: Int) -> Int {
        if index == 0 {
            return -1
        }
        
        return -1 * (keyboardData.currentKeyboard[index].getPitch() - keyboardData.currentKeyboard[index - 1].getPitch())
    }
    
    func inBounds(location: CGPoint) -> Bool {
        return touchIndex(location: location) != -1
    }
    
    // gets current offset from beginning of drag
    func getOffSet(index:Int) -> Float {
        // gets current y, and distance from initial y
        let distance = initialY[index] - points[index].y
        
        // gets shift amount
        var shift = distance / (initialY[index] / CGFloat(abs(limits[index])))
        
        shift *= 2
        // checks if user dragged to max
        if abs(shift) > abs(CGFloat(limits[index])) {
            shift = CGFloat(limits[index])
        }
        
        currentBendAmount = CGFloat(shift)
        return Float(shift)
    }
}
    
class TouchableView: UIView {
    var handler : TouchHandler = TouchHandler.shared
    var instrumentData : KeyboardData = KeyboardData.shared
    var engine: InstrumentConductor
    
    required init(frame: CGRect, engine: InstrumentConductor) {
        self.engine = engine
        super.init(frame:frame)
        isMultipleTouchEnabled = true
        setUpFrame(frame: frame)
    }
    
    override init(frame: CGRect) {
        engine = InstrumentConductor()
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        setUpFrame(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        engine = InstrumentConductor()
        super.init(coder: aDecoder)
        isMultipleTouchEnabled = true
    }
    
    func viewDidLoad() {
        
    }
    
    func setUpFrame(frame:CGRect) {
        handler.xPadding = (Int(frame.width) - ((handler.xSize * handler.xCount)+((handler.xCount-1) * handler.xSpacing))) / 2
        // ( height + spacing ) * width
        
        handler.yPadding = (Int(frame.height) - ((handler.ySize * handler.yCount)+((handler.yCount-1) * handler.ySpacing))) / 2
        var cur = (handler.xSize / 2) + handler.xPadding
        for _ in 0..<handler.xCount {
            var yCur = (handler.ySize / 2) + handler.yPadding
            for _2 in 0..<handler.yCount {
                handler.bounds.append(cur)
                handler.yBounds.append(yCur)
                yCur += handler.ySpacing + handler.ySize
            }
            
            cur += handler.xSpacing + handler.xSize
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {
            if (handler.inBounds(location: $0.location(in: self))) {
                let selectedIndex = handler.touchIndex(location: $0.location(in: self))
                if (selectedIndex != -1) {
                    if (!handler.selectedKeys.contains(selectedIndex)) {
                        let selectedPitch = (handler.touchIndex(location: $0.location(in: self)) % 3) * 5
                        handler.selectedKeys.append(selectedIndex)
                        
                        engine.on(pitch: Float(instrumentData.currentKeyboard[selectedIndex/3].getPitch()+50 + selectedPitch), index: 0)
                    }
                }
                self.handler.touches.append($0)
                self.handler.points.append($0.location(in: self))
                self.handler.initialY.append($0.location(in: self).y)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {
            let index = self.handler.touches.firstIndex(of: $0)
            if (index != nil) {
                self.handler.points[index!] = $0.location(in: self)
                let selectedIndex = self.handler.selectedKeys[index!]
                let newSelectedIndex = handler.touchIndex(location: handler.points[index!])
                
                if (selectedIndex != -1 && newSelectedIndex != -1 && selectedIndex != newSelectedIndex) {
                    let selectedPitch = (handler.touchIndex(location: handler.points[index!]) % 3) * 5
                    self.handler.selectedKeys[index!] = newSelectedIndex
                    
                    engine.offNew(pitch: instrumentData.currentKeyboard[selectedIndex/3].getPitch()+50 + selectedPitch, index: 0)
                    engine.on(pitch: Float(instrumentData.currentKeyboard[newSelectedIndex/3].getPitch()+50 + selectedPitch), index: 0)
                }
                else if (selectedIndex != -1 && selectedIndex == newSelectedIndex) {
                    self.handler.updateDrag(index: index!)
                    engine.bend(offset: handler.getOffSet(index: index!))
                }
            }
        
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach {
            let index = self.handler.touches.firstIndex(of: $0)
            
            if index != nil {
                let selectedIndex = handler.selectedKeys[index!] / 3
                let selectedPitch = (handler.touchIndex(location: handler.points[index!]) % 3) * 5
                engine.offNew(pitch: instrumentData.currentKeyboard[selectedIndex].getPitch()+50+selectedPitch, index: 0)
                
                self.handler.touches.remove(at: index!)
                self.handler.points.remove(at: index!)
                self.handler.initialY.remove(at:index!)
                self.handler.selectedKeys.remove(at: index!)
            }
            
            
        }
    }
}

