//
//  AppDelegate.swift
//  SpeedRead
//
//  Created by libe on 7/11/17.
//  Copyright © 2017 Liberato Aguilar. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: -2)
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var pauseButton: NSButton!
    @IBOutlet weak var restartButton: NSButton!
    @IBOutlet weak var darkcheckbox: NSButton!
    @IBOutlet weak var lightcheckbox: NSButton!
    @IBOutlet weak var settingslabel: NSTextField!
    @IBOutlet weak var themeslabel: NSTextField!
    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var powerButton: NSButton!
    @IBOutlet weak var timeleftlabel: NSTextField!
    @IBOutlet weak var stepper: NSStepper!
    @IBOutlet weak var wpmlabel: NSTextField!
    @IBOutlet weak var speedlabel: NSTextField!
    
    
    var firstClipboardItem = ""
    var first:[String] = []
    var stri:String = ""
    var fstr:String = ""
    var timer: Timer?
    var timeractive = 0
    var toolbar:NSToolbar!
    var tset = 0
    var ended = 0
    var themesel = "Dark"
    var WPM:Float = 0.25
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
//        let point = NSPoint(x: 200, y: 0)
//        label.translateOrigin(to: point)
        timeleft()
        settingslabel.isHidden = true
        themeslabel.isHidden = true
        darkcheckbox.isHidden = true
        lightcheckbox.isHidden = true
        wpmlabel.isHidden = true
        stepper.isHidden = true
        speedlabel.isHidden = true
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        
        darkcheckbox.attributedTitle = NSAttributedString(string: "Dark", attributes: [ NSAttributedString.Key.foregroundColor : NSColor(calibratedRed: 184/255, green: 184/255, blue: 184/255, alpha: 1), NSAttributedString.Key.paragraphStyle : pstyle ])
        lightcheckbox.attributedTitle = NSAttributedString(string: "Light", attributes: [ NSAttributedString.Key.foregroundColor : NSColor(calibratedRed: 184/255, green: 184/255, blue: 184/255, alpha: 1), NSAttributedString.Key.paragraphStyle : pstyle ])
        
        pauseButton.isHidden = true
        restartButton.isHidden = true
        getclip()
        
        label.stringValue = first[0]
        label.textColor = NSColor(calibratedRed: 184/255, green: 184/255, blue: 184/255, alpha: 1)
        //startUIUpdateTimer()
        
