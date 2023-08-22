//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 22.08.2023.
//

import Foundation

struct AlertModel {
    //текст заголовка алерта
    var title: String
    //текст сообщения алерта
    var message: String
    //текст для кнопки алерта
    var buttonText: String
    //замыкание без параметров для действия по кнопке алерта
    var completion: (_:MovieQuizViewController) -> Void
}
