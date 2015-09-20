//
//  InfoSessionSourceHTMLParser.swift
//  FidoUsage
//
//  Created by Honghao Zhang on 2015-08-12.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation
import Ji

struct InfoSessionSourceHTMLParser {
//    let kEmployer = "Employer"
//    let kDate = "Date"
//    let kTime = "Time"
//    let kLocation = "Location"
//    let kWebSite = "Web Site"
//    let kAudience = "Audience"
//    let kProgram = "Program"
//    let kDescription = "Description"
//    let kId = "id"
//    
//    var result = [String: AnyObject]()
//    
//    func parserHTMLString(string: String) {
//        log.debug("Parsing")
//        
//        let doc: Ji! = Ji(htmlString: string)
//        if doc == nil {
//            log.error("Setup Ji doc failed")
//        }
//        
//        let nodes = doc.xPath("//*[@id='tableform']")
//        if let tableNode = nodes?.first where tableNode.name == "table" {
//            // Divide trs into different sessions
//            // Each session is a list of tr Ji node
//            var trSessionGroups = [[JiNode]]()
//            var trSessionGroup: [JiNode]?
//            for tr in tableNode {
//                if var tdContent = tr.firstChildWithName("td")?.content {
//                    if tdContent.hasPrefix("\(kEmployer):") {
//                        if let trSessionGroup = trSessionGroup { trSessionGroups.append(trSessionGroup) }
//                        trSessionGroup = [tr]
//                        continue
//                    }
//                    trSessionGroup!.append(tr)
//                }
//            }
//            
//            // Process each session group to a dictionary
//            let json = JSON(trSessionGroups.map { self.processTrSessionGroupToDict($0) })
//            log.debug(json)
//        }
//    }
//    
//    private func processTrSessionGroupToDict(trSession: [JiNode]) -> [[String: String]] {
//        var result = [[String: String]]()
//        
//        var webSiteIndex: Int?
//        for (index, tr) in enumerate(trSession) {
//            if let firstString = tr.firstChild?.content?.trimmed() where firstString.hasPrefix("\(kEmployer):") {
//                let secondString = tr.firstChild?.nextSibling?.content?.trimmed()
//                result.append([kEmployer: secondString ?? "null"])
//            } else if let firstString = tr.firstChild?.content?.trimmed() where firstString.hasPrefix("\(kDate):") {
//                let secondString = tr.firstChild?.nextSibling?.content?.trimmed()
//                result.append([kDate: secondString ?? "null"])
//            } else if let firstString = tr.firstChild?.content?.trimmed() where firstString.hasPrefix("\(kTime):") {
//                let secondString = tr.firstChild?.nextSibling?.content?.trimmed()
//                result.append([kTime: secondString ?? "null"])
//            } else if let firstString = tr.firstChild?.content?.trimmed() where firstString.hasPrefix("\(kLocation):") {
//                let secondString = tr.firstChild?.nextSibling?.content?.trimmed()
//                result.append([kLocation: secondString ?? "null"])
//            } else if let firstString = tr.firstChild?.content?.trimmed() where firstString.hasPrefix("\(kWebSite):") {
//                var secondString = tr.firstChild?.nextSibling?.content?.trimmed()
//                if secondString == "http://" { secondString = "" }
//                result.append([kWebSite: secondString ?? "null"])
//                webSiteIndex = index
//            }
//            else if let webSiteIndex = webSiteIndex where index == webSiteIndex + 1 {
//                // Audience + Programs
//                if let rawContent = tr.xPath("./td/i").first?.rawContent?.replaceMatches("<(i|/i)>", withString: "", ignoreCase: false) {
//                    let components = rawContent.componentsSeparatedByString("<br>")
//                    if components.count == 3 {
//                        let levelString = (components[0].hasPrefix("For ") ? components[0].stringByReplacingOccurrencesOfString("For ", withString: "", options: NSStringCompareOptions(0), range: nil) : components[0]).trimmed()
//                        let studentString = components[1].replaceMatches(", ", withString: ",", ignoreCase: true)?.stringByReplacingOccurrencesOfString(",", withString: ", ", options: NSStringCompareOptions(0), range: nil).trimmed() ?? ""
//                        let programString = components[2].trimmed()
//                        result.append([kAudience: "\(levelString) \(studentString)".trimmed()])
//                        result.append([kProgram: programString])
//                    } else {
//                        log.error("Parsing Audient and Program failed.")
//                    }
//                } else {
//                    log.error("Get raw text for Audience failed.")
//                }
//            } else if let webSiteIndex = webSiteIndex where index == webSiteIndex + 2 {
//                // Description
//                if let rawContent = tr.xPath("./td/i").first?.rawContent?.replaceMatches("<(i|/i)>", withString: "", ignoreCase: false) {
//                    let removedBrString = rawContent.stringByReplacingOccurrencesOfString("<br>", withString: "\n", options: NSStringCompareOptions(0), range: nil)
//                    result.append([kDescription: removedBrString])
//                } else {
//                    log.error("Get raw text for Audience failed.")
//                }
//            }
//        }
//        
//        return result
//    }
}
