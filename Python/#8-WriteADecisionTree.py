# A Custom Decision Tree Classifier

def console_line(heading):
    print(f"- - - - -{heading}- - - - - - - - - - - - - - - - - - - - - -")
# Dataset
training_data = [
    ['Green', '3', 'Apple'],
    ['Yellow', '3', 'Apple'],
    ['Red', '1', 'Grape'],
    ['Red', '1', 'Grape'],
    ['Yellow', '3', 'Lemon'],
]
 
# Column headings for printing
header = ["color", "diameter", "label"]


console_line("utility functions")
# Utility FUnctions #
def unique_vals(rows, col):
    """Find the unique values for a column in a dataset."""
    return set([row[col] for row in rows])

print(unique_vals(training_data, 1))

def class_counts(rows):
    """Counts the number of each type of example in a dataset."""
    counts = {}  # a dictionary of label -> count.
    for row in rows:
        # in our dataset format, the label is always the last column
        label = row[-1]
        if label not in counts:
            counts[label] = 0
        counts[label] += 1
    return counts

print(class_counts(training_data))

def is_numeric(value):
    """Test if a value is numeric."""
    return isinstance(value, int) or isinstance(value, float)

print(is_numeric(5))


console_line("question class")
# Question Class
class Question:
    """A Question is used to partition a dataset.

    This class just records a 'column number' (e.g., 0 for Color) and a
    'column value' (e.g., Green). The 'match' method is used to compare
    the feature value in an example to the feature value stored in the
    question. See the demo below.
    """

    def __init__(self, column, value):
        self.column = column
        self.value = value

    def match(self, example):
        # Compare the feature value in an example to the
        # feature value in this question.
        val = example[self.column]
        if is_numeric(val):
            return val == self.value
        else:
            return val == self.value

    def __repr__(self):
        # This is just a helper method to print
        # the question in a readable format.
        condition = "=="
        if is_numeric(self.value):
            condition = "=="
        return "Is %s %s %s?" % (
            header[self.column], condition, str(self.value))


q = Question(0, 'Green')
print(q)
example = training_data[1]
print(example)
print(q.match(example))


console_line("partition func")
# Partioning the dataset
def partition(rows, question):
    """Partitions a dataset.

    For each row in the dataset, check if it matches the question. If
    so, add it to 'true rows', otherwise, add it to 'false rows'.
    """
    true_rows, false_rows = [], []
    for row in rows:
        if question.match(row):
            true_rows.append(row)
        else:
            false_rows.append(row)
    return true_rows, false_rows

true_rowsx, false_rowsx = partition(training_data, Question(0,'Red'))
print(true_rowsx)
print(false_rowsx)


# Gini Impurity Function
console_line("gini impurity")
def gini(rows):
    """Calculate the Gini Impurity for a list of rows.

    There are a few different ways to do this, I thought this one was
    the most concise. See:
    https://en.wikipedia.org/wiki/Decision_tree_learning#Gini_impurity
    """
    counts = class_counts(rows)
    impurity = 1
    for label in counts:
        prob_of_label = counts[label] / float(len(rows))
        # print(prob_of_label)
        impurity -= prob_of_label**2
        # print(impurity)
    return impurity

some_mixing = [['Apple'], ['Orange']]
print(gini(some_mixing))


# Information Gain
console_line("information gain")

def information_gain(left, right, current_uncertainty):
    """Information Gain.

    The uncertainty of the starting node, minus the weighted impurity of
    two child nodes.
    """
    left_weight = float(len(left)) / (len(left) + len(right))
    right_weight = 1 - left_weight # or -> float(len(right)) / (len(left) + len(right)) , both give the same result.
    weighted_avg_impurity = left_weight*gini(left) + right_weight*gini(right)

    info_gain = current_uncertainty - weighted_avg_impurity
    return info_gain

current_uncertainty = gini(training_data)
# true_rows, false_rows = partition(training_data, Question(0, 'Green'))
true_rowsxx, false_rowsxx = partition(training_data, Question(0, 'Green'))
print(information_gain(true_rowsxx, false_rowsxx, current_uncertainty))

