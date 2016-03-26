
## ...

**What I am Trying to Do** - A method of fitting trail speed observations from the Pacific Crest Trail (PCT) to a modified version of Tobler's hiking function. 

Given hiker observations (trail mile start, stop, and time between), and the PCT's elevation profile, this method estimates the Tobler hiking function for this hiker. It may be used for hiking speed projections later in the trail, or on other trails. It may be modified to accept hiking speed observations from other trails. 

The plan:

- the hiker records the time it takes to hike between PCT mile markers (or alternatively, a smart phone, satellite tracker, or GPS/GLONASS tracker this). 
    - this assumes continuous hiking between mile markers. That is the hiker takes a minimum of breaks during this spell,
    - I assume this is done about once an hour or so, but more granular observations lead to better fits. 
    - Observations along the lines: `Mile-Start`, `Mile-Stop`, `Time-Bwt-Markers`
- cut time observations over elevation profile
    - given the elevation profile of the PCT between these mile marker observations, map (cut up) observations to a granular observations between every elevation 
    - weighted by the portion of the trail at different slopes


## Modified Tobler's hiking function. 

Link to r markdown document. 

modified... include fixed effect of: 

- daily "fatigue".  How long has hiker been hiking that day? Generally assumes the longer time on the trail leads to slower pace. 
- overall "fitness". How many days as hiker been on trail? Generally assumes hikers who have been on the trail longer have faster paces. Hopefully, 
    - I'll assume an asymptotic relationship for effect of fitness (log fitness, I think). Early on the trail, increases in fitness improve pace more than later fitness increases. 
- "pack weight". May not include this, since it requires hiker to log daily packweight.... How does the weight of the pack affect hiking pace? Generally assumes a heavier pack slows pace.  May interacts with "fatigue" variable.  

## Data

#### Pacific Crest Trail Data

Used Halfmile dataset... link

KML trail data (2016)....


#### Elevation Profile

I got the PCT's elevation profile from a handy tool made by the [kind people at geocontext.org](http://www.geocontext.org/publ/2010/04/profiler/en/?import=kmz#). 

Here is my data (pulled from the 2016 PCT)


## Also See

#### [Tobler's hiking function](https://en.wikipedia.org/wiki/Tobler%27s_hiking_function) 

"Tobler's hiking function is an exponential function determining the hiking speed, taking into account the slope angle. It was formulated by Waldo Tobler."

#### [Naismith's rule](https://en.wikipedia.org/wiki/Naismith%27s_rule) 

"Naismith's rule is a rule of thumb that helps in the planning of a walking or hiking expedition by calculating how long it will take to walk the route, including the extra time taken when walking uphill. The rule assumes that travel will be on trails, footpaths, or reasonably easy ground; it is possible to apply adjustments or "corrections" for more challenging terrain, although it cannot be used for scrambling routes. In the grading system used in North America, Naismith's rule applies only to hikes rated Class 1 on the Yosemite Decimal System, and not to Class 2 or higher. The rule was devised by William W. Naismith, a Scottish mountaineer, in 1892.

The basic rule is as follows:

- Allow 1 hour for every 5 kilometers (3.1 mi) forward, plus 1 hour for every 600 meters (2,000 ft) of ascent.
- When walking in groups, calculate for the speed of the slowest person."

