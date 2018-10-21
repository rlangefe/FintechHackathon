import pandas as pd
from sklearn.neighbors import KNeighborsClassifier
import datetime
from sklearn.externals import joblib
import warnings

class Charge:
    name = ''
    cost = 0
    count = 1
    first_date = datetime.datetime.now()
    last_date = datetime.datetime.now()

    def __init__(self, n, c, d):
        self.name = n
        self.cost = float(c)
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


class TrainCharge(Charge):
        sub = 0

        def __init__(self, n, c, d, s):
            self.name = n
            self.cost = c
            self.date = d
            self.sub = s


#################################
def main():
    warnings.simplefilter('ignore')
    data = pd.read_csv("TransData.csv")
    chargeList = []
    data['Date'] = pd.to_datetime(data['Date'])

    for i in range(data[data['Name'] == '-'].index.values.astype(int)[0]):
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
        X_data.append([float(x.cost), ((x.first_date - x.last_date)/x.count).total_seconds(), x.count])
        y_data.append(x.sub)

    from sklearn.neural_network import MLPClassifier
    #neigh = MLPClassifier(solver='lbfgs', alpha=1e-5, hidden_layer_sizes = (5, 2), random_state = 1, learning_rate='adaptive')
    neigh = KNeighborsClassifier(n_neighbors=3, weights='distance', n_jobs=20)
    neigh.fit(X_data, y_data)

    filename = "finalized_model.sav"
    joblib.dump(neigh, filename)

    f = open('output.txt', 'w')
    for v in range(1, 9):
        chargeList = []

        for i in range(data[data['Name'] == '-'].index.values.astype(int)[v-1]+1, data[data['Name'] == '-'].index.values.astype(int)[v]):
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
            X_data.append([float(x.cost), ((x.first_date - x.last_date) / x.count).total_seconds(), x.count])
            y_data.append(x.sub)

        actual = 0
        correct = 0
        result = neigh.predict(X_data)
        for q in range(len(X_data)):
            output = listOfNames[q] + ' ' + str(result[q]) + ' ' + str(y_data[q]) + '\n'
            if result[q] != y_data[q]:
                f.write(output)
            if y_data[q] == 1.0:
                actual += 1
                if result[q] == 1.0:
                    correct += 1

        print('' + str(v) + ' ' + str(float(correct)/actual) + ' ' + str(neigh.score(X_data, y_data)) + '\n')


if __name__ == '__main__':
    main()
