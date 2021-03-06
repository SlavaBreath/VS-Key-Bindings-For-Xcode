//
//  SourceEditorCommand.swift
//  Visual Studio Hotkeys
//
//  Created by Vyacheslav Nagornyak on 8/10/16.
//  Copyright © 2016 Vyacheslav Nagornyak. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
	
	enum Command: String {
		case commentCommand = "com.breath.VS-Key-Bindings-For-Xcode.Visual-Studio-Hotkeys.CommentCommand"
		case uncommentCommand = "com.breath.VS-Key-Bindings-For-Xcode.Visual-Studio-Hotkeys.UncommentCommand"
	}
	
	// XCSourceEditorCommand
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
		
		switch Command(rawValue: invocation.commandIdentifier)! {
		case .commentCommand:
			commentCommand(for: invocation)
			break
			
		case .uncommentCommand:
			uncommentCommand(for: invocation)
			break
		}
		
        completionHandler(nil)
    }
	
	// MARK: - Private functions
	
	private func commentCommand(for invocation: XCSourceEditorCommandInvocation) {
		
		// First check for not selected text
		let singleSelection = invocation.buffer.selections.firstObject as! XCSourceTextRange
		if singleSelection.start.line == singleSelection.end.line, singleSelection.start.column == singleSelection.end.column {
			var line = invocation.buffer.lines[singleSelection.start.line] as! String
			if let index = line.characters.index(where: { (c) -> Bool in
				return c != "\t" && c != " " && c != "\n"
			}) {
				line.insert(contentsOf: "//".characters, at: index)
				
				invocation.buffer.lines[singleSelection.start.line] = line
				singleSelection.start.column = line.distance(from: line.startIndex, to: index)
				singleSelection.end = singleSelection.start
			}
			return
		}
		
		for selection in invocation.buffer.selections {
			var firstLine = invocation.buffer.lines[selection.start.line] as! String
			var lastLine = invocation.buffer.lines[selection.end.line] as! String
			let sameLine = firstLine == lastLine
			
			var lastIndex = lastLine.index(lastLine.startIndex, offsetBy: selection.end.column)
			if lastLine[lastIndex] != "\n" {
				lastIndex = lastLine.index(after: lastIndex)
			}
			lastLine.characters.insert(contentsOf: "*/".characters, at: lastIndex)
			
			if sameLine {
				firstLine = lastLine
			}
			
			var startIndex = firstLine.index(firstLine.startIndex, offsetBy: selection.start.column)
			let startLineIndex = firstLine.characters.index(where: { (c) -> Bool in
				return c != "\t" && c != " " && c != "\n"
			})
			
			if let index = startLineIndex, index > startIndex {
				startIndex = index
			}
			
			firstLine.characters.insert(contentsOf: "/*".characters, at: startIndex)
			
			if sameLine {
				invocation.buffer.lines[selection.start.line] = firstLine
				
				(selection as! XCSourceTextRange).end.column = firstLine.distance(from: firstLine.startIndex, to: lastIndex) + 4
			} else {
				invocation.buffer.lines[selection.start.line] = firstLine
				invocation.buffer.lines[selection.end.line] = lastLine
				
				(selection as! XCSourceTextRange).end.column = lastLine.distance(from: lastLine.startIndex, to: lastIndex) + 2
			}
			
			(selection as! XCSourceTextRange).start.column = firstLine.distance(from: firstLine.startIndex, to: startIndex)
		}
	}
	
	private func uncommentCommand(for invocation: XCSourceEditorCommandInvocation) {
		// First check for not selected text
		let singleSelection = invocation.buffer.selections.firstObject as! XCSourceTextRange
		if singleSelection.start.line == singleSelection.end.line, singleSelection.start.column == singleSelection.end.column {
			var line = invocation.buffer.lines[singleSelection.start.line] as! String
			if let index = line.characters.index(of: "/") {
				if index == line.startIndex, line.hasSuffix("//") {
					line.characters.removeFirst(2)
					
					invocation.buffer.lines[singleSelection.start.line] = line
					singleSelection.start.column = 0
					singleSelection.end = singleSelection.start
				} else {
					let preLine = line[line.index(before: index)]
					let secondSlash = line[line.index(after: index)]
					if (preLine == "\t" || preLine == " ") && secondSlash == "/" {
						line.characters.removeSubrange(index...line.index(after: index))
						
						invocation.buffer.lines[singleSelection.start.line] = line
						singleSelection.start.column = line.distance(from: line.startIndex, to: index)
						singleSelection.end = singleSelection.start
					}
				}
			}
			return
		}
		
		for selection in invocation.buffer.selections {
			var firstLine = invocation.buffer.lines[selection.start.line] as! String
			var lastLine = invocation.buffer.lines[selection.end.line] as! String
			let sameLine = firstLine == lastLine
			var firstChanged = false
			var lastChanged = false
			
			var startIndex = firstLine.index(firstLine.startIndex, offsetBy: selection.start.column)
			let startLineIndex: String.Index? = firstLine.characters.index(where: { (c) -> Bool in
				return c != "\t" && c != " " && c != "\n"
			})
			if let index = startLineIndex, index > startIndex {
				startIndex = index
			}
			
			if firstLine[startIndex] == "/" && firstLine[firstLine.index(after: startIndex)] == "*" {
				firstChanged = true
			}
			
			let endIndex = lastLine.index(lastLine.startIndex, offsetBy: selection.end.column)
			if lastLine[endIndex] == "/" && lastLine[lastLine.index(before: endIndex)] == "*" {
				lastChanged = true
			}
			
			if firstChanged && lastChanged {
				lastLine.characters.removeSubrange(lastLine.index(before: endIndex)...endIndex)
				if sameLine {
					firstLine = lastLine
				}
				firstLine.characters.removeSubrange(startIndex...firstLine.index(after: startIndex))
				
				if sameLine {
					invocation.buffer.lines[selection.start.line] = firstLine
					
					(selection as! XCSourceTextRange).end.column = lastLine.distance(from: lastLine.startIndex, to: endIndex) - 3
				} else {
					invocation.buffer.lines[selection.start.line] = firstLine
					invocation.buffer.lines[selection.end.line] = lastLine
					
					(selection as! XCSourceTextRange).end.column = lastLine.distance(from: lastLine.startIndex, to: endIndex) - 1
				}
				
				(selection as! XCSourceTextRange).start.column = firstLine.distance(from: firstLine.startIndex, to: startIndex)
			}
		}
	}
	
}
