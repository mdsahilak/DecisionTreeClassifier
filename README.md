# A Generic Decision Tree Classifier in Swift

## Implementing a generic decision tree classifier in swift and testing it on a dataset of strings and then on the iris dataset(comprising of Double type values).

### This repo consists of a python and a swift version of a decision tree classifier. 

- - -
> As part of a course on machine learning, i learned how to write a decision tree classifier in python. But can it be implemented in swift? I explore it here. 

> Now swift is a strongly typed language, wheares python isnt. So, there are small differences in the algorithm. For example, in swift, i cannot use an array that contains both strings and doubles at the same time(actually, you can by using the 'Any' type, but it is not ideal and causes a lot of errors later in the code.)

> However, I did make the algorithm Generic. so even though you cannot have strings and doubles at the same time in the training data, it can either be all strings or all double or all Int, etc. and the same algorithm can work on both data types, as demonstrated in the playground.
