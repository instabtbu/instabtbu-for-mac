//
//  ViewController.swift
//  instabtbu for mac
//
//  Created by 杨培文 on 14/12/19.
//  Copyright (c) 2014年 杨培文. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = NSUserDefaults(suiteName: "data")
        {
            if let num = data.stringForKey("num"){
                numtext.stringValue=num
            }
            if let psw = data.stringForKey("psw"){
                pswtext.stringValue=psw
            }
            if let liuliang = data.stringForKey("liuliang"){
                liulianglabel.stringValue=liuliang
            }
            if let zaixian = data.stringForKey("zaixian"){
                zaixianlabel.stringValue=zaixian
            }
            
            if let data = NSUserDefaults(suiteName: "data")
            {
                let zdc = data.integerForKey("zidongcha")
                let zddl = data.integerForKey("zidongdenglu")
                if zdc != 0 {
                    zidongchaliuliang()
                }
                if zddl != 0 {
                    xiancheng({self.denglu2(false)})
                }
                refreshzidong()
            }
        }
        showtext.becomeFirstResponder()
    }
    
    
    
    override func viewDidDisappear() {
        print("disappear")
        exit(0)
    }

    func refreshzidong(){
        if let data = NSUserDefaults(suiteName: "data")
        {
            let zdc = data.integerForKey("zidongcha")
            let zddl = data.integerForKey("zidongdenglu")
            if zdc != 0 {
                zidongchaxun.image=NSImage(named: "zidongcha1")
            }else{
                zidongchaxun.image=NSImage(named: "zidongcha0")
            }
            if zddl != 0 {
                zidongdenglu.image=NSImage(named: "zidongdenglu1")
            }else{
                zidongdenglu.image=NSImage(named: "zidongdenglu0")
            }
        }
        
    }

    
    @IBAction func zidongcha(sender: AnyObject) {
        if let data = NSUserDefaults(suiteName: "data")
        {
            var zd = data.integerForKey("zidongcha")
            zd=1-zd
            data.setInteger(zd, forKey: "zidongcha")
        }
        refreshzidong()
    }
    
    @IBAction func zidongdenglu(sender: AnyObject) {
        if let data = NSUserDefaults(suiteName: "data")
        {
            var zd = data.integerForKey("zidongdenglu")
            zd=1-zd
            data.setInteger(zd, forKey: "zidongdenglu")
        }
        refreshzidong()
    }
    
    @IBOutlet weak var zhuangtai: NSImageView!
    @IBOutlet weak var denglubutton: NSButton!
    @IBOutlet weak var numtext: NSTextField!
    @IBOutlet weak var pswtext: NSTextField!
    @IBOutlet weak var zaixianlabel: NSTextField!
    @IBOutlet weak var zidongdenglu: NSButton!
    @IBOutlet weak var zidongchaxun: NSButton!
    @IBOutlet weak var liulianglabel: NSTextField!
    
    
    @IBAction func denglu(sender: AnyObject) {
        xiancheng({
            self.denglu2(false)
        })
    }
    
    @IBAction func randdenglu(sender: AnyObject) {
        let dir = NSHomeDirectory() + "/out.txt"
        print(dir)
        do {
            let text = try NSString(contentsOfFile: dir, encoding: NSUTF8StringEncoding)
            var users = text.componentsSeparatedByString("\n")
            let n = (UInt32)(users.count)
            let i = (Int)(arc4random_uniform(n))
            let lucky: String = users[i] as String
            print(lucky)
            var num = lucky.componentsSeparatedByString(",")
            if num.count == 2{
                numtext.stringValue = num[0]
                pswtext.stringValue = num[1]
                xiancheng({
                    self.chaliuliang2()
                })
            }
        } catch _ {
        }
    }
    
    func yellow(){
        xiancheng({
            let color = NSColor(red: 1, green: 1, blue: 0, alpha: 1)
            self.liulianglabel.textColor=color
            self.zaixianlabel.textColor=color
            
            for var i:CGFloat=0;i<255;i+=5{
                let color = NSColor(red: 1, green: 1, blue: (i/255.0), alpha: 1)
                self.ui({
                    self.liulianglabel.textColor=color
                    self.zaixianlabel.textColor=color
                })
                NSThread.sleepForTimeInterval(0.02)
            }
            
        })
    }
    
    func red(){
        xiancheng({
            let color = NSColor(red: 1, green: 0, blue: 0, alpha: 1)
            self.liulianglabel.textColor=color
            self.zaixianlabel.textColor=color
            
            for var i:CGFloat=0;i<255;i+=5{
                let color = NSColor(red: 1, green: (i/255.0), blue: (i/255.0), alpha: 1)
                self.ui({
                    self.liulianglabel.textColor=color
                    self.zaixianlabel.textColor=color
                })
                NSThread.sleepForTimeInterval(0.02)
            }
            
        })
    }
    
    func denglu2(isbackground: Bool){
        let ip = oc().getIP()
        if ip != nil{
            let buf:[UInt8] = [0x7E,0x11,0x00,0x00,0x54,0x01,0x7E]
            var trytime = 0
            var rec = [UInt8]()
            
            repeat{
                repeat
                {
                    Common.connect()
                    Common.send(buf)
                    rec = Common.read()
                    rec = Common.fanzhuanyi(rec)
                    trytime++
                    print("第\(trytime)次")
                    if trytime > 20{
                        red()
                        //show("登录失败")
                        
                        //只要失败次数超过指定次数就直接return
                        return
                    }
                    NSThread.sleepForTimeInterval(0.1)
                    //防止服务器一直丢弃连接,我们需要一定的延时
                }while(rec.count != 23)
                
                if rec.count==23 {
                    Common.verify=[UInt8]()
                    for i in 0...15
                    {
                        Common.verify.append(rec[i+4])
                    }
                    print("获取到验证码:\(Common.t(Common.verify))")
                    var msg = Common.user(numtext.stringValue, psw: pswtext.stringValue)
                    msg = Common.feng(msg, cmd: 0x01)
                    msg=Common.zhuanyi(msg)
                    Common.send(msg)
                    rec = Common.read()
                }
            }while(rec.count == 0)
            
            Common.client.close()
            if Common.jiefeng(rec){
                print("保持在线数据:\(Common.t(Common.remain))")
                ui({
//                    self.locationManager.startUpdatingLocation()
                    //通过locationManager保持后台
                    
                    let data = NSUserDefaults(suiteName: "data")
                    data?.setObject(self.numtext.stringValue, forKey: "num")
                    data?.setObject(self.pswtext.stringValue, forKey: "psw")
                    
                    //登录成功之后调整UI
                    self.zhuangtai.image=NSImage(named: "shangwang_yilianjie5.png")
                    self.zidongchaliuliang()
                    self.numtext.enabled = false
                    self.pswtext.enabled = false
                    self.denglubutton.enabled = false
                })
                always = true
                //保持在线线程
                if !isbackground{
                    xiancheng({
                        self.baochi()
                    })
                    //测试是否在线线程
                    xiancheng({
                        self.testonline()
                    })
                }
            }else {
                if !isbackground{
                    show(Common.recString)
                }
                print(Common.recString)
            }
        }else {
            if !isbackground{
                show("获取数据出错");
            }
        }
    }
    
    var always = false
    
    func zidongchaliuliang(){
        xiancheng({
            if let data = NSUserDefaults(suiteName: "data")
            {
                let zdc = data.integerForKey("zidongcha")
                if zdc != 0{
                    self.xiancheng({self.chaliuliang2()})
                }
            }
        })
    }
    
    @IBAction func duankai(sender: AnyObject) {
        print("断开中")
        let udp = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        do {
            try udp.connectToHost("192.168.8.8", onPort: 21099)
        } catch _ {
        }
        let cmd = Common.getcmd(1)
        let data = NSData(bytes: cmd, length: cmd.count)
        
        udp.sendData(data, withTimeout: 15, tag: 0)
        NSThread.sleepForTimeInterval(0.1)
        udp.sendData(data, withTimeout: 15, tag: 0)
        NSThread.sleepForTimeInterval(0.1)
        udp.sendData(data, withTimeout: 15, tag: 0)
        NSThread.sleepForTimeInterval(0.1)
        udp.sendData(data, withTimeout: 15, tag: 0)
        show("断开成功")
        always = false
        zhuangtai.image = NSImage(named: "shangwang_weilianjie.png")
        denglubutton.enabled = true
//        locationManager.stopUpdatingLocation()
        numtext.enabled = true
        pswtext.enabled = true
        
        xiancheng({
            sleep(1)
            self.zidongchaliuliang()
        })
    }
    
    func xiancheng(code:dispatch_block_t){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), code)
    }
    
    func ui(code:dispatch_block_t){
        dispatch_async(dispatch_get_main_queue(), code)
    }
    
    var delaytime:UInt32 = 10
    func baochi(){
        //        var udp = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        //        udp.connectToHost("192.168.8.8", onPort: 21099, error: nil)
        //        var err = NSErrorPointer()
        //        udp.bindToPort(21099, error: err)
        //        if err != nil{
        //            println(err.debugDescription)
        //        }
        //        udp.beginReceiving(nil)
        //
        //        while always{
        //            var cmd = getcmd(0)
        //            var data = NSData(UInt8s: cmd, length: cmd.count)
        //            sleep(30)
        //            udp.sendData(data, withTimeout: 30000, tag: 0)
        //            println("发送保持数据:\(t(cmd))")
        //        }
        
        let udpclient = UDPClient(addr: "192.168.8.8", port: 21099)
        while always{
            sleep(delaytime)
            let cmd = Common.getcmd(0)
            let data = NSData(bytes: cmd, length: cmd.count)
            let (success,errmsg) = udpclient.send(data: data)
            if success{
                delaytime = 10
                print("发送保持数据成功:\(Common.t(cmd))")
            }else {
                //一旦发送失败,加快发送速度
                delaytime = 2
                print("发送保持数据失败,原因: \(errmsg)")
            }
        }
    }
    
    func testonline(){
        while always{
            sleep(delaytime)
            let testclient = TCPClient(addr: "baidu.com", port: 80)
            let (success, error) = testclient.connect(timeout: 15)
            print("\(success),\(error)")
            testclient.close()
            if success == false{
                if always{
                    denglu2(true)
                }
            }
        }
    }
    
    func chaliuliang2(){
//        MobClick.event("chaliuliang")
        print("开始连接");
        let ip = oc().getIP()
        if ip != nil{
            let buf:[UInt8] = [0x7E,0x11,0x00,0x00,0x54,0x01,0x7E]
            var rec = [UInt8]()
            var trytime = 0
            repeat{
                repeat{
                    Common.connect()
                    Common.send(buf)
                    rec = Common.read()
                    rec = Common.fanzhuanyi(rec)
                    trytime++
                    print("第\(trytime)次")
                    if trytime > 20{
                        //show("查询流量失败")
                        red()
                        return
                    }
                    NSThread.sleepForTimeInterval(0.1)
                }while(rec.count != 23)
                
                if rec.count==23 {
                    Common.verify=[UInt8]()
                    for i in 0...15
                    {
                        Common.verify.append(rec[i+4])
                    }
                    print("获取到验证码:\(Common.t(Common.verify))")
                    let num = numtext.stringValue
                    let psw = pswtext.stringValue
                    var msg = Common.user_noip(num, psw: psw)
                    print("构造发送数据:\(Common.t(msg))")
                    msg = Common.feng(msg, cmd: 0x03)
                    msg = Common.zhuanyi(msg)
                    Common.send(msg)
                    rec = Common.read()
                }
            }while(rec.count == 0)
            
            Common.client.close()
            Common.jiefeng(rec)
            var regex: NSRegularExpression?
            do {
                regex = try NSRegularExpression(pattern: "(\\d+)兆", options: NSRegularExpressionOptions())
            } catch _ {
                regex = nil
            }
            var len = Common.recString.characters.count
            print(len)
            
            if len < 100{
                show(Common.recString)
            }
            else {
                let match = regex?.matchesInString(Common.recString, options: NSMatchingOptions(), range: NSMakeRange(0,len))
                var liuliang = 0
                for a in match!{
                    let range = NSMakeRange(a.range.location, a.range.length-1)
                    let tmp = (Common.recString as NSString).substringWithRange(range)
                    if let temp = Int(tmp){
                        liuliang+=temp
                    }
                }
                print(liuliang)
                
                let data = NSUserDefaults(suiteName: "data")
                data?.setObject(self.numtext.stringValue, forKey: "num")
                data?.setObject(self.pswtext.stringValue, forKey: "psw")
                
                self.liulianglabel.stringValue="\(liuliang)M"
                
                self.yellow()
                
                do {
                    regex = try NSRegularExpression(pattern: "在线:\\d+", options: NSRegularExpressionOptions())
                } catch _ {
                    regex = nil
                }
                len = Common.recString.characters.count
                if let tmp = regex?.firstMatchInString(Common.recString, options: NSMatchingOptions(), range: NSMakeRange(0,len)){
                    let range = NSMakeRange(tmp.range.location+3, tmp.range.length-3)
                    let tmp2 = (Common.recString as NSString).substringWithRange(range)
                    self.zaixianlabel.stringValue=tmp2
                }
                
                if let data = NSUserDefaults(suiteName: "data"){
                    data.setObject(liulianglabel.stringValue, forKey: "liuliang")
                    data.setObject(zaixianlabel.stringValue, forKey: "zaixian")
                }
            }
            
        }else {
            red()
        }
        
    }
    
    @IBAction func chaliuliang(sender: AnyObject) {
        xiancheng({
            self.chaliuliang2()
        })
    }
    
    @IBOutlet weak var showtext: NSTextField!
    
    func show(show:String){
        ui({
            self.showtext.stringValue = show
        })
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func force(sender: AnyObject) {
        xiancheng({
            self.force2()
        })
    }
    
    func force2(){
        let mypost = oc()
        let rec = mypost.iPOSTwithurl("http://self.btbu.edu.cn/cgi-bin/nacgi.cgi", withpost: "textfield=" + numtext.stringValue+"&textfield2=" + pswtext.stringValue + "&Submit=%CC%E1%BD%BB&nacgicmd=9&radio=1&jsidx=1")
        print(rec)
        if (rec.rangeOfString("成功断开本帐号的当前的所有连接") != nil){
            print("成功断开本帐号的当前的所有连接")
            show("成功断开本帐号的当前的所有连接")
        }else{
            print("断开失败")
            show("断开失败")
        }
    }

    @IBAction func showpsw(sender: AnyObject) {
        showtext.stringValue = pswtext.stringValue
    }

}

