class CheckingRelationship(object):
    def __init__(self, overdraft, balance = 0.0):
        """This function initializes the Checking Relationship account"""
        self.balance = balance
    
    def getBalance(self):
        """Returns the current balance."""
        return self.balance

    def __str__(self):
        """Returns the string rep."""
        result = '\tChecking Relationship Balance: $' + str(self.balance)
        return result
