import Foundation

struct AlertModel {
    //текст заголовка алерта
    var title: String
    //текст сообщения алерта
    var message: String
    //текст для кнопки алерта
    var buttonText: String
    //индентификатор
    var identifier: String
    //замыкание для действия по кнопке алерта
    var completion: () -> Void
}
