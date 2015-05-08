#!/usr/local/bin/python


def changeDateFormat(str):
    date = str.split(" ")
    indvDate = date[0].split("/")
    return indvDate[2]+"/"+indvDate[0]+"/"+indvDate[1]+" "+date[1]

