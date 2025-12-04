//
//  Views/PriorityMatrix/Matrix.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 05.12.25.
//



enum PriorityMatrix  {
    case urgent
    case importantAndUrgent
    case nothingOfBoth
    case important

    var localizedString: String {
        
        switch self {
            case PriorityMatrix.important:
                return Localization.priority.important
            case PriorityMatrix.urgent:
                return Localization.priority.urgent
            case PriorityMatrix.importantAndUrgent:
                return Localization.priority.importantAndUrgent
            default:
                return Localization.priority.nothingOfBoth
        }
    }
}
