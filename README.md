# A Generic Decision Tree Classifier in Swift

## Implementing a Generic Decision Tree Classifier in Swift and testing it on a Dataset of Strings and then on the Iris Dataset(comprising of Double values).

### This repo consists of a Python and Swift version of a Decision Tree Classifier. Why ML Algorithms in Swift? Check out [Swift For TensorFlow - S4TF ](https://github.com/tensorflow/swift) and [Fast AI embracing swift for ML](https://www.fast.ai/2019/03/06/fastai-swift/) to know why Swift could be the next most big thing in Machine Learning.

- - -
* Converting a Decision Tree in Python to Swift.

* Now swift is a strongly typed language, whereas python is dynamically typed. So, there are small differences in the algorithm. For example, in swift, i dont use an array that contains both strings and doubles at the same time (actually, you can by using the 'Any' type, but it is not ideal and causes a lot of errors later in the code. I am not aware of another way to do it either, if there is another way apart from using Generics, let me know. Thanks 😃).

* However, the algorithm is Generic. So even though you cannot have strings and doubles at the same time in the training data, it can either be all strings or all double or YourOwnType(that conforms to the equatable protocol) or Int or Bool etc. and the same algorithm can work on all the Data types, as demonstrated in the playground.

If you would like to see another Classifier Algorithm in Swift, check out - [K=1 Nearest Neighbour Algorithm](https://github.com/mdsahilak/KNearestNeighbour).
