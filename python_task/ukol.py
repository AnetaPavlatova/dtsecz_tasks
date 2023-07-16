#Use requests lib for downloading from web
import requests
#use openpyxl for openXML 
from openpyxl import load_workbook
#use pandas for data procesing
import pandas as pd

#for graphs
import matplotlib.pyplot as plt




#set proxy if any
proxies = {
  # 'http': 'http://proxy.example.com:8080',
}
url = 'https://covid.ourworldindata.org/data/owid-covid-data.xlsx'


#download data using requests, save to loacal file
response = requests.get(url, proxies=proxies)
open("owid-covid-data.xlsx", "wb").write(response.content)



# load open XML document
#wb = load_workbook(filename = 'owid-covid-data_1.xlsx')
wb = load_workbook(filename = 'owid-covid-data.xlsx')
# load first sheet
ws = wb[wb.sheetnames[0]]

data = pd.DataFrame(ws.values)


# Make the first data row as column header
data.columns = data.iloc[0]

# Drop the first row
data = data.iloc[1:]

# Reset the DataFrame index
data.reset_index(drop=True, inplace=True)


data['new_cases'] = pd.to_numeric(data['new_cases'], errors='coerce')

# Calculate the mean of 'new_cases' column
avg_new_cases = data['new_cases'].mean()
#print(avg_new_cases) 

# Make sure the 'date' column is in datetime format
data['date'] = pd.to_datetime(data['date'])

week_ago = data['date'].max() - pd.DateOffset(days=7)
last_week_data = data[data['date'] > week_ago]


# Calculate the average new cases in the last week for each location
weekly_cases_per_locations = last_week_data.groupby('location')['new_cases'].sum()

population_per_locality = pd.merge(data[['location', 'population']].drop_duplicates(), weekly_cases_per_locations, on='location')


population_per_locality_per_100k =population_per_locality['new_cases'] * 100000 / population_per_locality['population'];



for i in range(0, len(population_per_locality['location'])+1):
   print(f"Average new cases for last 7 days in {population_per_locality['location'].values[i] } per 100k : {population_per_locality_per_100k.values[i]} ")





population_per_locality['AvgNewCasesPer100k'] = population_per_locality['new_cases'] * 100000 / population_per_locality['population'];
df_top20 = population_per_locality.sort_values('AvgNewCasesPer100k', ascending=False).head(20)


fig,ax = plt.subplots(nrows=1,ncols=2,figsize=(14,6))

ax[0].bar(list(df_top20['location']), list(df_top20['population']), color ='maroon',width = 0.4)
ax[0].set_title('Population of Top 20 States')
ax[0].set_xlabel('State')
ax[0].set_ylabel('Population')
ax[0].tick_params(axis='x', rotation=90)

ax[1].bar(list(df_top20['location']), list(df_top20['new_cases']), color ='blue',width = 0.4)

ax[1].set_title('Avg New Cases per 100k in a Week for Top 20 States')
ax[1].set_xlabel('State')
ax[1].set_ylabel('Avg New Cases per 100k in a Week')
ax[1].tick_params(axis='x', rotation=90)

plt.tight_layout()
plt.show()

