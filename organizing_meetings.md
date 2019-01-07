# Readings on Gaussian Processes - Organizing meetings logs

## 2018-11-07 (G, J, N, L)

First meeting. We discussed of the ideas I sent by email (e.g. dynamics, periodicity). We agree to meet every Wednesday at 3:10 pm.

For next meeting:
- Make a broad schedule for the next semester, including the name of the big topics/themes and a tentative time allocation.

## 2018-11-14 (J, N, L)

We went over the four proposed schedules and identified the common topics (see below). With respect to order, we generally agreed that a simple-to-complex (i.e. start small) approach would be best. We noticed that we should be pessimistic about time allocation as topics will probably take longer than expected. We also agreed that it's better to focus on application papers and discuss theory along the way (e.g. we discuss MLE along with some application instead of having one session devoted to inference, we select several applications using different covariance functions instead of having one session to exclusively discuss covariance functions).

For next meeting on W 11/28, we need to propose papers for these topics:

- Weeks 1-2: Intro to GP. Nate.
- Weeks 3-4: Applications on regression and/or time series. Focus on the 1d-input case. Luis.
- Weeks 5-6: Applications on spatial data. Focus on the 2d-input case. Mattern function. Jarad.
- Weeks 7-8: Applications on multiple regression. Focus on the +2d-input case. Jarad.
- Weeks 9-10: Applications on computer experiments. Gulzina.
- Weeks 11-12: Applications on classification. Focus on the binary case. Gulzina.
- Weeks 13-14: Applications on point processes. Nate.
- Weeks 15-16: GP for big data. Focus on approximations due to computational complexity. Luis.

One question remained open: how much do we want to cater this reading group to a broader audience? We vaguely mentioned that our main interest is the computational side of GPs, but the current list is broad and general. Although we agreed that we will partially profit from exposure to more broad applications, we don't exploit the group for our interests. We mentioned that some of the most simple topics could be collapsed to make room for more intermediate/advanced material. I propose we think over this for next meeting.

## 2018-11-28

Cancelled.

## 2018-12-05 (G, J, N, L)

We went over the candidate material:

- Intro to GP. Nate presented an introductory paper written by MacKay based on a univariate non-linear model, but it had some details that may be hard to discuss in our first meeting. Jarad mentioned picking a chapter from Rassmussen as an alternative.
- Time series. Luis presented a paper by Roberts that seemed good for an introduction to GPs. We discussed using this paper for the first session.
- Spatial. Jarad mentioned that the original papers are very relevant, yet perhaps too hard for the first part of the reading plan. He couldn't find a suitable paper and suggested a chapter from Banerjee.
- Multivariate regression. Not many papers. 
- Computer experiments. Gulzina proposed Kennedy-O'Hagan.
- Applications on classification. We agreed that we should focus on the binary case. Gulzina will try to find a paper.
- Applications on point processes. Nate proposed Deable (??) 2014 which includes a comparison of MCMC and INLA for spatial point process.
- GP for big data. Luis found three very good candidates, including one with a theoretical review of most methods and another lighter on theory but with a simulation experiment. Recommended the latter.

We realized that finding good material for the first sessions are difficult. In general, there are not many accessible applications. We mentioned that we may mentioned "optional" extra readings for those interested. We also agreed on creating a file in the repository with the tentative schedule where each person can list the papers. Nate and Luis will discuss the first four weeks during the break.

We decided that the best time for meeting would be T/R 4-5 starting on the second week of the semester. We would send an email to statfacl and statgrad to invite.

## 2018-12-13 (N, L)

Discusssion about the introductory block (first four weeks). We easily agreed on starting with Roberts.

Tentative outline:

-  Session I: Intro: Roberts section 2 to 3.1. Short, very informative and helpful.
-  Session II: An interactive meeting to build intuition. Nate will clean some R code of his to create an exploratory example.
-  Session III: Revisiting theory from a more principled point of view -- some sections from Chapter 2 Rasmussen. Defining terminology.
-  Session IV: Applications univariate case. Luis will look for a paper.

------
