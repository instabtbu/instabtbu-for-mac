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
                var zdc = data.integerForKey("zidongcha")
                var zddl = data.integerForKey("zidongdenglu")
                if zdc != 0 {
                    zidongchaliuliang()
                }
                if zddl != 0 {
                    xiancheng({self.denglu2()})
                }
                refreshzidong()
            }
        }
        showtext.becomeFirstResponder()
    }

    func refreshzidong(){
        if let data = NSUserDefaults(suiteName: "data")
        {
            var zdc = data.integerForKey("zidongcha")
            var zddl = data.integerForKey("zidongdenglu")
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
        denglu2()
    }
    
    func denglu2(){
        var ip = oc().getIP()
        if ip != nil{
            var buf:[Byte] = [0x7E,0x11,0x00,0x00,0x54,0x01,0x7E]
            var trytime = 0
            var rec = [Byte]()
            
            do{
                do
                {
                    connect()
                    send(buf)
                    rec = read()
                    rec=fanzhuanyi(rec)
                    trytime++
                    print("第\(trytime)次")
                    if trytime > 10{
                        show("登录失败")
                        return
                    }
                }while(rec.count != 23)
                
                if rec.count==23 {
                    verify=[Byte]()
                    for i in 0...15
                    {
                        verify.append(rec[i+4])
                    }
                    print("获取到验证码:\(t(verify))")
                    var msg = user(numtext.stringValue, psw: pswtext.stringValue)
                    msg=feng(msg, cmd: 0x01)
                    msg=zhuanyi(msg)
                    send(msg)
                    rec = read()
                }
            }while(rec.count == 0)
            
            client.close()
            if jiefeng(rec){
                print("保持在线数据:\(t(remain))")
                ui({
                    if let data = NSUserDefaults(suiteName: "data"){
                        data.setObject(self.numtext.stringValue, forKey: "num")
                        data.setObject(self.pswtext.stringValue, forKey: "psw")
                    }
                    self.numtext.enabled=false
                    self.pswtext.enabled=false
                    self.denglubutton.enabled=false
                    self.zhuangtai.image=NSImage(named: "zhuangtai1")
                    self.zidongchaliuliang()
                })
                always = true
                xiancheng({
                    self.baochi()
                })
            }else {
                show(recString)
                print(recString)
            }
        }else {
            show("获取数据出错");
        }
        
    }
    var always = false
    
    func zidongchaliuliang(){
        xiancheng({
            if let data = NSUserDefaults(suiteName: "data")
            {
                var zdc = data.integerForKey("zidongcha")
                if zdc != 0{
                    self.xiancheng({self.chaliuliang2()})
                }
            }
        })
    }
    
    @IBAction func duankai(sender: AnyObject) {
        print("断开中")
        var udp = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        udp.connectToHost("192.168.8.8", onPort: 21099, error: nil)
        udp.bindToPort(21099, error: nil)
        udp.beginReceiving(nil)
        var cmd = getcmd(1)
        var data = NSData(bytes: cmd, length: cmd.count)
        udp.sendData(data, withTimeout: 15, tag: 0)
        NSThread.sleepForTimeInterval(0.05)
        udp.sendData(data, withTimeout: 15, tag: 0)
        NSThread.sleepForTimeInterval(0.05)
        udp.sendData(data, withTimeout: 15, tag: 0)
        NSThread.sleepForTimeInterval(0.05)
        udp.sendData(data, withTimeout: 15, tag: 0)
        always = false
        self.numtext.enabled=true
        self.pswtext.enabled=true
        self.denglubutton.enabled=true
        self.zhuangtai.image=NSImage(named: "zhuangtai0")
        xiancheng({
            sleep(1)
            self.zidongchaliuliang()
        })
        print("已断开")
    }
    
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        var rec = [Byte](count:27,repeatedValue:0x0)
        data.getBytes(&rec)
        print("收到保持数据:\(t(rec))")
    }
    
    func xiancheng(code:dispatch_block_t){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), code)
    }
    func ui(code:dispatch_block_t){
        dispatch_async(dispatch_get_main_queue(), code)
    }
    
    func baochi(){
        var udp = GCDAsyncUdpSocket(delegate: self,delegateQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        udp.connectToHost("192.168.8.8", onPort: 21099, error: nil)
        while always{
            var cmd = getcmd(0)
            var data = NSData(bytes: cmd, length: cmd.count)
            udp.sendData(data, withTimeout: 15000, tag: 0)
            print("发送保持数据:\(t(cmd))")
            sleep(15)
        }
    }
    
    
    func chaliuliang2(){
        print("开始连接");
        var ip = oc().getIP()
        if ip != nil{
            var buf:[Byte] = [0x7E,0x11,0x00,0x00,0x54,0x01,0x7E]
            var rec = [Byte]()
            var trytime = 0
            do{
                do{
                    connect()
                    send(buf)
                    rec = read()
                    rec=fanzhuanyi(rec)
                    trytime++
                    print("第\(trytime)次")
                    if trytime > 10{
                        show("查询流量失败")
                        return
                    }
                }while(rec.count != 23)
                
                if rec.count==23 {
                    verify=[Byte]()
                    for i in 0...15
                    {
                        verify.append(rec[i+4])
                    }
                    print("获取到验证码:\(t(verify))")
                    var num = numtext.stringValue
                    var psw = pswtext.stringValue
                    var msg = user_noip(num, psw: psw)
                    print("构造发送数据:\(t(msg))")
                    msg=feng(msg, cmd: 0x03)
                    msg=zhuanyi(msg)
                    send(msg)
                    rec = read()
                }
            }while(rec.count == 0)
            
            client.close()
            jiefeng(rec)
            var regex = NSRegularExpression(pattern: "(\\d+)兆", options: NSRegularExpressionOptions.allZeros, error: nil)
            var len = countElements(recString)
            var match = regex?.matchesInString(recString, options: NSMatchingOptions.allZeros, range: NSMakeRange(0,len))
            var liuliang = 0
            for a in match!{
                let range = NSMakeRange(a.range.location, a.range.length-1)
                let tmp = (recString as NSString).substringWithRange(range)
                if let temp = tmp.toInt(){
                    liuliang+=temp
                }
            }
            self.liulianglabel.stringValue="\(liuliang)M"
            xiancheng({
                var color = NSColor(red: 1, green: 1, blue: 0, alpha: 1)
                self.liulianglabel.textColor=color
                self.zaixianlabel.textColor=color
                NSThread.sleepForTimeInterval(0.02)
                for var i:CGFloat=0;i<255;i+=5{
                    var color = NSColor(red: 1, green: 1, blue: i/255, alpha: 1)
                    self.ui({
                        self.liulianglabel.textColor=color
                        self.zaixianlabel.textColor=color
                    })
                    NSThread.sleepForTimeInterval(0.02)
                }
                
            })
            
            
            
            regex = NSRegularExpression(pattern: "在线:\\d+", options: NSRegularExpressionOptions.allZeros, error: nil)
            len = countElements(recString)
            if let tmp = regex?.firstMatchInString(recString, options: NSMatchingOptions.allZeros, range: NSMakeRange(0,len)){
                let range = NSMakeRange(tmp.range.location+3, tmp.range.length-3)
                let tmp2 = (recString as NSString).substringWithRange(range)
                self.zaixianlabel.stringValue=tmp2
            }
            
            if let data = NSUserDefaults(suiteName: "data"){
                data.setObject(liulianglabel.stringValue, forKey: "liuliang")
                data.setObject(zaixianlabel.stringValue, forKey: "zaixian")
            }
            
        }else {
            show("获取数据出错");
        }
        
        
    }
    
    @IBAction func chaliuliang(sender: AnyObject) {
        chaliuliang2()
    }
    
    var verify:[Byte] = []
    var remain:[Byte] = []
    var recString:String = ""
    
    func jiami(buf:[Byte])->[Byte]{
        var re:[UInt8] = [UInt8](count:128,repeatedValue:0x0)
        rsajiami(buf,CInt(countElements(buf)),&re)
        return re
    }
    
    func jiefeng(buf:[Byte])->Bool{
        var buf2 = fanzhuanyi(buf)
        var len1 = Int(buf[2])
        var len2 = Int(buf[3])*256
        var len = len1+len2
        var f = false
        var re = [Byte]()
        for var i=0;i<Int(len);i=i+1{
            re.append(buf2[i+4])
        }
        
        if buf[1]==1 {
            remain = [UInt8](count:20,repeatedValue:0x0)
            rsajiemi(re,&remain)
            f=true
        }else{
            var data = NSData(bytes: &re, length: re.count)
            if let rec = oc().gb2312(data){
                recString = rec
                print("返回文本:\(recString)")
            }else{
                print("转码失败")
            }
        }
        
        return f
    }
    
    func feng(buf:[Byte],cmd:Int)->[Byte]{
        var jiamibytes = jiami(buf)
        var crcbytes = [Byte(cmd),Byte(jiamibytes.count&0xff),Byte(jiamibytes.count>>8)] + jiamibytes
        var crc = getCRC16(crcbytes)
        crcbytes = [Byte(0x7E)] + crcbytes + [Byte(crc&0xFF),Byte(crc>>8),Byte(0x7E)]
        return crcbytes
    }
    
    func getcmd(cmd:Int)->[Byte]{
        if remain.count==20 {
            var re:[Byte] = [Byte(cmd),0x14,0x00]+remain
            var crc = getCRC16(re)
            re=[0x7E]+re+[Byte(crc&0xFF),Byte(crc>>8),Byte(0x7E)]
            return re
        }else{
            return []
        }
    }
    
    func user(num:String,psw:String)->[Byte]{
        var msg = [Byte](count: 82, repeatedValue: 0)
        var ip = oc().getIP();
        var i = 0
        for c in num.cStringUsingEncoding(NSASCIIStringEncoding)!{
            msg[i]=Byte(c)
            i++
        }
        i=23
        for c in psw.cStringUsingEncoding(NSASCIIStringEncoding)!{
            msg[i]=Byte(c)
            i++
        }
        i=23+23
        for c in ip.cStringUsingEncoding(NSASCIIStringEncoding)!{
            msg[i]=Byte(c)
            i++
        }
        i=23+23+20
        for c in verify{
            msg[i]=Byte(c)
            i++
        }
        return msg;
    }
    
    func user_noip(num:String , psw:String)->[Byte]{
        var msg = [Byte](count: 62, repeatedValue: 0)
        var ip = oc().getIP();
        var i = 0
        for c in num.cStringUsingEncoding(NSASCIIStringEncoding)!{
            msg[i]=Byte(c)
            i++
        }
        i=23
        for c in psw.cStringUsingEncoding(NSASCIIStringEncoding)!{
            msg[i]=Byte(c)
            i++
        }
        for i in 0..<verify.count{
            msg[i+23+23]=verify[i]
        }
        return msg;
    }
    
    func zhuanyi(buf:[Byte])->[Byte]{
        var re = [Byte]()
        re.append(0x7E)
        for var i=1;i<buf.count-1;i++ {
            if buf[i]==0x7D||buf[i]==0x7E{
                re.append(0x7D)
                re.append(buf[i]^0x40)
            }else {
                re.append(buf[i])
            }
        }
        re.append(0x7E)
        return re;
    }
    
    func fanzhuanyi(buf:[Byte])->[Byte]{
        var re = [Byte]()
        for var i=0;i<buf.count;i++ {
            if buf[i]==0x7D{
                re.append(buf[++i]^0x40)
            }else {
                re.append(buf[i])
            }
        }
        return re;
    }
    
    func getCRC16(bytes:[Byte])->Int{
        var table = [0x0000,0x8005,0x800F,0x000A,0x801B,0x001E,0x0014,0x8011,0x8033,0x0036,0x003C,0x8039,0x0028,0x802D,0x8027,
            0x0022,0x8063,0x0066,0x006C,0x8069,0x0078,0x807D,0x8077,0x0072,0x0050,0x8055,0x805F,0x005A,0x804B,0x004E,0x0044,
            0x8041,0x80C3,0x00C6,0x00CC,0x80C9,0x00D8,0x80DD,0x80D7,0x00D2,0x00F0,0x80F5,0x80FF,0x00FA,0x80EB,0x00EE,0x00E4,
            0x80E1, 0x00A0,0x80A5,0x80AF,0x00AA,0x80BB,0x00BE,0x00B4,0x80B1,0x8093,0x0096,0x009C,0x8099,0x0088,0x808D,0x8087,
            0x0082,0x8183,0x0186,0x018C,0x8189,0x0198,0x819D,0x8197,0x0192,0x01B0,0x81B5,0x81BF,0x01BA,0x81AB,0x01AE,0x01A4,
            0x81A1,0x01E0,0x81E5,0x81EF,0x01EA,0x81FB,0x01FE,0x01F4,0x81F1,0x81D3,0x01D6,0x01DC,0x81D9,0x01C8,0x81CD,0x81C7,
            0x01C2,0x0140,0x8145,0x814F,0x014A,0x815B,0x015E,0x0154,0x8151,0x8173,0x0176,0x017C,0x8179,0x0168,0x816D,0x8167,
            0x0162,0x8123,0x0126,0x012C,0x8129,0x0138,0x813D,0x8137,0x0132,0x0110,0x8115,0x811F,0x011A,0x810B,0x010E,0x0104,
            0x8101,0x8303,0x0306,0x030C,0x8309,0x0318,0x831D,0x8317,0x0312,0x0330,0x8335,0x833F,0x033A,0x832B,0x032E,0x0324,
            0x8321,0x0360,0x8365,0x836F,0x036A,0x837B,0x037E,0x0374,0x8371,0x8353,0x0356,0x035C,0x8359,0x0348,0x834D,0x8347,
            0x0342,0x03C0,0x83C5,0x83CF,0x03CA,0x83DB,0x03DE,0x03D4,0x83D1,0x83F3,0x03F6,0x03FC,0x83F9,0x03E8,0x83ED,0x83E7,
            0x03E2,0x83A3,0x03A6,0x03AC,0x83A9,0x03B8,0x83BD,0x83B7,0x03B2,0x0390,0x8395,0x839F,0x039A,0x838B,0x038E,0x0384,
            0x8381,0x0280,0x8285,0x828F,0x028A,0x829B,0x029E,0x0294,0x8291,0x82B3,0x02B6,0x02BC,0x82B9,0x02A8,0x82AD,0x82A7,
            0x02A2,0x82E3,0x02E6,0x02EC,0x82E9,0x02F8,0x82FD,0x82F7,0x02F2,0x02D0,0x82D5,0x82DF,0x02DA,0x82CB,0x02CE,0x02C4,
            0x82C1,0x8243,0x0246,0x024C,0x8249,0x0258,0x825D,0x8257,0x0252,0x0270,0x8275,0x827F,0x027A,0x826B,0x026E,0x0264,
            0x8261,0x0220,0x8225,0x822F,0x022A,0x823B,0x023E,0x0234,0x8231,0x8213,0x0216,0x021C,0x8219,0x0208,0x820D,0x8207,
            0x0202]
        var i = 0;
        var len = bytes.count;
        var crc = 0;
        while(i<len){
            var index = Byte(crc>>8)^bytes[i++];
            if(index<0){
                index+=Int(256);
            }
            crc = ((crc&0xFF)<<8) ^ table[Int(index)]
        }
        return crc;
    }
    
    func t(buf:[Byte])->String{
        var re = ""
        for b in buf{
            re+=bts(b)+" "
        }
        re+=" 长度:\(buf.count)"
        return re
    }
    
    func bts(b:Byte)->String{
        var table = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
        return "\(table[Int(b/16)])\(table[Int(b%16)])"
    }
    
    var client = TCPClient(addr: "192.168.8.8", port: 21098)
    
    func connect()->Bool{
        var (success,error) = client.connect(timeout: 7)
        if !success{
        }
        print("连接服务器成功")
        return success
    }
    
    func send(buf:[Byte]){
        print("开始发送数据:\(t(buf))")
        let (succeed,error) = client.send(data: buf)
        if succeed{
            print("发送数据成功")
        }else{
            print("发送数据失败:\(error)")
        }
    }
    
    func read()->[Byte]{
        print("开始读取数据")
        if let re = client.read(1024*10){
            print("获取数据成功:\(t(re))")
            return re
        }else{
            print("获取数据失败")
            return []
        }
    }
    
    @IBOutlet var showtext: NSTextView!
    
    func show(show:String){
        ui({
            self.showtext.string = show
        })
    }

    func print(show:String){
        ui({
            self.showtext.string=show
        })
        println(show)
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