//        toolbar = NSToolbar(identifier:"ScreenNameToolbarIdentifier")
//        toolbar.allowsUserCustomization = false
//        window.toolbar = toolbar
//        
        
        window.setIsZoomed(true)
        window.titleVisibility = NSWindow.TitleVisibility.hidden;
        window.titlebarAppearsTransparent = true;
        window.backgroundColor = NSColor(calibratedRed: 31/255, green: 31/255, blue: 31/255, alpha: 1)
        if let button = statusItem.button {
            button.image = NSImage(named: "Book")
            button.action = #selector(toggle)
        }
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Read", action: #selector(quit) , keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit SpeedRead", action: #selector(quit) , keyEquivalent: "q"))
        
        //statusItem.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func toggle(sender: NSButton){
        if window.isVisible {
        window.setIsVisible(false)
        if timeractive == 1{
            timer?.invalidate()
            timeractive = 0
        }
            settingslabel.isHidden = true
            themeslabel.isHidden = true
            darkcheckbox.isHidden = true
            lightcheckbox.isHidden = true
        pauseButton.isHidden = true
        playButton.isHidden = false
        label.isHidden = false
        getclip()
        restartButton.isHidden = true
        label.stringValue = first[0]
        wpmlabel.isHidden = true
        stepper.isHidden = true
        speedlabel.isHidden = true
        timeleftlabel.isHidden = false
        tset = 0
        }else{
            getclip()
            updateUI()
            //label.stringValue = first[0]
            NSApplication.shared.activate(ignoringOtherApps: true)
            window.setIsVisible(true)
            window.makeKeyAndOrderFront(self)
        }
    }
    
    
    @IBAction func quit(sender: NSButton){
        NSApplication.shared.terminate(sender)
    }
    
    func getclip(){
        //clipboard
        let pasteboard = NSPasteboard.general
        
        var clipboardItems: [String] = []
        for element in pasteboard.pasteboardItems! {
            if let str = element.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) {
                clipboardItems.append(str)
            } else {
                clipboardItems.append("ERROR NO CLIPBOARD OR NO TEXT IN CLIPBOARD")
            }
        }
        
        // Access the item in the clipboard
        firstClipboardItem = clipboardItems[0]
        first = firstClipboardItem.components(separatedBy: " ")
    }
    
    @IBAction func stepperIncrease(sender: NSStepper){
        let s1 = 100 / stepper.floatValue
        WPM = s1
        
        wpmlabel.stringValue = String(stepper.intValue) + " WPM"
    }
    
    @IBAction func play(sender: NSButton){
        startUIUpdateTimer()
        playButton.isHidden = true
        pauseButton.isHidden = false
    }
    
    @IBAction func pause(sender: NSButton) {
        timer?.invalidate()
        playButton.isHidden = false
        pauseButton.isHidden = true
        
    }
    
    func startUIUpdateTimer() {
        // NOTE: For our purposes, the timer must run on the main queue, so use GCD to make sure.
        //       This can still be called from the main queue without a problem since we're using dispatch_async.
            // Start a time that calls self.updateUI() once every tenth of a second
        //hello-h
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(WPM), target:self, selector:#selector(AppDelegate.updateUI), userInfo: nil, repeats: true)
        timeractive = 1
    }
    
    @objc func updateUI()  {
        timeleft()
        if first.count > 0 {
            stri = String(first[0])
            stri = stri.replacingOccurrences(of: "-", with: "")
            stri = stri.replacingOccurrences(of: "_", with: "")
            stri = stri.replacingOccurrences(of: ".", with: "")
           // print(String(stri.characters))
            var characters1 = Array(String(stri))
            for x in characters1 {
                if x == ","{
                    characters1.removeLast()
                } else if x == "."{
                    characters1.removeLast()
                } else if x == "?"{
                    characters1.removeLast()
                } else if x == "!"{
                    characters1.removeLast()
                } else if x == ":"{
                    characters1.removeLast()
                } else if x == ";"{
                    characters1.removeLast()
                } else if x == "'"{
                    characters1.remove(at: characters1.count - 2)
                }
            }
            
            let num = characters1.count
            var lett = 0
            if num % 2 == 0{
                lett = num/2
            } else if num == 1{
                lett = 0
            } else {
                lett = Int(num/2)
            }
            let characters2 = Array(String(stri))
            if characters2[lett] == "'"{
                lett -= 1
            } else if characters2[lett] == "-"{
                lett -= 1
            } else if characters2[lett] == "."{
                lett -= 1
            }
            let pstyle = NSMutableParagraphStyle()
            pstyle.alignment = .center
            let rrange = NSRange(location: lett, length: 1)
            let mtsr = NSMutableAttributedString(string: first[0], attributes: [NSAttributedString.Key.paragraphStyle : pstyle])
            mtsr.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.red, range: rrange)
            label.objectValue = mtsr

            first.removeFirst()
        } else {
            pauseButton.isHidden = true
            playButton.isHidden = true
            timer?.invalidate()
            restartButton.isHidden = false
            ended = 1
        }
        
    }
    
    @IBAction func restart(sender: NSButton)  {
        playButton.isHidden = false
        restartButton.isHidden = true
        getclip()
        updateUI()
        //label.stringValue = first[0]
        ended = 0
    }
    
    @IBAction func settingss (sender: NSButton){
        timeleft()
        if tset == 0{
            playButton.isHidden = true
            pauseButton.isHidden = true
            restartButton.isHidden = true
            restartButton.isHidden = true
            timeleftlabel.isHidden = true
            label.isHidden = true
            tset = 1
            settingslabel.isHidden = false
            themeslabel.isHidden = false
            darkcheckbox.isHidden = false
            lightcheckbox.isHidden = false
            wpmlabel.isHidden = false
            stepper.isHidden = false
            speedlabel.isHidden = false
            if timeractive == 1 {
                timer?.invalidate()
                timeractive = 0
            }
        } else {
            playButton.isHidden = false
            if ended == 0 {
                restartButton.isHidden = true
            } else {
               restartButton.isHidden = false
               playButton.isHidden = true
            }
            settingslabel.isHidden = true
            timeleftlabel.isHidden = false
            themeslabel.isHidden = true
            darkcheckbox.isHidden = true
            lightcheckbox.isHidden = true
            wpmlabel.isHidden = true
            stepper.isHidden = true
            speedlabel.isHidden = true
            label.isHidden = false
            tset = 0
        }
    }
    
    
    @IBAction func darklistener(sender: NSButton) {
        lightcheckbox.setNextState()
        if themesel == "Dark"{
            lightthemeon()
            themesel = "Light"
        } else {
            darkthemeon()
            themesel = "Dark"
        }
    }

    @IBAction func lightlistener(sender: NSButton) {
        darkcheckbox.setNextState()
        if themesel == "Dark"{
            lightthemeon()
            themesel = "Light"
        } else {
            darkthemeon()
            themesel = "Dark"
        }
    }
    
    func darkthemeon() {
        pauseButton.image = NSImage(named: "pause")
        playButton.image = NSImage(named: "play")
        settingsButton.image = NSImage(named: "settings")
        restartButton.image = NSImage(named: "redo")
        powerButton.image = NSImage(named: "power")
        window.backgroundColor  = NSColor(calibratedRed: 31/255, green: 31/255, blue: 31/255, alpha: 1)// NSColor(calibratedRed: 184/255, green: 184/255, blue: 184/255, alpha: 1)
        label.textColor = NSColor(calibratedRed: 184/255, green: 184/255, blue: 184/255, alpha: 1)
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        darkcheckbox.attributedTitle = NSAttributedString(string: "Dark", attributes: [ NSAttributedString.Key.foregroundColor : NSColor(calibratedRed: 184/255, green: 184/255, blue: 184/255, alpha: 1), NSAttributedString.Key.paragraphStyle : pstyle ])
        lightcheckbox.attributedTitle = NSAttributedString(string: "Light", attributes: [ NSAttributedString.Key.foregroundColor : NSColor(calibratedRed: 184/255, green: 184/255, blue: 184/255, alpha: 1), NSAttributedString.Key.paragraphStyle : pstyle ])
        settingslabel.textColor = NSColor(calibratedRed: 184/255, green: 184/255, blue: 184/255, alpha: 1)
        themeslabel.textColor = NSColor(calibratedRed: 184/255, green: 184/255, blue: 184/255, alpha: 1)
        timeleftlabel.textColor = NSColor(calibratedRed: 184/255, green: 184/255, blue: 184/255, alpha: 1)
        wpmlabel.textColor = NSColor(calibratedRed: 184/255, green: 184/255, blue: 184/255, alpha: 1)
        speedlabel.textColor = NSColor(calibratedRed: 184/255, green: 184/255, blue: 184/255, alpha: 1)
    }
    func lightthemeon() {
      //  pauseButton.image = NSImage(named: "pauselight")
      //  playButton.image = NSImage(named: "playlight")
      //  settingsButton.image = NSImage(named: "settingslight")
      //  restartButton.image = NSImage(named: "redolight")
      //  powerButton.image = NSImage(named: "powerlight")
        window.backgroundColor  = NSColor(calibratedRed: 184/255, green: 184/255, blue: 184/255, alpha: 1)
        label.textColor = NSColor(calibratedRed: 31/255, green: 31/255, blue: 31/255, alpha: 1)
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        darkcheckbox.attributedTitle = NSAttributedString(string: "Dark", attributes: [ NSAttributedString.Key.foregroundColor : NSColor(calibratedRed: 31/255, green: 31/255, blue: 31/255, alpha: 1), NSAttributedString.Key.paragraphStyle : pstyle ])
        lightcheckbox.attributedTitle = NSAttributedString(string: "Light", attributes: [ NSAttributedString.Key.foregroundColor : NSColor(calibratedRed: 31/255, green: 31/255, blue: 31/255, alpha: 1), NSAttributedString.Key.paragraphStyle : pstyle ])
        settingslabel.textColor = NSColor(calibratedRed: 31/255, green: 31/255, blue: 31/255, alpha: 1)
        themeslabel.textColor = NSColor(calibratedRed: 31/255, green: 31/255, blue: 31/255, alpha: 1)
        timeleftlabel.textColor = NSColor(calibratedRed: 31/255, green: 31/255, blue: 31/255, alpha: 1)
        wpmlabel.textColor = NSColor(calibratedRed: 31/255, green: 31/255, blue: 31/255, alpha: 1)
        speedlabel.textColor = NSColor(calibratedRed: 31/255, green: 31/255, blue: 31/255, alpha: 1)
    }
    
    func timeleft(){
        let numb = Double(first.count)
        let wpm = Double(stepper.intValue)
        var left = numb/wpm
        var modifier = ""
        var smod = ""
        if left < 1 {
            modifier = "> "
        }
        if Int(left) == 0{
            left += 1
        }
        if Int(left) > 1{
            smod = "s"
        }
        let str = modifier + String(Int(left)) + " Minute" + smod
        timeleftlabel.stringValue = str
        
    }
}

