import AppKit
import Speech
import AVFoundation

class VoiceControlManager {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let wakeWord = "小助手"
    
    func startListening() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == .authorized {
                self.beginRecording()
            }
        }
    }
    
    private func beginRecording() {
        let inputNode = self.audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try! audioEngine.start()
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = false // 改为false以获取完整句子
        recognitionRequest?.requiresOnDeviceRecognition = true // 启用设备端识别提高准确性
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { result, error in
            if let error = error {
                print("识别错误: \(error.localizedDescription)")
                return
            }
            
            if let result = result {
                let text = result.bestTranscription.formattedString
                print("完整识别内容: \(text)")
                if text.lowercased().contains(self.wakeWord) {
                    self.processCommand(text)
                }
            }
        }
    }
    
    private func processCommand(_ text: String) {
        let cleanText = text.replacingOccurrences(of: wakeWord, with: "").trimmingCharacters(in: .whitespaces)
        
        if cleanText.contains("打开浏览器") {
            // 只打开默认浏览器，不导航到特定页面
            if let browserURL = URL(string: "http://") {
                NSWorkspace.shared.open(browserURL)
                speakResponse("正在打开浏览器")
            }
        }
        else if cleanText.contains("查看日历") {
            NSWorkspace.shared.open(URL(string: "ical://")!)
            speakResponse("正在打开日历")
        }
        else if cleanText.contains("打开元宝") {
            // 尝试打开腾讯元宝应用
            let appName = "腾讯元宝"
            let appURL = URL(fileURLWithPath: "/Applications/\(appName).app")
            let config = NSWorkspace.OpenConfiguration()
            
            NSWorkspace.shared.openApplication(
                at: appURL,
                configuration: config) { app, error in
                    if let error = error {
                        print("打开失败详情: \(error.localizedDescription)")
                    }
                    if app != nil {
                        self.speakResponse("正在打开腾讯元宝")
                    } else {
                        print("打开失败: \(error?.localizedDescription ?? "未知错误")")
                        self.speakResponse("找不到腾讯元宝应用")
                    }
                }
        }
        else if cleanText.contains("帮我查一下今天的机票") {
            speakResponse("正在查询今天的机票价格")
            // 这里可以添加实际的机票查询逻辑
            // 例如打开机票查询网站或调用API
            if let url = URL(string: "https://www.fliggy.com") {
                NSWorkspace.shared.open(url)
            }
        }
        else if cleanText.contains("关闭脚本") {
            speakResponse("正在关闭语音助手")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NSApp.terminate(nil)
            }
        }
        // 添加更多指令...
    }
    
    private func speakResponse(_ text: String) {
        let speechSynthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        speechSynthesizer.speak(utterance)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let voiceManager = VoiceControlManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        voiceManager.startListening()
        NSApp.setActivationPolicy(.accessory)
    }
    
    private func setupMenuBar() {
        statusItem.button?.image = NSImage(named: NSImage.Name("mic_icon"))
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()