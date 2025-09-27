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
                    .foregroundColor(Color.theme.gray)
                    .padding(.top)
                
                VStack (spacing: 16) {
                    
                    HStack {
                        Image(.swipeLeft)
                            .iconStyle()
                        Text("\(Localization.labels.swipeLeftRandomTodo)")
                            .padding(.leading, 8)
                    }
                    
                    HStack {
                        Image(.swipeRight)
                            .iconStyle()
                        VStack {
                            Text("\(Localization.labels.swipeRightRandomTodo1)")
                                .padding(.leading, 8)
                            Text("\(Localization.labels.swipeRightRandomTodo2)")
                                .padding(.leading, 8)
                        }
                    }
                    
                    HStack {
                        Image(.tap)
                            .iconStyle()
                        VStack {
                            Text(Localization.labels.tapToSelectRandomTodo1)
                                .padding(.leading, 8)
                            Text(Localization.labels.tapToSelectRandomTodo2)
                                .padding(.leading, 8)
                        }
                    }
                    
                }
                .font(Font.app.normal)
                .foregroundColor(Color.theme.gray)
                .padding(.top)
                .padding(.bottom)
                
                Text(randomTodo.title)
                    .frame(maxWidth: .infinity)
                    .font(Font.app.title)
                    .padding()
                    .foregroundColor(Color.theme.gray)
                    .background(Color.theme.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.theme.accent, lineWidth: 1)
                    )
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
                    .font(Font.app.normal)
                    .foregroundColor(Color.theme.gray)
                    .onTapGesture {
                        isPresented = false
                    }
                    .accessibilityIdentifier("NoTodosText")
            }
        }
        .frame(maxWidth: 375, maxHeight: 375)
        .background(Color.theme.white)
        .cornerRadius(20)
        .padding()
    }
}

extension Image {
    func iconStyle() -> some View {
        self.resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
    }
}
