
# coding: utf-8

# In[ ]:


#1.	Load the python libraries - Done (Data pulled is only for top 200 for 2012)
#2.	Create dummy variables and account for missing data - created a dummy variable and appended to my dataframe. Also 
#3.	Describe your data - Done
#4.	Which of our variables are potentially collinear? - After reviewing correlation, it is clear that a few of my 
#datapoints are collinear, especially since a few of them relate specifically to each other. The total score would
#naturally relate to the world rank, and teaching/research also tie into the world rank and total score closely 
#international_students and international would also be collinear
#5.	Create an exploratory analysis plan of your data - Will use various charting options to look further at data
#6.	What is your hypothesis? - My hypothesis is that number of students will have no impact on a school's rank
#I also think that the larger a school, the higher their student / staff ratio will be 
#7.	Bonus: Test your hypothesis with Logistic Regression


# In[128]:


# importing needed libraries
import pandas as pd
import numpy as np


# In[132]:


# read in my CSV files for analysis and check for null values
db2012 = pd.read_excel('times_2012.xlsx')
db2012


# In[133]:


#checking datatypes
db2012.dtypes


# In[114]:


# describe each dataset for high level overview
db2012.describe()


# In[115]:


db2012.isnull().sum()


# In[152]:


#shape after dropping null values
db2012.dropna(inplace=True)
db2012


# In[147]:


db2012.shape


# In[148]:


#creating new dataframe w/ made up valus
new = pd.DataFrame({'world_rank':[250],'university_name':['Scrivner School of Business'],'country':['United States'],'teaching':['27'],'international':[28],'research':[29],'citations':[30],'income':[31],'total_score':[34],'num_students':[7],'student_staff_ratio':[.01],'international_students':[.5],'year':[2012]})
new


# In[149]:


#append the new dataframe to my existing dataframe
db2012.append(new,verify_integrity=False)


# In[153]:


#review dataframe w/o the newly added row
db2012.loc[db2012.world_rank < 249]


# In[157]:


db2012.corr()


# In[158]:


#let's do some plotting
import matplotlib.pyplot as plt


# In[162]:


#looking to see if there is any trend between # of students and rank
plt.scatter(db2012[['num_students']], db2012[['world_rank']])
plt.xlabel('Students')
plt.ylabel('World Rank')
plt.title('Students vs World Rank')
plt.show()
#As expected, there appears to be no correlation between # of stuudents vs world rank. 


# In[163]:


plt.scatter(db2012[['student_staff_ratio']], db2012[['world_rank']])
plt.xlabel('Student/Staff Ratio')
plt.ylabel('World Rank')
plt.title('Student/Staff Ratio vs World Rank')
plt.show()
#There appears to be a slight correlation, let's investigate this further


# In[164]:


#histogram of staff/student ratio, label y as frequency
plt.hist(db2012['student_staff_ratio'])
plt.ylabel('Frequency')
plt.title('Distribution of Student / Staff Ratio Values')
plt.show()
#Definitely seems to be a high concentration from 0-20 that falls off sharply after 25.


# In[165]:


# from sklearn import linear model
from sklearn import linear_model


# In[182]:


# use linear_model.LinearRegression() - fit the data
lm = linear_model.LinearRegression()
lm.fit(db2012[['student_staff_ratio']], db2012['world_rank'])


# In[183]:


# find the predicted Y values - lm.predict(X)
predict_y = lm.predict(db2012[['world_rank']])


# In[184]:


#array of predicted Y values
predict_y


# In[185]:


# based on the previous fit, it predicts the y value based on the student/staff ratio of 15 
lm.predict(15)
# this seems fairly consistent with the histogram of our data, as it appears 15 is near the median value
# and our median world rank value is 100.5 db2012.world_rank.median()


# In[192]:


#truth vs predicted - make sure the the relationship looks symmetric around a line
#scatterplot of db['y'] and y_pred
plt.scatter(predict_y, db2012['student_staff_ratio'])
plt.show()
# It doesn't look like the student / staff ratio has a significant impact on rank. But what about on the total # 
# of students?


# In[203]:


# use linear_model.LinearRegression() - fit the data
lm = linear_model.LinearRegression()
lm.fit(db2012[['num_students']], db2012['student_staff_ratio'])


# In[204]:


# find the predicted Y values - lm.predict(X)
predict_y2 = lm.predict(db2012[['student_staff_ratio']])


# In[205]:


predict_y2


# In[207]:


lm.predict(25000)
# again, this is consistent with our data as we are using the median number of students, and the predicted 
# number is near the median number of student/staff ratio db2012.student_staff_ratio.median()


# In[198]:


#histogram of number of students, label y as frequency
plt.hist(db2012['num_students'])
plt.ylabel('Frequency')
plt.title('Distribution of Number of Students Values')
plt.show()
# this is a little bit more evenly distributed around our median of ~21k


# In[209]:


#find the residual y_pred - y_truth
resid = predict_y2 - db2012['student_staff_ratio']


# In[210]:


plt.hist(resid)
plt.show()
#somewhat normal but one-tailed distribution


# In[212]:


# r squared using lm.score (X, y)
# this states that only about 9% of the variation of y (student/staff ratio) is explained by the X (number of students)
# variable
lm.score(db2012[['num_students']], db2012['student_staff_ratio'])
# This makes it clear that there is no transparent relationship between our number of students and the student / 
# staff ratio.


# In[215]:


# let's look at relationship between a few different variables and our world_rank
lm.fit(db2012[['student_staff_ratio','international_students','num_students']], db2012['world_rank'])


# In[216]:


predict_y3 = lm.predict(db2012[['student_staff_ratio','international_students','num_students']])


# In[217]:


predict_y3


# In[219]:


lm.score(db2012[['student_staff_ratio','international_students','num_students']], db2012['world_rank'])
# Even by including two additional varables relating to the student population, it seems to have doubled our impact
# to the variation experienced in the world_rank, but still only 19% of that variation can be explained by the
# relationship to these three variables.


# In[220]:


# Let's take the 4 of the datapoints that relate to the total score:
lm.fit(db2012[['teaching', 'research', 'citations', 'income']], db2012['world_rank'])


# In[221]:


predict_y4 = lm.predict(db2012[['teaching', 'research', 'citations', 'income']])


# In[222]:


lm.score(db2012[['teaching', 'research', 'citations', 'income']], db2012['world_rank'])
# As expected, there is a large impact on the world_rank variability, 87% specifically, that can be attributed to these
# 4 variables. This indicates that if you have a way to measure these four scores, you have a good chance of being able
# to predict the school's world rank.


# In[230]:


# the min for each of my columns checked is in the teens or low 20s, so let's shoot for a prediction that doesn't
# already fall within our dataset, how about a very poorly ranked school?
lm.predict([[1,1,1,1]])
# this predicts the school will be ranked 310, which is pretty bad considering we're looking specifically at the top 200
# we should keep in mind that the scores are unlikely to scale that steeply when moving past the top 200

