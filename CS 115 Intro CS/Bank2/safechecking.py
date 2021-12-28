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
- this file is the restricted checking account
- prevents users from withdrawing more than 3 times a month
"""

class CheckingRestricted():
    """This class represents a restricted savings account."""

    MAX_WITHDRAWALS = 3
    
        
    def __init__(self, balance = 0.0):
        """Same attributes as SavingsAccount, but with
        a counter for withdrawals."""
        self.counter = 0
        self.balance = balance
        self.SAFE_MONTHLY_FEE = 4.95
   
    def deposit(self, amount):
        """If the amount is valid, adds it
        to the balance and returns None;
        otherwise, returns an error message."""
        self.balance += amount
        return None

    def resetCounter(self):
        """Resets the counter to 0."""
        self.counter = 0

    def withdraw(self, amount):
        """Restricts number of withdrawals to MAX_WITHDRAWALS.
        If the amount is valid, sunstract it
        from the balance and returns None;
        otherwise, returns an error message."""
        if self.counter == 3:
            print("Can't withdraw more that 3 times")
            return

        if amount < 0:
            return "Amount must be >= 0"
        elif self.balance < amount:
            return "Insufficient funds"
        else:
            self.balance -= amount
            self.counter += 1
            return None
    
    def getBalance(self):
        """Returns the current balance."""
        return self.balance

    def __str__(self):
        """Returns the string rep."""
        result = '\tRestricted Checking Balance: $' + str(self.balance)
        return result

    def chargeMonthlyFee(self):
        self.balance -= self.SAFE_MONTHLY_FEE
        print("A monthly fee was charged to your account")