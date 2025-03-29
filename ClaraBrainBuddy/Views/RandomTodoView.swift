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
    
    var body: some View {
        VStack {
            if let randomTodo = todoViewModel.randomTodo() {
                Text(Localization.labels.titleRandomTodoPopup)
                    .font(Font.app.title)
                    .foregroundColor(Color.theme.white)
                    .padding(.top)
                
                VStack {
                    
                    Text("<< \(Localization.labels.swipeLeftRandomTodo)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 24)
                    
                    Text(">> \(Localization.labels.swipeRightRandomTodo)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 24)

                    Text(Localization.labels.tapToSelectRandomTodo)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 24)
                    
                }
                .font(Font.app.normal)
                .foregroundColor(Color.theme.white)
                .padding(.top)
                .padding(.bottom)
                
                Text(randomTodo.title)
                    .frame(maxWidth: .infinity)
                    .font(Font.app.title)
                    .padding()
                    .foregroundColor(Color.theme.listText)
                    .background(Color.theme.listBackground)
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
                Text(Localization.labels.noTodosRandomTodo)
                    .font(Font.app.title)
                    .foregroundColor(Color.theme.white)
                    .onTapGesture {
                        isPresented = false
                    }
            }
        }
        .frame(maxWidth: 375, maxHeight: 375)
        .background(Color.theme.blue.opacity(0.9))
        .cornerRadius(20)
        .padding()
    }
}
