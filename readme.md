for the low fre low score group, 

I'm recommending videos with the highest average 
* MV_ratio
* highest freq, (excluding those which they have watched)



# RecommendR

## Introduction

Due to relatively high dimensionality of the genres (total 33),
its computationally extensive to calculate the pairwise similarity of user viewing data based on the genres

We employ dimensionality reduction using Principal Component Analysis (PCA) to identify

In the first step carrying out PCA

## Methods

The package includes a **tools** folder which contains the genre2matrix perl executable compatible with minimum perl 5.8.

### genre2matrix (perl)

linux/osx command

```
$ perl genre2matrix --table inputTable --users --genres
```

windows command prompt

```
C:\> perl genre2matrix --table inputTable --users --genres
```

#### example 

##### inputTable

| UserID | Genres as a string                                                                          | the score |
| ---    | ----                                                                                        | ----      |
| 37     | Comedy (6g), Drama (9g), Idol Drama (1038g), Romance (18g), Taiwanese Drama (1043g)         | 26        |
| 37     | Drama (9g), Romance (18g)                                                                   | 14        |
| 37     | Drama (9g), Korean Drama (23g), Medical Drama (1040g)                                       | 1         |
| 37     | Drama (9g), Korean Drama (23g), Romance (18g)                                               | 1         |
| 37     | Action & Adventure (1g), Costume & Period (25g), Drama (9g), Romance (18g)                  | 7         |
| 37     | Drama (9g), Romance (18g)                                                                   | 11        |
| 37     | Action & Adventure (1g), Costume & Period (25g), Drama (9g), Korean Drama (23g)             | 6         |
| 37     | Entertainment (10g), Lifestyle & Variety (14g), Romance (18g), Variety Show (1044g)         | 1         |
| 37     | Comedy (6g), Drama (9g), Idol Drama (1038g), Korean Drama (23g), Music (17g), Romance (18g) | 42        |
| 37     | Comedy (6g), Idol Drama (1038g), Korean Drama (23g), Romance (18g), SciFi & Fantasy (19g)   | 64        |

##### users

original csv provided in the challenge


| userid | country    | gender |
| ---    | ---        | ---    |
| 1      | Country001 | None   |
| 2      | Country002 | None   |
| 3      | Country001 | None   |
| 4      | Country003 | None   |
| 5      | Country001 | None   |
| 6      | Country004 | None   |


## Output

In the examples folder we have included the output of the recommendR procedure
