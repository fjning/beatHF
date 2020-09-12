//
//  StudyTasks.swift
//
//  Created for the CardinalKit Framework.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import ResearchKit

/**
 This file contains some sample `ResearchKit` tasks
 that you can modify and use throughout your project!
*/
struct StudyTasks {
    
    /**
     Active tasks created with short-hand constructors from `ORKOrderedTask`
    */
    static let tappingTask: ORKOrderedTask = {
        let intendedUseDescription = "Finger tapping is a universal way to communicate."
        
        return ORKOrderedTask.twoFingerTappingIntervalTask(withIdentifier: "TappingTask", intendedUseDescription: intendedUseDescription, duration: 10, handOptions: .both, options: ORKPredefinedTaskOption())
    }()
    
    static let walkingTask: ORKOrderedTask = {
        let intendedUseDescription = "Tests ability to walk"
        
        return ORKOrderedTask.shortWalk(withIdentifier: "ShortWalkTask", intendedUseDescription: intendedUseDescription, numberOfStepsPerLeg: 20, restDuration: 30, options: ORKPredefinedTaskOption())
    }()
    
    /**
     Sample task created step-by-step!
    */
    static let sf12Task: ORKOrderedTask = {
        var steps = [ORKStep]()

        let yesNoAnswer = ORKBooleanAnswerFormat(yesString: "Yes", noString: "No")
		let medicationQuestionStep = ORKQuestionStep(identifier: "medicationQuestionStep", title: nil, question: "Have you missed your medications more than 1 time this week?".capitalized, answer: yesNoAnswer) //YES-Message-NoAlert
		let breathQuestionStep = ORKQuestionStep(identifier: "breathQuestionStep", title: nil, question: "Are you more short of breath than usual?".capitalized, answer: yesNoAnswer) //YES-Follow-Up-3
			let activeQuestionStep = ORKQuestionStep(identifier: "activeQuestionStep", title: nil, question: "Do you have more trouble breathing when you are active?".capitalized, answer: yesNoAnswer) //yellow-alert
			let restingQuestionStep = ORKQuestionStep(identifier: "restingQuestionStep", title: nil, question: "Do you have more trouble breathing when you are resting or you cannot stop coughing?".capitalized, answer: yesNoAnswer) //orange-alert
			let awayQuestionStep = ORKQuestionStep(identifier: "awayQuestionStep", title: nil, question: "Are you having trouble breathing that will not go away?".capitalized, answer: yesNoAnswer) //red-alert
		let gainedQuestionStep = ORKQuestionStep(identifier: "gainedQuestionStep", title: nil, question: "Have you gained 2 to 3 pounds overnight or 5 pounds in one week? ".capitalized, answer: yesNoAnswer) //yellow-alert
		let sleepQuestionStep = ORKQuestionStep(identifier: "sleepQuestionStep", title: nil, question: "Are you having trouble breathing related to sleep?".capitalized, answer: yesNoAnswer) //yes-follow-2
			let pillowsQuestionStep = ORKQuestionStep(identifier: "pillowsQuestionStep", title: nil, question: "Do you need more pillows than usual to sleep?".capitalized, answer: yesNoAnswer) //yellow-alert
			let wakeQuestionStep = ORKQuestionStep(identifier: "wakeQuestionStep", title: nil, question: "Do you wake up because you cannot sleep?".capitalized, answer: yesNoAnswer) //orange-alert
		let dizzyQuestionStep = ORKQuestionStep(identifier: "dizzyQuestionStep", title: nil, question: "Do you feel dizzy, pass out, or feel that you are going to pass out?".capitalized, answer: yesNoAnswer) //yes-follow-1
			let passOutQuestionStep = ORKQuestionStep(identifier: "passOutQuestionStep", title: nil, question: "Did you pass out or feel that you are going to pass out?".capitalized, answer: yesNoAnswer) //yes-red-alert no-orange-alert
		let rapidQuestionStep = ORKQuestionStep(identifier: "rapidQuestionStep", title: nil, question: "Do you have a rapid heart beat that makes you feel dizzy?".capitalized, answer: yesNoAnswer)
		let chestQuestionStep = ORKQuestionStep(identifier: "chestQuestionStep", title: nil, question: "Do you have chest pain?".capitalized, answer: yesNoAnswer)
		let swellingQuestionStep = ORKQuestionStep(identifier: "swellingQuestionStep", title: nil, question: "Do you have more swelling than usual?".capitalized, answer: yesNoAnswer)

        //SUMARY
        let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
        summaryStep.title = "Thank you."
        summaryStep.text = "We appreciate your time."
        
        steps += [medicationQuestionStep,breathQuestionStep,activeQuestionStep,restingQuestionStep,awayQuestionStep,gainedQuestionStep,sleepQuestionStep,pillowsQuestionStep,wakeQuestionStep,dizzyQuestionStep,passOutQuestionStep,rapidQuestionStep,chestQuestionStep,swellingQuestionStep,summaryStep]

		// Form a task
		var task = ORKNavigableOrderedTask(identifier: "SurveyTask-SF12", steps: steps)

		//  Expected answer - (usually No) - Skips to the next question
		var resultSelector = ORKResultSelector(resultIdentifier: "breathQuestionStep")
		var predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: false)
		var predicateRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers:
				   [ (predicate, "gainedQuestionStep") ])
		task.setNavigationRule(predicateRule, forTriggerStepIdentifier: "breathQuestionStep")

		resultSelector = ORKResultSelector(resultIdentifier: "sleepQuestionStep")
		predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: false)
		predicateRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers:
				   [ (predicate, "dizzyQuestionStep") ])
		task.setNavigationRule(predicateRule, forTriggerStepIdentifier: "sleepQuestionStep")

		resultSelector = ORKResultSelector(resultIdentifier: "dizzyQuestionStep")
		predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: false)
		predicateRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers:
				   [ (predicate, "rapidQuestionStep") ])
		task.setNavigationRule(predicateRule, forTriggerStepIdentifier: "dizzyQuestionStep")

		return task

    }()
}
