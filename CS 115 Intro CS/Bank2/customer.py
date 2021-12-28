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
- customer.py

Description:
- this file is a class called Customer; customer objects will be stored in Bank
- it keeps track of a user's accounts and other personal information
"""


from savingsaccount import SavingsAccount
from safechecking import CheckingRestricted
from checkingaccount import CheckingAccount
from checkingrelationship import CheckingRelationship

class Customer(object):
    def __init__(self, name, pin, age, phone, email, overdraft = "decline"):
        self.accounts = {}
        # essential info
        self.name = name
        self.pin = pin
        self.age = age
        self.total = 0
        # non-essential info
        self.phone = phone
        self.email = email
        self.overdraft = overdraft

    def addAccount(self, type, balance = 0.0):
        """Adds the specified account to the bank. (Checking, Relations, Restricted, Savings)"""
        if (type == "Checking" or type == "Relations" or type == "Restricted") and ("Checking" in self.accounts):
            print("You already have a Checking account")
            return
        elif(type == "Savings") and ("Savings" in self.accounts):
            print("You already have a Savings account")
            return

        if type == "Checking":
            self.accounts["Checking"] = CheckingAccount()
            print("Account added")
        elif type == "Relations":
            self.accounts["Checking"] = CheckingRelationship()
            print("Account added")
        elif type == "Restricted":
            self.accounts["Checking"] = CheckingRestricted()
            print("Account added")
        elif type == "Savings":
            self.accounts["Savings"] = SavingsAccount()
            print("Account added")
        else:
            print("Invalid type of account")
    
    def removeAccount(self, type):
        if (type == "Checking" or type == "Savings") and (type in self.accounts):
            del self.accounts[type]
            print("Account removed\n")
        else:
            print("Error")

    def deposit(self, amount, type):
        if type == "Checking" or "Savings":
            self.accounts.get(type).deposit(amount)
            self.total += amount
        else:
            print("Wrong")
    
    def withdraw(self, amount, type):
        if self.overdraft == "decline":
            if self.accounts.get(type).balance > amount:
                self.accounts.get(type).withdraw(amount)
                self.total -= amount
            else:
                print("You can't withdraw more than you have...transaction cancelled\n")
        elif self.overdraft == "standard":
            self.accounts.get(type).withdraw(amount)
            self.total -= amount


    def computeInterest(self):
        """Computes and returns the interest on
        all accounts."""
        rate_at_boa = .0003
        r = self.total * rate_at_boa
        self.total += r
        return r

    def __str__(self):
        output = "Your Customer Profile: \n"
        for accnt in self.accounts.values():
            output += str(accnt) + '\n'
        return output

    def chargeMonthlyFee(self):
        for accnt in self.accounts.values():
            accnt.chargeMonthlyFee()

    # getters and setters
    def getAge(self):
        return self.age
    def getDoB(self):
        return self.dob
    
    def getPhone(self):
        return self.phone
    def setPhone(self, ph):
        self.phone = ph

    def getEmail(self):
        return self.email
    def setEmail(self, em):
        self.address = em


        