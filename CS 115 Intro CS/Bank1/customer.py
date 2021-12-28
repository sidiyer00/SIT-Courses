from savingsaccount import SavingsAccount
from safechecking import SafeChecking
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
        """Adds the specified account to the bank. (Checking, Relations, Savings, Restricted)"""
        if type == "Checking":
            self.accounts["Checking"] = CheckingAccount()
        elif type == "Relations":
            self.accounts["Relations"] = CheckingRelationship()
        elif type == "Savings":
            self.accounts["Savings"] = SavingsAccount()
        elif type == "Restricted":
            self.accounts["Restricted"] = SafeChecking()
        else:
            print("Invalid type of account")
    
    def removeAccount(self, type):
        del self.accounts[type]

    def deposit(self, amount, type):
        self.accounts.get(type).deposit(amount)
        self.total += amount
    
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
        output = str(self.name) + " (" + str(self.pin) + "): \n"
        for accnt in self.accounts.values():
            output += str(accnt) + '\n'
        return output

    # getters and setters
    def getName(self):
        return self.name
    def getDoB(self):
        return self.dob
    def getPIN(self):
        return self.pin
    
    def getPhone(self):
        return self.phone
    def setPhone(self, ph):
        self.phone = ph

    def getEmail(self):
        return self.email
    def setEmail(self, em):
        self.address = em


        