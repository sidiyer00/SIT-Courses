class CheckingRelationship(object):
    def __init__(self, name, pin, balance = 0.0):
        """This function initializes the Checking Relationship account"""
        self.name = name
        self.pin = pin
        self.balance = balance
    
    def __str__(self):
        """Returns the string rep."""
        result = '\tChecking Relationship Balance: $' + str(self.balance)
        return result
