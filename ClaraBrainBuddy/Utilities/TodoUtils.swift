//
//  Utilities/TodoUtilties.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 04.08.26.
//

import SwiftUI

struct TodoUtils {
    
    static func getShortenedTitle(_ todo: Todo, maxLength: Int) -> String {
        return todo.title.count > maxLength ? String(todo.title.prefix(maxLength) + "...") : todo.title
    }
    
}
