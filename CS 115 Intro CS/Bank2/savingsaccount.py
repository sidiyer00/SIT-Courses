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
- this file is the savings account class
"""

class SavingsAccount:
    """This class represents a savings account
    with the owner's name, PIN, and balance."""

    RATE = 0.02    # Single rate for all accounts
    

    def __init__(self, balance = 0.0):
        self.balance = balance
        self.counter = 0
        self.SAVINGS_MONTHLY_FEE = 8

    def __str__(self):
        """Returns the string rep."""
        result = '\tSavings Balance: $' + str(self.balance)
        return result

    def getBalance(self):
        """Returns the current balance."""
        return self.balance

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
            if self.counter >= 6:
                self.balance -= 10
                print("Over 6 withdraws...charged $10 fee")
            self.counter += 1
            return None

    def computeInterest(self):
        """Computes, deposits, and returns the interest."""
        interest = self.balance * SavingsAccount.RATE
        self.deposit(interest)
        return interest

    def chargeMonthlyFee(self):
        if self.balance >= 500:
            return
        else:
            self.balance -= self.SAVINGS_MONTHLY_FEE
            print("A monthly fee of $8 has been charged to your account")
