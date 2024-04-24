//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Shantanu Roy on 4/24/24.
//

import Foundation

class TriviaQuestionService {
    func fetchTriviaQuestions(category: Int?, difficulty: String?, completion: @escaping ([TriviaQuestion]?) -> Void) {
        var urlString = "https://opentdb.com/api.php?amount=5"
        if let category = category {
            urlString += "&category=\(category)"
        }
        if let difficulty = difficulty {
            urlString += "&difficulty=\(difficulty)"
        }
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching trivia questions: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                let triviaResponse = try decoder.decode(TriviaResponse.self, from: data)
                let questions = triviaResponse.results.map { TriviaAPIQuestion -> TriviaQuestion in
                    return TriviaQuestion(
                        category: TriviaAPIQuestion.category,
                        question: TriviaAPIQuestion.question,
                        correctAnswer: TriviaAPIQuestion.correct_answer,
                        incorrectAnswers: TriviaAPIQuestion.incorrect_answers)
                }
                completion(questions)
            } catch {
                print("Error decoding trivia questions: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}

struct TriviaResponse: Codable {
    let results: [TriviaAPIQuestion]
}

struct TriviaAPIQuestion: Codable {
    let category: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
    
    func toTriviaQuestion() -> TriviaQuestion {
        return TriviaQuestion(category: category, question: question, correctAnswer: correct_answer, incorrectAnswers: incorrect_answers)
    }
}
