//
//  main.swift
//  CSV
//
//  Created by Gavi Narra on 5/2/15.
//  Copyright (c) 2015 ObjectGraph LLC. All rights reserved.
//

import Foundation

class DictReader{
    var fileHandle:NSFileHandle!
    var encoding:UInt!
    var delimiter:NSString!
    var buffer:NSMutableData!
    var newLineData:NSData!
    var chunkSize:Int!
    var colNames=[String]()
    
    init(file:String,encoding:UInt=NSUTF8StringEncoding,delimiter:String=",",newline:String="\n",firstRowColNames:Bool=true){
        if let fileHandle=NSFileHandle(forReadingAtPath: file){
            self.fileHandle=fileHandle
            
        }
        self.encoding=encoding
        self.chunkSize=4096
        self.buffer=NSMutableData(capacity: self.chunkSize)
        self.newLineData=newline.dataUsingEncoding(encoding)
        self.delimiter=delimiter
        if let line=rawReadLine(){
            let tmp=line.componentsSeparatedByString(delimiter)
            if(firstRowColNames){
                self.colNames=tmp
            }else{
                for (var i=0;i<tmp.count;i++){
                    self.colNames.append("Var\(i+1)")
                }
                //reset the buffer
                fileHandle.seekToFileOffset(0)
                buffer.length=0
            }
        }
    
    }
    
    func rawReadLine()->String?{
        var range=buffer.rangeOfData(newLineData, options: nil, range: NSMakeRange(0, buffer.length))
        while(range.location==NSNotFound){
            //Load the buffer
            var tmpData=fileHandle.readDataOfLength(chunkSize)
            if tmpData.length==0{
                if buffer.length>0{
                    //Send the remaining buffer back
                    let line = NSString(data:buffer, encoding:encoding)
                    buffer.length=0
                    
                    return line as String?
                }
                return nil
            }
            buffer.appendData(tmpData)
            range=buffer.rangeOfData(newLineData, options: nil, range: NSMakeRange(0, buffer.length))
            
        }
        //At this point its is found
        
        let line=NSString(data:buffer.subdataWithRange(NSMakeRange(0, range.location)), encoding:encoding)
        
        //Remove the buffer
        
        buffer.replaceBytesInRange(NSMakeRange(0, range.location+range.length), withBytes: nil,length:0)
        return line as String?
        
    }
    
    func readLine()->Dictionary<String,String>?{
        if let line=rawReadLine(){
            var dict=[String:String]()
            let tmp=line.componentsSeparatedByString(delimiter! as String)
            for (var i=0;i<colNames.count;i++){
                dict[colNames[i]]=tmp[i]
            }
            return dict
        }
        return nil
    }
    
    
}
