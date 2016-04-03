//
//  csv.swift
//  CSV
//
//  Created by Gavi Narra on 5/2/15.
//  Copyright (c) 2015 ObjectGraph LLC. All rights reserved.
//

import Foundation

enum Quoting{
    case Minimal,All,NonNumeric,None;
}

struct Dialect: CustomStringConvertible{
    
    static let Unix:Dialect = Dialect()
    static let Excel:Dialect = Dialect(delimiter:",",lineterminator:"\r\n",quoteCharacter:"\"")
    static let ExcelTab:Dialect = Dialect(delimiter:"\t",lineterminator:"\r\n",quoteCharacter:"\"")
    
    
    var delimiter:String
    var lineTerminator:String
    var quoteCharacter:String
    var escapeCharacter:Character?
    
    init(){
        self.delimiter=","
        self.lineTerminator="\n"
        self.quoteCharacter=""
        self.escapeCharacter=nil
    }
    
    init(delimiter:String,lineterminator:String,quoteCharacter:String){
        self.delimiter=delimiter
        self.lineTerminator=lineterminator
        self.quoteCharacter=quoteCharacter
        self.escapeCharacter=nil
    }
    
    var description:String{
        let term:String=self.lineTerminator.stringByReplacingOccurrencesOfString("\n", withString: "\\n", options: NSStringCompareOptions.LiteralSearch, range: nil)
            .stringByReplacingOccurrencesOfString("\r", withString: "\\r", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let delim:String=self.delimiter.stringByReplacingOccurrencesOfString("\t", withString: "\\t", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return "Delimiter: \(delim) \nLine Term: \(term)"
    }
    
}


struct DictReader{
    var fileHandle:NSFileHandle!
    var encoding:UInt!
    var quoteCharacter:NSString!
    var buffer:NSMutableData!
    var newLineData:NSData!
    var chunkSize:Int!
    var colNames=[String]()
    var dialect:Dialect
    
    init(file:String,encoding:UInt=NSUTF8StringEncoding,dialect:Dialect=Dialect(),firstRowColNames:Bool=true){
        if let fileHandle=NSFileHandle(forReadingAtPath: file){
            self.fileHandle=fileHandle
            
        }
        self.dialect=dialect
        self.encoding=encoding
        self.chunkSize=4096
        self.buffer=NSMutableData(capacity: self.chunkSize)
        self.newLineData=(dialect.lineTerminator as NSString!).dataUsingEncoding(encoding)
        if let line=rawReadLine(){
            let tmp=line.componentsSeparatedByString(dialect.delimiter)
            if(firstRowColNames){
                self.colNames=tmp
            }else{
                for i in 0 ..< tmp.count{
                    self.colNames.append("Var\(i+1)")
                }
                //reset the buffer
                fileHandle.seekToFileOffset(0)
                buffer.length=0
            }
        }
    
    }
    
    func rawReadLine()->String?{
        var range=buffer.rangeOfData(newLineData, options: [], range: NSMakeRange(0, buffer.length))
        while(range.location==NSNotFound){
            //Load the buffer
            let tmpData=fileHandle.readDataOfLength(chunkSize)
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
            range=buffer.rangeOfData(newLineData, options: [], range: NSMakeRange(0, buffer.length))
            
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
            let tmp=line.componentsSeparatedByString(dialect.delimiter)
            for i in 0 ..< colNames.count{
                dict[colNames[i]]=tmp[i]
            }
            return dict
        }
        return nil
    }
    
}


extension DictReader : SequenceType {
    func generate() -> AnyGenerator<Dictionary<String,String>> {
        return AnyGenerator {
            return self.readLine()
        }
    }
}
