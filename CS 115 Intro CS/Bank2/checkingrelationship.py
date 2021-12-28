"""
Title:
- 2020 Capstone Project

Author
- Siddharth Iyer

Collaborators:
- None

Date:
- 2020 May 17

Filename:
- main.py

Description:
- this file is the checking relations account 
"""

class CheckingRelationship(object):
    def __init__(self, balance = 0.0):
        """This function initializes the Checking Relationship account"""
        self.balance = balance
        self.RELATIONSHIP_MONTHLY_FEE = 25

    def getBalance(self):
        """Returns the current balance."""
        return self.balance

    def __str__(self):
        """Returns the string rep."""
        result = '\tChecking Relationship Balance: $' + str(self.balance)
        return result

    def deposit(self, amount):
        """If the amount is valid, adds it
        to the balance and returns None;
        otherwise, returns an error message."""
        self.balance += amount
        return None

    def withdraw(self, amount):
        """If the amount is valid, sunstract it
        from the balance and returns None;
        otherwise, returns an error message."""
        if amount < 0:
            return "Amount must be >= 0"
        elif self.balance < amount:
            return "Insufficient funds"
        else:
            self.balance -= amount
            return None
        
    def chargeMonthlyFee(self):
        self.balance -= self.RELATIONSHIP_MONTHLY_FEE
        print("A monthly fee was charged to your account")