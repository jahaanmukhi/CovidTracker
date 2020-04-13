import time, datetime
import requests
import csv, json 
from io import StringIO
import pandas as pd

def sleep(hour, minute):
    t = datetime.datetime.today()
    future = datetime.datetime(t.year,t.month,t.day,hour,minute)
    if t.hour >= hour:
        future += datetime.timedelta(days=1)
        time.sleep((future-t).seconds)

def watch_for_updates():
    """
    Waits until 8pm every day and updates the 
    data in the server.
    """
    while True:
        sleep(20, 30)
        update()
        time.sleep(60) 

def update():
    """
    Updates the data in the server.
    """
    # get data from the server
    # repo 
    # https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series
    
    US_confirmed = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
    global_confirmed = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
    US_deaths = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv"
    global_deaths = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
    #global_recovered = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv"   
   
    US_confirmed_df = pd.read_csv(StringIO(requests.get(url = US_confirmed).content.decode('utf-8')))
    US_deaths_df = pd.read_csv(StringIO(requests.get(url = US_deaths).content.decode('utf-8')))
    global_confirmed_df = pd.read_csv(StringIO(requests.get(url = global_confirmed).content.decode('utf-8')))
    global_deaths_df = pd.read_csv(StringIO(requests.get(url = global_deaths).content.decode('utf-8')))
    # change data into the correct json form
    
    US_df = pd.merge(filter_df(US_confirmed_df), \
            filter_df(US_deaths_df, deaths=True), \
            on=[ 'uid', 'fips', 'combined_key', 'country', 'state', 'state_abbr', 'county', 'latitude', 'longitude' ], \
            how='left')

    global_df = pd.merge(filter_df(global_confirmed_df, worldwide=True), \
            filter_df(global_deaths_df, deaths=True, worldwide=True), \
            on=[  'country', 'state', 'latitude', 'longitude' ], \
            how='left')

    covid_data = pd.merge(US_df, global_df, how='outer')

    covid_data.to_json('data/daily_data.json', orient='records')

    # save the data to the file

def filter_df(df, deaths=False, worldwide=False):

    if worldwide == True: 
        ### For Global confirmed cases and confirmed deaths dataframes 
        return filter_df_worldwide(df, deaths)

    else:
        ### For US confirmed cases and confirmed death dataframes 
        return filter_df_US(df, deaths)

def filter_df_worldwide(df, deaths):
    filters = ['Province/State','Country/Region','Lat','Long']

    if deaths == True:
        filters.append('Population')
        df['Population'] = df['Country/Region'].map(lambda country: global_populations[country]*1000 , na_action='ignore') 

    filtered_df = date_manipulation(df, deaths, filters)

    if deaths == True:
        rename = {  "Province/State" : "state",
                    "Country/Region": "country",
                    "Lat": "latitude",
                    "Long":  "longitude",
                    "daily_change": "daily_change_deaths",
                    "weekly_change": "weekly_change_deaths",
                    "Population": "population"
                }
    else: 
        rename = {  "Province/State" : "state",
                    "Country/Region": "country",
                    "Lat": "latitude",
                    "Long":  "longitude",
                    "daily_change": "daily_change_cases",
                    "weekly_change": "weekly_change_cases"
                }
    filtered_df.rename(columns=rename, inplace=True)
    return filtered_df

def filter_df_US(df, deaths):
    filters = ['UID', 'FIPS', 'Combined_Key', 'Country_Region', 'Province_State', 'Admin2', 'Lat', 'Long_']

    if deaths == True:
        filters.append('Population')

    filtered_df = date_manipulation(df, deaths, filters)

    if deaths == True:
        rename = {  "UID" : "uid",
                    "FIPS": "fips",
                    "Combined_Key": "combined_key",
                    "Country_Region":  "country",
                    "Province_State": "state",
                    "Admin2": "county",
                    "Lat": "latitude",
                    "Long_": "longitude",
                    "Population": "population",
                    "daily_change": "daily_change_deaths",
                    "weekly_change": "weekly_change_deaths"
                }
    else: 
        rename = {  "UID" : "uid",
                    "FIPS": "fips",
                    "Combined_Key": "combined_key",
                    "Country_Region":  "country",
                    "Province_State": "state",
                    "Admin2": "county",
                    "Lat": "latitude",
                    "Long_": "longitude",
                    "daily_change": "daily_change_cases",
                    "weekly_change": "weekly_change_cases"
                }
    
    filtered_df.rename(columns=rename, inplace=True)
    filtered_df['state_abbr'] = filtered_df['state'].map(lambda state: us_state_abbrev[state], na_action='ignore')
    return filtered_df

def date_manipulation(df, deaths, filters):

    try:
        current_date_raw = datetime.datetime.now()
        day_before_raw = current_date_raw - datetime.timedelta(days = 1) 
        week_before_raw = current_date_raw - datetime.timedelta(days = 7) 
    
        current_date = current_date_raw.strftime("%-m/%-d/%y")
        day_before = day_before_raw.strftime("%-m/%-d/%y")
        week_before = week_before_raw.strftime("%-m/%-d/%y")

        filters_with_current = list(filters)
        filters_with_current.append(week_before)
        filters_with_current.append(day_before)
        filters_with_current.append(current_date)
        slice_df = df[filters_with_current]
        filtered_df = pd.DataFrame(slice_df)
    
        filtered_df['daily_change'] = filtered_df[current_date] - filtered_df[day_before]  
        filtered_df['weekly_change'] = filtered_df[current_date] - filtered_df[week_before]
        if deaths == True:
            filtered_df.rename(columns={current_date : 'confirmed_deaths'}, inplace = True)
        else:
            filtered_df.rename(columns={current_date : 'confirmed_cases'}, inplace = True)  
        filtered_df.drop([day_before, week_before], axis=1, inplace=True)
        
        return filtered_df
    
    except KeyError:
        yesterday = current_date_raw - datetime.timedelta(days = 1) 
        two_days_ago = current_date_raw - datetime.timedelta(days = 2) 
        week_before_raw = current_date_raw - datetime.timedelta(days = 8) 


        yesterday = yesterday.strftime("%-m/%-d/%y")
        two_days_ago = two_days_ago.strftime("%-m/%-d/%y")
        week_before = week_before_raw.strftime("%-m/%-d/%y")

        filters_with_yesterday = list(filters)
        filters_with_yesterday.append(week_before)
        filters_with_yesterday.append(two_days_ago)
        filters_with_yesterday.append(yesterday)
        slice_df = df[filters_with_yesterday]
        filtered_df = pd.DataFrame(slice_df)
        
        filtered_df['daily_change'] = filtered_df[yesterday] - filtered_df[two_days_ago]  
        filtered_df['weekly_change'] = filtered_df[yesterday] - filtered_df[week_before]  
        if deaths == True:
            filtered_df.rename(columns={yesterday : 'confirmed_deaths'}, inplace = True)
        else:
            filtered_df.rename(columns={yesterday : 'confirmed_cases'}, inplace = True)

        filtered_df.drop([two_days_ago, week_before], axis=1, inplace=True)
        
        return filtered_df


    


############################################

with open('us_state_abbreviations.json', 'r') as file1:
    us_state_abbrev = json.load(file1)

global_populations = {}
with open('global_populations.json', 'r') as file2: 
    global_populations = json.load(file2)

if __name__ == '__main__':
    update()