import AVFoundation
import CoreML
import SoundAnalysis

class VoiceWakeUpManager: NSObject, SNResultsObserving {
    
    // 单例，方便在 AppDelegate 或 ViewController 中全局调用
    static let shared = VoiceWakeUpManager()
    
    // 核心音频与分析组件
    private let audioEngine = AVAudioEngine()
    private var streamAnalyzer: SNAudioStreamAnalyzer?
    private var classificationRequest: SNClassifySoundRequest?
    
    // 回调闭包：当成功识别到指令时，通知外部
    var onKeywordDetected: ((String) -> Void)?
    
    // 状态标记，防止重复启动
    private(set) var isListening = false
    
    // 防抖标记：避免用户拖长音时，1秒内连续触发多次打开窗口
    private var isProtectedDuration = false
    
    private override init() {
        super.init()
    }
    
    /// 启动语音监听
    func startListening() {
        guard !isListening else { return }
        
        // 在异步线程初始化，避免卡住主线程 UI
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.setupAndStartAudioEngine()
        }
    }
    
    /// 停止语音监听（退出聊天窗或 App 切入后台时可以调用）
    func stopListening() {
        guard isListening else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        streamAnalyzer = nil
        classificationRequest = nil
        isListening = false
        print("🛑 语音监听已安全关闭")
    }
    
    private func setupAndStartAudioEngine() {
        do {
            // 1. 配置 Audio Session：前台挂机必用配置
            let audioSession = AVAudioSession.sharedInstance()
            // .playAndRecord 允许录音的同时播放声音；.mixWithOthers 保证不杀死系统其它App的音乐
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.mixWithOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // 2. 加载你导出的 5KB 核心大脑模型
            // 注意：请确保你的模型文件名在工程里确叫 `HeyAldeloClassifier`
            let modelConfig = MLModelConfiguration()
            // 强制使用 CPU/GPU 组合，保证在老款 iPhone 上也有极佳兼容性
            modelConfig.computeUnits = .all
            
            let wrappedModel = try HeyAldeloClassifier(configuration: modelConfig)
            classificationRequest = try SNClassifySoundRequest(mlModel: wrappedModel.model)
            
            // 3. 配置音频引擎
            let inputNode = audioEngine.inputNode
            let inputFormat = inputNode.outputFormat(forBus: 0)
            
            // 4. 初始化流分析器（SoundAnalysis 官方原生支持自动重采样，直接喂入麦克风硬件格式即可）
            streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
            
            // 5. 将分类请求挂载到分析器，并指定自己(self)为结果接收代理
            try streamAnalyzer?.add(classificationRequest!, withObserver: self)
            
            // 6. 开启麦克风接出口（Tap），将音频 Buffer 持续送入分析器
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] (buffer, time) in
                // 守护：只有当帧长大于0时才分析，防止因空 Buffer 导致 CoreML 报错
                if buffer.frameLength > 0 {
                    self?.streamAnalyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
                }
            }
            
            // 7. 启动音频引擎
            audioEngine.prepare()
            try audioEngine.start()
            
            isListening = true
            print("🎙️ [Hey Aldelo] 唤醒引擎已在后台就绪，正在前台实时聆听...")
            
        } catch {
            print("❌ 语音唤醒引擎启动失败: \(error.localizedDescription)")
            isListening = false
        }
    }
    
    // MARK: - SNResultsObserving 核心代理回调
    func request(_ request: SNRequest, didProduce result: SNResult) {
        // 确保收到的是声音分类结果
        guard let classificationResult = result as? SNClassificationResult,
              let topClassification = classificationResult.classifications.first else { return }
        
        let className = topClassification.identifier // 对应你在 Create ML 里的文件夹名
        let confidence = topClassification.confidence // 置信度分数 (0.0 ~ 1.0)
        
        // 打印实时日志（调试用，正式上架可以删掉）
        print("当前声音: \(className) | 置信度: \(String(format: "%.2f", confidence * 100))%")
        
        // 判定核心逻辑
        if className == "hey_aldelo" && confidence > 0.96 {
            // 检查防抖保护锁，防止连续高频触发
            guard !isProtectedDuration else { return }
            
            isProtectedDuration = true
            
            // 回到主线程执行 UI 操作（打开聊天窗口）
            DispatchQueue.main.async { [weak self] in
                print("🔥 [🔥 触发成功] 听到有效指令：Hey Aldelo！置信度：\(confidence)")
                
                // 震动反馈：给用户一种被手机听懂的爽快感
                AudioServicesPlaySystemSound(1519) // Peek 弱震动
                
                // 触发外部传入的打开聊天窗闭包
                self?.onKeywordDetected?("🔥 [🔥 触发成功] 听到有效指令：Hey Aldelo！置信度：\(confidence)")
                
                // 3秒后解锁保护，允许下一次唤醒
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self?.isProtectedDuration = false
                }
            }
        } else {
            
        }
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("❌ SoundAnalysis 分析管道中途报错: \(error)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("ℹ️ 分析流完成")
    }
}
