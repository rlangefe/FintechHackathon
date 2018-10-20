import numpy as np
import pandas as pd
from sklearn.neighbors import KNeighborsClassifier
import datetime
import time

class Charge:
    name = ''
    cost = 0
    count = 1
    first_date = datetime.datetime.now()
    last_date = datetime.datetime.now()

    def __init__(self, n, c, d):
        self.name = n
        self.cost = c
        self.date = d

    def check(self, n, d, c):
        if(self.name == n) and (self.cost == c):
            self.add(d)
            return True
        else:
            return False

    def add(self, d):
        self.last_date = d
        self.count += 1

    def print(self):
        return self.name + ',' + self.cost + ',' + self.first_date + ',' + self.last_date + ',' + self.count


class TrainCharge(Charge):
        sub = 0

        def __init__(self, n, c, d, s):
            self.name = n
            self.cost = c
            self.date = d
            self.sub = s


#################################
def main():
    data = pd.read_csv("TransData.csv")
    chargeList = []
    data['Date'] = pd.to_datetime(data['Date'])

    for i in range(6001):
        if(data.iloc[i]['Name']!='-'):
            name = data.iloc[i]['Name']
            cost = data.iloc[i]['Amount']
            date = data.iloc[i]['Date']
            sub = data.iloc[i]['Is Subscription or Not']
            added = 0
            for x in chargeList:
                if x.check(name, date, cost):
                    added = 1
            if added != 1:
                chargeList.append(TrainCharge(name, cost, date, sub))

    #formattedData = pd.DataFrame(columns=['Name', 'Amount', 'Frequency', 'Subscription'])
    X_data = []
    y_data = []
    for x in chargeList:
        #formattedData.append({'Name' : x.name}, {'Amount' : x.cost}, {'Frequency' : ((x.first_date - x.last_date)/x.count)}, {'Subscription' : x.sub})
        X_data.append([x.cost, ((x.first_date - x.last_date)/x.count).total_seconds()])
        y_data.append(x.sub)

    #X = np.array(X_data)
    #y = np.array(y_data)
    neigh = KNeighborsClassifier(n_neighbors=3)
    neigh.fit(X_data, y_data)

    chargeList = []

    for i in range(6002, 12133):
        if (data.iloc[i]['Name'] != '-'):
            name = data.iloc[i]['Name']
            cost = data.iloc[i]['Amount']
            date = data.iloc[i]['Date']
            sub = data.iloc[i]['Is Subscription or Not']
            added = 0
            for x in chargeList:
                if x.check(name, date, cost):
                    added = 1
            if added != 1:
                chargeList.append(TrainCharge(name, cost, date, sub))

    X_data = []
    y_data = []
    listOfNames = []
    for x in chargeList:
        # formattedData.append({'Name' : x.name}, {'Amount' : x.cost}, {'Frequency' : ((x.first_date - x.last_date)/x.count)}, {'Subscription' : x.sub})
        listOfNames.append(x.name)
        X_data.append([x.cost, ((x.first_date - x.last_date) / x.count).total_seconds()])
        y_data.append(x.sub)

    #X = np.array(X_data)
    #y = np.array(y_data)

    f = open('output.txt', 'w')
    result = neigh.predict(X_data)
    for q in range(len(X_data)):
        output = listOfNames[q] + ' ' + str(result[q]) + ' ' + str(y_data[q]) + '\n'
        f.write(output)

    print(neigh.score(X_data, y_data))


if __name__ == '__main__':
    main()
