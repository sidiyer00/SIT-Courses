"""
File: student.py
Resources to manage a student's name and test scores.
"""

class Student(object):
    """Represents a student."""

    def __init__(self, name, number):
        """All scores are initially 0."""
        self.name = name
        self.scores = []
        for count in range(number):
            self.scores.append(0)

    def getName(self):
        """Returns the student's name."""
        return self.name
  
    def setScore(self, i, score):
        """Resets the ith score, counting from 1."""
        self.scores[i-1] = score

    def getScore(self, i):
        """Returns the ith score, counting from 1."""
        return self.score[i-1]
   
    def getAverage(self):
        avg = 0
        for i in self.scores:
            avg+=i
        return avg/len(self.scores)
            
    def getHighScore(self):
        """Returns the highest score."""
        return max(self.scores)
 
    def __str__(self):
        """Returns the string representation of the student."""
        #come back to this later after Domi instruction
        returnString = ""
        returnString+="Student name: " + self.name + "\n"
        returnString+="Student grade average: " + str(self.getAverage()) + "\n"
        returnString+="Student highest score: " + str(self.getHighScore())
        return returnString

def main():
    """A simple test."""
    sally = Student("Sally", 5)
    sally.setScore(1,90)
    sally.setScore(2,87)
    sally.setScore(3,93)
    sally.setScore(4,65)
    sally.setScore(5, 91)
    print(sally)
    

if __name__ == "__main__":
    main()


