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
            Text("What would you like to do?")
                .font(Font.app.title)
                .foregroundColor(Color.theme.white)
                .padding(.top)
            
            VStack {
                
                Text("Swipe left to delete.")
                
                Text("Swipe right to keep, but prioritize lower.")
                
                Text("Or tap to select for today.")

                    
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
                        todoViewModel.handleTap(randomTodo)
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
                Text("No todos available")
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
