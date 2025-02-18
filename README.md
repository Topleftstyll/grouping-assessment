# Grouping Assessment

I thought it would be a good idea to show the progression I've made over the last 2.5 years here at Zipline by linking my CSE assessment.
- [CSE Assessment](/grouping/cse-hiring-assessment.rb)


# Summary
hire_josh.rb can be called by using flags, example: `./hire_josh -m MATCH_TYPE -f FILE_NAME`
MATCH_TYPES = same_email, same_phone, same_email_or_phone.

These match types will find all users that match on all headers associated with the match type and assign an ID to those users. Any user not matching another user by one of those values with receive a unique ID.

# Usage
From the root folder in the command line:
```
  Example:
    ./hire_josh.rb -m same_email -f file.csv

  Help:
    ./hire_josh.rb -h
    -m, --match MATCH_TYPE           Specify the match type (same_email, same_phone, same_email_or_phone)
    -f, --file FILE                  Specify the CSV input file
    -h, --help                       Prints this help message
```

# Special Notes
I used UnionFind w/ path compression for the matching algorithm - [Video](https://www.youtube.com/watch?v=VHRhJWacxis&list=PLDV1Zeh2NRsBI1C-mR6ZhHTyfoEJWlxvq&index=4) on how UnionFind works.

Phone numbers are assumed to have a country code of +1. This should be changed to something more dynamic in the future.

