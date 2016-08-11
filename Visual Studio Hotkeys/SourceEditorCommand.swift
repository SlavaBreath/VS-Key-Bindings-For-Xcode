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
		
		
		
//		for selection in invocation.buffer.selections {
//			
//			// Case when nothing is selected
//			if selection.start.line == selection.end.line, selection.start.column == selection.end.column {
//				let line = selection.start.line
//				
//				if command == .commentCommand {
//					let newLine = "//" + (invocation.buffer.lines[line] as! String)
//					invocation.buffer.lines[line] = newLine
//				} else if command == .uncommentCommand {
//					var oldLine = invocation.buffer.lines[line] as! String
//					if oldLine.hasPrefix("//") {
//						oldLine.characters.removeFirst(2)
//						invocation.buffer.lines[line] = oldLine
//					} else if oldLine.hasPrefix("/*"), oldLine.hasSuffix("*/") {
//						oldLine.characters.removeFirst(2)
//						oldLine.characters.removeLast(2)
//						invocation.buffer.lines[line] = oldLine
//					}
//				}
//				break
//			}
//			
//			var firstLine = invocation.buffer.lines[selection.start.line] as! String
//			var lastLine = invocation.buffer.lines[selection.end.line] as! String
//			let sameLine = firstLine == lastLine
//			
//			if command == .commentCommand {
//				var index = lastLine.index(lastLine.startIndex, offsetBy: selection.end.column + 1)
//				lastLine.insert(contentsOf: "*/".characters, at: index)
//				
//				if sameLine {
//					firstLine = lastLine
//				}
//				index = firstLine.index(firstLine.startIndex, offsetBy: selection.start.column)
//				firstLine.insert(contentsOf: "/*".characters, at: index)
//				
//				invocation.buffer.lines[selection.start.line] = firstLine
//				if !sameLine {
//					invocation.buffer.lines[selection.end.line] = lastLine
//				}
//				
//				(selection as! XCSourceTextRange).end.column += 5
//			} else if command == .uncommentCommand {
//				if sameLine {
//					if selection.end.column - selection.start.column >= 4 {
//						var index = firstLine.index(firstLine.startIndex, offsetBy: selection.end.column)
//						firstLine.removeSubrange(firstLine.index(before: index)...index)
//						
//						index = firstLine.index(firstLine.startIndex, offsetBy: selection.start.column)
//						firstLine.removeSubrange(index...firstLine.index(after: index))
//						
//						invocation.buffer.lines[selection.start.line] = firstLine
//					}
//				}
//				
//				(selection as! XCSourceTextRange).end.column -= 3
//			}
//		}
		
        completionHandler(nil)
    }
	
	// MARK: - Private functions
	
	private func commentCommand(for invocation: XCSourceEditorCommandInvocation) {
		
		// First check for not selected text
		let selection = invocation.buffer.selections.firstObject as! XCSourceTextRange
		if selection.start.line == selection.end.line, selection.start.column == selection.end.column {
			var line = invocation.buffer.lines[selection.start.line] as! String
			if let index = line.characters.index(where: { (c) -> Bool in
				return c != "\t" && c != " " && c != "\n"
			}) {
				line.insert(contentsOf: "//".characters, at: index)
				invocation.buffer.lines[selection.start.line] = line
			}
			return
		}
	}
	
	private func uncommentCommand(for invocation: XCSourceEditorCommandInvocation) {
		// First check for not selected text
		let selection = invocation.buffer.selections.firstObject as! XCSourceTextRange
		if selection.start.line == selection.end.line, selection.start.column == selection.end.column {
			var line = invocation.buffer.lines[selection.start.line] as! String
			if let index = line.characters.index(of: "/") {
				if index == line.startIndex, line.hasSuffix("//") {
					line.characters.removeFirst(2)
					
					invocation.buffer.lines[selection.start.line] = line
				} else {
					let preLine = line[line.index(before: index)]
					let secondSlash = line[line.index(after: index)]
					if (preLine == "\t" || preLine == " ") && secondSlash == "/" {
						line.characters.removeSubrange(index...line.index(after: index))
						
						invocation.buffer.lines[selection.start.line] = line
					}
				}
			}
			return
		}
	}
	
}
