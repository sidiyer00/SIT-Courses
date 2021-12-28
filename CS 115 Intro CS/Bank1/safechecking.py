"""
File: restrictedsavingsaccount.py
This module defines the RestrictedSavingsAccount class.
"""

class SafeChecking():
    """This class represents a restricted savings account."""

    MAX_WITHDRAWALS = 3
        
    def __init__(self, balance = 0.0):
        """Same attributes as SavingsAccount, but with
        a counter for withdrawals."""
        self.counter = 0

    def withdraw(self, amount):
        """Restricts number of withdrawals to MAX_WITHDRAWALS."""
        pass
    
    def getBalance(self):
        """Returns the current balance."""
        return self.balance

    def __str__(self):
        """Returns the string rep."""
        result = '\tRestricted Savings Balance: $' + str(self.balance)
        return result

    
    def resetCounter(self):
        """Resets the counter to 0."""
        self.counter = 0
