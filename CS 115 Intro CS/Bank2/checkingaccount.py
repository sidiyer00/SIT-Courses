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
- checkingaccount.py

Description:
- this file is a checking account class...it keeps track of balance and monthly fees 
- the users withdraws / deposits from here
"""

class CheckingAccount:

    def __init__(self, balance = 0.0):
        """This function initializes the Checking account"""
        self.balance = balance
        self.CHECKING_MONTHLY_FEE = 12

    def __str__(self):
        """Returns the string rep."""
        result = '\tChecking Balance: $' + str(self.balance)
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
            return None

    def chargeMonthlyFee(self):
        if self.balance >= 1500:
            return
        else:
            self.balance -= self.CHECKING_MONTHLY_FEE
            print("A monthly fee of $12 has been charged to your account")



    
    
    
