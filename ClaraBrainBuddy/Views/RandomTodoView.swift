//
//  Random.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 21.03.25.
//

import SwiftUI

struct RandomTodoView: View {
    
    @ObservedObject var todoViewModel: TodoViewModel
    
    @Binding var isPresented: Bool
    
    let title = NSLocalizedString("random.todo.popup.title", comment: "What would you like to do?")
    let swipeLeftLabel = NSLocalizedString("random.todo.popup.explanation.swipe.left", comment: "Swipe left to delete.")
    let swipeRightLabel = NSLocalizedString("random.todo.popup.explanation.swipe.right", comment: "Swipe right to keep, but prioritize lower.")
    let tapToSelectLabel = NSLocalizedString("random.todo.popup.explanation.tab", comment: "Or tap to select for today.")
    let noTodosLabel = NSLocalizedString("random.todo.popup.no.todo.available", comment: "No todos available...")
    
    var body: some View {
        VStack {
            Text(title)
                .font(Font.app.title)
                .foregroundColor(Color.theme.white)
                .padding(.top)
            
            VStack {
                
                Text(swipeLeftLabel)
                
                Text(swipeRightLabel)
                
                Text(tapToSelectLabel)

                    
            }
            .font(Font.app.normal)
            .foregroundColor(Color.theme.white)
            .padding(.top)
            .padding(.bottom)
                         
            if let randomTodo = todoViewModel.randomTodo() {
                
                Text(randomTodo.title)
                    .frame(maxWidth: .infinity)
                    .font(Font.app.title)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding()
                    .onTapGesture {
                        todoViewModel.moveToTheTop(randomTodo)
                        isPresented = false
                    }
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onEnded { value in
                                if value.translation.width < 0 {
                                    // swipe left
                                    todoViewModel.deleteTodo(randomTodo)
                                } else if value.translation.width > 0 {
                                    // swipe right
                                    todoViewModel.moveTodoOneDown(randomTodo)
                                }
                                isPresented = false
                            }
                    )
            } else {
                Text(noTodosLabel)
                    .font(Font.app.title)
                    .foregroundColor(Color.theme.primary)
            }
        }
        .frame(maxWidth: 375, maxHeight: 375)
        .background(Color.theme.blue.opacity(0.9))
        .cornerRadius(20)
        .padding()
    }
}
