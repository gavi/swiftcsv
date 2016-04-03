//
//  main.swift
//  CSV
//
//  Created by Gavi Narra on 5/2/15.
//  Copyright (c) 2015 ObjectGraph LLC. All rights reserved.
//

import Foundation


func Test1(){
    let file="/Users/gavi/work/mac/CSV/CSV/test_files/excel_csv.csv"
    let dictReader=DictReader(file:file,firstRowColNames:true,dialect:Dialect.Excel)
    print(dictReader.colNames)

    while(true){
        if let x=dictReader.readLine(){
            print(x)
        }else{
            break
        }
    }

    for dict in dictReader{
        print(dict)
    }

}


print(Dialect.Excel)
//Test1()
