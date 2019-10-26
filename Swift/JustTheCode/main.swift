// written by: md_sahil_ak

import Foundation

func consoleLineBreak(_ heading: String ) {
    print("- - - - - - - - - - - - - - - - - - - - - - - - - - - - \(heading) - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -")
}


// Dataset
var headers: [String] = ["color", "diameter", "label"]
let trainingData: [[String]] = [
    ["Green", "3"],
    ["Yellow", "3"],
    ["Red", "1"],
    ["Red", "1"],
    ["Yellow", "3"]
    ]
let trainingTargets: [String] = ["Apple", "Apple", "Grape", "Grape", "Lemon"]


// MARK: Utility Functions
consoleLineBreak("Utility functions")
func uniqueValues<T: Hashable>(rows: [[T]], Column: Int) -> Set<T> {
    var ans: Set<T> = []
    for row in rows {
        let val = row[Column]
        ans.insert(val)
    }
    return ans
}

print(uniqueValues(rows: trainingData, Column: 0))

func classCounts<T>(rows: [[T]], targets: [String]) -> [String: Int] {
    var counts: [String: Int] = [:]
    
    for i in 0..<rows.count {
        let label = targets[i] //"\(rawLabel)"
        if counts[label] == nil {
            // if the label isnt there, then add it with count value as 0
            counts[label] = 0
        }
        // otherwise just append one to the count value corresponding to the label
        counts[label]! += 1
    }
    return counts
}

print(classCounts(rows: trainingData, targets: trainingTargets))

func isNumeric<T>(_ value: T) -> Bool {
    if value is Int || value is Float || value is Double {
        return true
    } else {
        return false
    }
}

print(isNumeric(50.0))

// -End- Utility Functions //


// MARK: Question Struct
consoleLineBreak("question struct")
struct Question<T: Comparable>: CustomStringConvertible{
    var column: Int
    var value: T
    
    // Custom string convertible-protocol required implementation
    var description: String {
        var condition: String {
            if isNumeric(value) {
                return ">="
            } else {
                return "=="
            }
        }
        return "Is the \(headers[self.column]) \(condition) \(self.value)?"
    }
    
    func match(_ exampleRow: [T]) -> Bool {
        let val = exampleRow[column]
        if isNumeric(value) {
            return val >= self.value
        } else {
            return val == self.value
        }
    }
    
}

let q = Question(column: 0, value: "Green")
q.match(trainingData[0])
print(q)


// MARK: Partition Function
consoleLineBreak("partition func")
func partition<T: Comparable>(rows: [[T]], targets: [String], question: Question<T>) -> ([[T]], [String], [[T]], [String]) {
    var trueRows: [[T]] = []
    var trueTargets: [String] = []
    var falseRows: [[T]] = []
    var falseTargets: [String] = []
    
    for (i, row) in rows.enumerated() {
        if question.match(row)  {
            trueRows.append(row)
            trueTargets.append(targets[i])
        } else {
            falseRows.append(row)
            falseTargets.append(targets[i])
        }
    }
    return (trueRows, trueTargets, falseRows, falseTargets)
}

let (trueRowsxx, trueTargetsxx, falseRowsxx, falseTargetsxx) = partition(rows: trainingData, targets: trainingTargets, question: q)
print(trueRowsxx)
print(falseRowsxx)


// MARK: Gini Impurity
consoleLineBreak("Gini impurity")
func gini<T>(rows: [[T]], targets: [String]) -> Double {
    let counts: [String: Int] = classCounts(rows: rows, targets: targets)
    var impurity: Double = 1
    for label in counts {
        let probOfLabel = Double(counts[label.key]!) / Double(rows.count)
        impurity -= pow(probOfLabel, 2)
    }
    return impurity
}

print(gini(rows: trainingData, targets: trainingTargets))


// MARK: Information Gain
consoleLineBreak("Info Gain")
func infoGain<T>(leftRows: [[T]], leftTargets: [String], rightRows: [[T]], rightTargets: [String], currentUncertainity: Double) -> Double {
    let leftWeight = Double(leftRows.count) / Double(leftRows.count + rightRows.count)
    let rightWeight = 1 - leftWeight // or Double(right.count) / Double(left.count + right.count)
    
    let weightAvgImpurity = leftWeight * gini(rows: leftRows, targets: leftTargets) + rightWeight * gini(rows: rightRows, targets: rightTargets)
    let informationGain = currentUncertainity - weightAvgImpurity
    
    return informationGain
}

print(infoGain(leftRows: trueRowsxx, leftTargets: trueTargetsxx, rightRows: falseRowsxx, rightTargets: falseTargetsxx, currentUncertainity: gini(rows: trainingData, targets: trainingTargets)))


// MARK: Best Question Run
consoleLineBreak("Best Question and corresponding info gain")
func findBestQuestion<T: Hashable & Comparable>(rows: [[T]], targets: [String]) -> (Double, Question<T>) {
    var bestGain: Double = 0
    var bestQuestion: Question<T> = Question(column: 0, value: rows.first![0]) // random starter question
    let currentUncertainity: Double = gini(rows: rows, targets: targets)
    let numOfFeatures: Int = rows.first!.count
    
    for column in 0..<numOfFeatures {
        let values = uniqueValues(rows: rows, Column: column)
        
        for value in values {
            let question = Question(column: column, value: value)
            let (trueRows, trueTargets, falseRows, falseTargets) = partition(rows: rows, targets: targets, question: question)
            if trueRows.count == 0 || falseRows.count == 0 {
                // do nothing - Skip the split if it doesn't divide the dataset
                continue
            }
            let gain = infoGain(leftRows: trueRows, leftTargets: trueTargets, rightRows: falseRows, rightTargets: falseTargets, currentUncertainity: currentUncertainity)
            if gain >= bestGain {
                bestGain = gain
                bestQuestion = question
            }
            
        }
        
    }
    
    return (bestGain, bestQuestion)
}

