"""
File: checkingaccount_SiddharthIyer.py
This module defines the Checkings Account class
"""

class CheckingAccount:

    def __init__(self, name, pin, balance = 0.0):
        """This function initializes the Checking account"""
        self.name = name
        self.pin = pin
        self.balance = balance

    def __str__(self):
        """Returns the string rep."""
        result = '\tChecking Balance: $' + str(self.balance)
        return result

    def getBalance(self):
        """Returns the current balance."""
        return self.balance


    def getName(self):
        """Returns the current name."""
        return self.name

    def getPin(self):
        """Returns the current pin."""
        return self.pin

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