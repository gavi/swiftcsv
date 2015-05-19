//
//  main.swift
//  CSV
//
//  Created by Gavi Narra on 5/2/15.
//  Copyright (c) 2015 ObjectGraph LLC. All rights reserved.
//

import Foundation

let file="/Users/gavi/work/R/capstone/ugram.csv"
let dictReader=DictReader(file:file,firstRowColNames:false)
println(dictReader.colNames)

/*
while(true){
    if let x=dictReader.readLine(){
        println(x)
    }else{
        break
    }
}

*/

for dict in dictReader{
    println(dict)
}