# Finding the best question to ask
console_line("best question")
def find_best_split(rows):
    """Find the best question to ask by iterating over every feature / value
    and calculating the information gain."""
    best_gain = 0
    best_question = None
    current_uncertainty = gini(rows)
    no_of_features = len(rows[0]) - 1

    for col in range(no_of_features):

        values = unique_vals(rows, col)

        for val in values:
            question = Question(col, val)
            # print(question)

            true_rows, false_rows = partition(rows, question)
            # Skip this split if it doesn't divide the
            # dataset
            if len(true_rows) == 0 or len(false_rows) == 0:
                continue

            gain = information_gain(true_rows, false_rows, current_uncertainty)
            if gain >= best_gain:
                best_gain = gain
                best_question = question

    return best_gain, best_question

best_gain, best_question = find_best_split(training_data)
print(best_gain)
print(best_question)

# Leaf
console_line("leaf class")
class Leaf:
    """A Leaf node classifies data.

    This holds a dictionary of class (e.g., "Apple") -> number of times
    it appears in the rows from the training data that reach this leaf.
    """
    def __init__(self, rows):
        self.predictions = class_counts(rows)


# Decision Node
console_line("decision node")
class Decsision_Node:
    """A Decision Node asks a question.

    This holds a reference to the question, and to the two child nodes.
    """
    def __init__(self, question, true_branch, false_branch):
        self.question = question
        self.true_branch = true_branch
        self.false_branch = false_branch


# build the tree
console_line("building the tree")
def build_tree(rows):
    """Builds the tree.

    Rules of recursion: 1) Believe that it works. 2) Start by checking
    for the base case (no further information gain). 3) Prepare for
    giant stack traces.
    """
    # find the best question to ask and hold its info gain and the question itself
    gain, question = find_best_split(rows)

    # base case
    if gain == 0:
        return Leaf(rows)
    
    # split into the true and false branches
    true_rows, false_rows = partition(rows, question)

    # Recursively build the tree for each branch
    true_branch = build_tree(true_rows)
    false_branch = build_tree(false_rows)

    # return a reference to the question and its branches at each decision node
    return Decsision_Node(question, true_branch, false_branch)

#
# Printing and Usability functions
#   Printing function for the tree with good visualisation
def print_tree(node, spacing=""):
    if isinstance(node, Leaf):
        print(spacing + "Predict", node.predictions)
        return

    print(spacing + str(node.question))

    print(spacing + "--> True:")
    print_tree(node.true_branch, spacing + "  ")

    print(spacing + "--> False:")
    print_tree(node.false_branch, spacing + "  ")

#   Printing function for good visualization of a classified leaf with % representation
def predictionViz_at_leaf(counts):
    total = sum(counts.values()) * 1.0
    probs = {}
    for label in counts.keys():
        probs[label] = str(int(counts[label] / total * 100)) + "%"
    return probs


# Classify function
console_line("classify")
def classify(row, node):
    """See the 'rules of recursion' above."""
    if isinstance(node, Leaf):
        return predictionViz_at_leaf(node.predictions)
    
    if node.question.match(row):
        return classify(row, node.true_branch)
    else:
        return classify(row, node.false_branch)


# Lets check out the tree
console_line("Tree Workings")

my_tree = build_tree(training_data)
print_tree(my_tree)


#
# Evaluataion of the tree with unseen data
#
console_line("Evaluate the Tree")
testing_data = [
    ['Green', 3, 'Apple'],
    ['Yellow', 4, 'Apple'],
    ['Red', 2, 'Grape'],
    ['Red', 1, 'Grape'],
    ['Yellow', 3, 'Lemon'],
]

# make predictions for each test item
for row in testing_data:
    actualval = row[-1]
    prediction = classify(row, my_tree)
    print(f"Prediction: {prediction} | Actual Value: {actualval}")
