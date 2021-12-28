from savingsaccount import SavingsAccount
from restrictedsavingsaccount import RestrictedSavingsAccount
from checkingaccount import CheckingAccount
from checkingrelationship import CheckingRelationship

class Customer(object):
    def __init__(self, name, pin, address = None, phone = None, email = None, dob = None, employment = None):
        self.accounts = {}
        # essential info
        self.name = name
        self.pin = pin
        self.total = 0
        # non-essential info
        self.address = address
        self.phone = phone
        self.email = email
        self.dob = dob
        self.employment = employment

    def addAccount(self, type, balance = 0.0):
        """Adds the specified account to the bank. (Checking, Checking Relationship, Savings, Restricted Savings)"""
        if type == "Checking":
            self.accounts["Checking"] = CheckingAccount(self.name, self.pin, balance)
        elif type == "Checking Relationship":
            self.accounts["Checking Relationship"] = CheckingRelationship(self.name, self.pin, balance)
        elif type == "Savings":
            self.accounts["Savings"] = SavingsAccount(self.name, self.pin, balance)
        elif type == "Restricted Savings":
            self.accounts["Restricted Savings"] = RestrictedSavingsAccount(self.name, self.pin, balance)
        else:
            print("Invalid type of account")
    
    def deposit(self, amount, type):
        self.accounts.get(type).deposit(amount)
    
    def withdraw(self, amount, type):
        self.accounts.get(type).withdraw(amount)

    def getAccounts(self):
        """Returns the account from the bank,
        or returns None if the account does
        not exist."""
        return self.accounts

    def computeInterest(self):
        """Computes and returns the interest on
        all accounts."""
        pass

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

    def getAddy(self):
        return self.address
    def setAddy(self, addy):
        self.address = addy
    
    def getPhone(self):
        return self.phone
    def setPhone(self, ph):
        self.phone = ph

    def getEmail(self):
        return self.email
    def setEmail(self, em):
        self.address = em
    
    def getEmployment(self):
        return self.employment
    def setEmplyoment(self, emp):
        self.employment = emp


        