let (bestGain, bestQuestion) = findBestQuestion(rows: trainingData, targets: trainingTargets)
print(bestGain)
print(bestQuestion)


consoleLineBreak("Leaf and Decision Node structs")

// MARK: Leaf
struct Leaf {
    var predictions: [String: Int]
    
    init<T>(rows: [[T]], targets: [String]) {
        self.predictions = classCounts(rows: rows, targets: targets)
    }
}

// MARK: Decision Node
struct DecisionNode<T: Comparable> {
    var question: Question<T>
    var trueBranch: Any
    var falseBranch: Any
    
}


// MARK: Decision Tree
consoleLineBreak("DecisionTree")

func BuildTree<T: Hashable & Comparable>(rows: [[T]], targets: [String]) -> Any {
    let (gain, question) = findBestQuestion(rows: rows, targets: targets)
    //Uncomment below lines to Vizualize the tree building process
    //print("build tree step")
    //print("gain ->", gain, "|", "question ->", question)
    if gain == 0.0 {
        let predictions = Leaf(rows: rows, targets: targets)
        //print(predictions)
        return predictions
    }
    
    let (trueRows, trueTargets, falseRows, falseTargets) = partition(rows: rows, targets: targets, question: question)
    //Uncomment below lines to Vizualize the tree building process
    //print("true rows ->", trueRows)
    //print("false rows ->", falseRows)
    
    let trueBranch = BuildTree(rows: trueRows, targets: trueTargets)
    let falseBranch = BuildTree(rows: falseRows, targets: falseTargets)
    
    return DecisionNode(question: question, trueBranch: trueBranch, falseBranch: falseBranch)
}

func printTree<T: Comparable>(node: Any, spacing: String = "", dTypeInstance: T) {
    if let leaf = node as? Leaf {
        print(spacing + "Predict", leaf.predictions)
        return
    }
    
    let dNode = node as! DecisionNode<T>
    print(spacing + dNode.question.description)
    
    print(spacing + "--> True:")
    printTree(node: dNode.trueBranch, spacing: spacing + "  ", dTypeInstance: dTypeInstance)
    
    print(spacing + "--> False:")
    printTree(node: dNode.falseBranch, spacing: spacing + "  ", dTypeInstance: dTypeInstance)
    
}

func vizPredictionsAtLeaf(predictions: [String: Int]) -> [String: String] {
    let total = Double(predictions.values.reduce(0, +))
    var probabilities: [String: String] = [:]
    
    for label in predictions.keys {
        probabilities[label] = String((Double(predictions[label]!) / total * 100)) + "%"
    }
    return probabilities
}

func classify<T: Comparable>(sample: [T], node: Any) -> [String: String] {
    if let leaf = node as? Leaf {
        return vizPredictionsAtLeaf(predictions: leaf.predictions)
    }
    
    let dNode = node as! DecisionNode<T>
    if dNode.question.match(sample) {
        return classify(sample: sample, node: dNode.trueBranch)
    } else {
        return classify(sample: sample, node: dNode.falseBranch)
    }
}


// MARK: Examining The Tree
consoleLineBreak("examining the tree")
let testingData: [[String]] = [
    ["Green", "3"],
    ["Yellow", "4"],
    ["Red", "2"],
    ["Red", "1"],
    ["Yellow", "3"],
    ]
let testingTargets: [String] = ["Apple", "Apple", "Grape", "Grape", "Lemon"]

let myTree = BuildTree(rows: trainingData, targets: trainingTargets)
printTree(node: myTree, dTypeInstance: trainingData.first!.first!)

// MARK: Evaluate the Tree
consoleLineBreak("Evaluating the tree")
for (i, row) in testingData.enumerated() {
    let actualVal = testingTargets[i]
    let prediction = classify(sample: row, node: myTree)
    
    print("Prediction: \(prediction) | AcutalValue: \(actualVal)")
}


// MARK: Evaluating with the iris dataset
// Now Lets try with another datatype(double) and dataset(iris-dataset)
consoleLineBreak("Evaluate with iris dataset")

var (iTrainingData, iTrainingTargetsRaw, iTestingData, iTestingTargetsRaw) = IrisDataset.trainTestSplit(numOfTestItems: 15)

// Change the labels to string
let iTrainingTargets = iTrainingTargetsRaw.map { (val) -> String in
    return "\(Int(val))"
}

//print(iTrainingTargets)

let iTestingTargets = iTestingTargetsRaw.map { (val) -> String in
    return "\(Int(val))"
}

//print(iTestingTargets)

headers = IrisDataset.featureNames
let irisTree = BuildTree(rows: iTrainingData, targets: iTrainingTargets)
printTree(node: irisTree, dTypeInstance: iTrainingData.first!.first!)


for (i, row) in iTestingData.enumerated() {
    let actualVal = iTestingTargets[i]
    let prediction = classify(sample: row, node: irisTree)
    
    print("Prediction: \(prediction) | AcutalValue: \(actualVal)")
}



consoleLineBreak("End")
