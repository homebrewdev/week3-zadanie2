//
//  main.swift
//  week3-zadanie2
//
//  Created by Egor Devyatov on 23.06.2019.
//  Copyright © 2019 homework. All rights reserved.
//

import Foundation

// MARK: - Неделя 3 Задача 2
// Решить задачу
// 2. Объявить протокол Age со свойством let age: Int {get}, var birthdayString: String {get} // формат возвращаемой строки 01

// Объявить структуру Person со свойствами let name, let birthday: Date, gender: Gender реализующим протокол Age
// enum Gender реализовать внутри Person (Nested Types)
// Если переданная в инициализатор дата рождения больше текущей даты - пробросить ошибку (ошибку реализовать свою - кастомную)

// Person должен реализовывать протокол Comparable (по birthday)

// Для Dictionary написать extension с методом, который в качестве параметра будет принимать Person и добавлять в словарь по ключу person.birthday значение person.name

// Для этого задания потребуются методы типов Date, DateFormatter, Comparable // ttps://developer.apple.com/search/

protocol Age {
    var age: Int {get}
    var birthdayString: String {get}
}

struct Person: Age {
    let name: String
    let birthdayString: String
    let age: Int
    var birthday: Date
    let gender: Gender
    
    // enum Gender реализовать внутри Person (Nested Types)
    // перечисление пол персоны
    enum Gender {
        case male
        case female
    }
    // перечисление - ошибки
    enum Errors: Error {
        case birthdayDateIncorrect
    }
    // инициализатор
    init(name: String, birthdayString: String, age: Int, gender: Gender) throws {
        do {
            self.name = name
            self.birthdayString = birthdayString
            self.gender = gender
            
            // строку в дату
            func getDate(date: String) throws -> (Date?) {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.locale = Locale(identifier: "ru_RU")
                let currentDate = Date() // текущая дата
                // отформатированния текущая дата в формате dd.MM.yyyy
                let currentDateString = dateFormatter.string(from: currentDate)
                guard date < currentDateString else {
                    throw Errors.birthdayDateIncorrect
                }
                //print("Current Date: \(currentDateString)")
                return dateFormatter.date(from: date) // возвращаем тип Date
            }
            
            self.age = age
            // пробуем запасать в birthday дату рождения из строки birtdayString
            self.birthday = try getDate(date: birthdayString) ?? Date()
            // и если срабатывает исключение что дата рождения больше текущей даты - то пробросить ошибку Errors.birthdayDateIncorrect
        } catch Errors.birthdayDateIncorrect {
            self.birthday = Date() // тогда по дефолту сделаем что он родился сегодня ))
            print("Дата рождения клиента по имени \(name), больше текущей даты \(self.birthday)")
            // Дата рождения клиента по имени Вова, больше текущей даты 2019-06-24 18:40:36 +0000
        }
    }
}

// Person должен реализовывать протокол Comparable (по birthday)
extension Person: Comparable {
    static func < (lhs: Person, rhs: Person) -> Bool {
        return lhs.birthday < rhs.birthday
    }
    
    //static func <= (lhs: Person, rhs: Person) -> Bool {
    //    return lhs.birthday <= rhs.birthday
    //}
    
    //static func >= (lhs: Person, rhs: Person) -> Bool {
    //    return lhs.birthday >= rhs.birthday
    //}
    
    static func > (lhs: Person, rhs: Person) -> Bool {
        return lhs.birthday > rhs.birthday
    }
}

// для проверки на одинаковые (уже созданные) Person сделаем, чтобы тип Person удовлетворял протоколу Equatable
extension Person: Equatable {
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.name == rhs.name &&
            lhs.age == rhs.age &&
            lhs.birthday == rhs.birthday &&
            lhs.gender == rhs.gender
    }
}

// Для Dictionary написать extension с методом, который в качестве параметра будет принимать Person и добавлять в словарь по ключу person.birthday значение person.name
extension Dictionary {
    func addNewPerson(addNew person: Person, toDictionary sourceDict: Dictionary<Date, String>) -> Dictionary<Date, String> {
        var newDictionary = sourceDict
        newDictionary.updateValue(person.name, forKey: person.birthday)
        //newDictionary[person.birthday] = person.name
        return newDictionary
    }
}

let vova = try Person(name: "Вова", birthdayString: "20.01.1990", age: 30, gender: .male)
let nadya = try Person(name: "Надя", birthdayString: "10.10.1993", age: 26, gender: .female)
let vova2 = try Person(name: "Вова", birthdayString: "20.01.1990", age: 30, gender: .male)
let julia = try Person(name: "Юля", birthdayString: "12.05.1990", age: 30, gender: .female)

print(vova.birthday) // 1990-01-20 21:00:00 +0000
print(nadya.birthday) // 1993-10-09 20:00:00 +0000

// функция проверяющая кто из двух персон старше
func printWhoIsOlder(first: Person, second: Person) {
    if first < second {
        print ("Person \(first.name) старше, чем \(second.name)")
    } else if first > second {
        print("Person \(first.name) младше, чем \(second.name)")
    }
    // проверка что first и second родились в один год
    if first.age == second.age {
        print("Данные люди \(first.name) и \(second.name) родились в один и тот же год")
    }
}

printWhoIsOlder(first: vova, second: nadya) //Person Вова старше, чем Надя

if vova == vova2 {
    print("Такой человек \(vova.name) уже создан и занесен в систему!") // так как vova и vova2 идентичны, то проверка на equatable вернет True - Такой персонаж уже создан!
}

printWhoIsOlder(first: vova, second: julia) // Данные люди Вова и Юля родились в один и тот же год

// словарь персон
var personDict: Dictionary<Date, String> = [vova.birthday: vova.name, nadya.birthday: nadya.name]

if personDict[vova.birthday] != nil {
    print(personDict[vova.birthday]!) // Вова
}
// новый массив с добавленным персоной julia
let newDict = personDict.addNewPerson(addNew: julia, toDictionary: personDict) // добавим Юлю

let dictCount = newDict.count // размер нового словаря

print("Содержимое словаря:")
print("Размер словаря: \(dictCount) элементов")
print(newDict)
// Содержимое словаря:
// [1990-01-19 21:00:00 +0000: "Вова", 1993-10-09 20:00:00 +0000: "Надя", 1990-05-11 20:00:00 +0000: "Юля"]
// таким образом Юля добавилась в словарь
