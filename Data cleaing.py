import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import pymysql
import numpy as np

# Customer csv

df_customer = pd.read_csv("D:/Project/DataSpark/DataSet-20241129T144729Z-001/DataSet/Customers.csv", encoding="Windows-1252")
df_customer.isnull().sum()
df_customer["Birthday"] = pd.to_datetime(df_customer["Birthday"],format= None , errors="coerce").dt.date
df_customer.dropna(inplace=True)
df_customer


# product csv

df_product = pd.read_csv("D:/Project/DataSpark/DataSet-20241129T144729Z-001/DataSet/Products.csv")

df_product.isnull().sum()

df_product.dropna(inplace=True)

# replace $s symbol and space and converting to float

df_product[["Unit Cost USD","Unit Price USD"]] = df_product[["Unit Cost USD","Unit Price USD"]].replace({"\$":"",",":""," ": ""} , regex= True).astype("float64")
df_product.dtypes

# sales scv

df_sales = pd.read_csv("D:/Project/DataSpark/DataSet-20241129T144729Z-001/DataSet/sales.csv")

df_sales.isnull().sum()
df_sales.dropna()

df_sales.isnull().sum()[df_sales.isnull().sum() > 0]/len(df_sales)

# column delivery sate contains more 70% as null values so i drop that column
if "Delivery Date" in df_sales.columns:
    df_sales.pop("Delivery Date")

df_sales["Order Date"] = pd.to_datetime(df_sales["Order Date"], format=None, errors="coerce").dt.date

df_sales.head(15)
df_sales.dtypes



# stores csv 

df_stores = pd.read_csv("D:/Project/DataSpark/DataSet-20241129T144729Z-001/DataSet/stores.csv")

df_stores.isnull().sum()

df_stores[df_stores.isnull().any(axis=1)].index

# for online store assining the square meter as 0

df_stores.loc[66,"Square Meters"] = 0
df_stores.isnull().sum()

df_stores["Open Date"] = pd.to_datetime(df_stores["Open Date"],format= None , errors="coerce").dt.date

df_stores.dtypes


# Exchange rates csv

df_exchange = pd.read_csv("D:/Project/DataSpark/DataSet-20241129T144729Z-001/DataSet/exchange_rates.csv")
df_exchange.isnull().sum()
df_exchange["Date"] = pd.to_datetime(df_exchange["Date"], format= None , errors="coerce").dt.date
df_exchange.dtypes





# def for mysqlconnect 

def mysqlconnect(df,table_name):  

    myconnection = pymysql.connect(host = "127.0.0.1" ,user = "root" , password = "Logesh007$")

    myconnection.cursor().execute("create database if not exists Dataspark")
    myconnection.cursor().execute("use Dataspark")


    col = [i.replace(" ","_") for i in df.columns]
    columns = ", ".join(f"{i} {j}" for i,j in zip(col,df.dtypes))

    python_to_sql = {"float64":"FLOAT",
                     "int64":"INT",
                    "object":"VARCHAR(300)",
                    "datetime64[ns]":"DATETIME",
                    }

    columns = ", ".join(f"{i} {python_to_sql[str(j)]}" for i,j in zip(col,df.dtypes))
    columns

    table_name = table_name

    myconnection.cursor().execute(f"create table if not exists {table_name} ({columns})")

    for i in range(len(df)):
        row = tuple(df.iloc[i].apply(lambda x: int(x) if isinstance(x,np.int64) else float(x) if isinstance(x,np.float64) else str(x)))
        myconnection.cursor().execute(f"insert into {table_name} values {row}")
    myconnection.commit()
    


mysqlconnect(df_customer,"customer")
mysqlconnect(df_product,"product")
mysqlconnect(df_sales,"sales")
mysqlconnect(df_stores,"stores")
mysqlconnect(df_exchange,"exchange")