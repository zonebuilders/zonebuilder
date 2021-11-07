
# Reviewer B:

1.  The authors present a good case for a new zoning system, based on
    annuli and radii, forming a web-type structure called ClockBoard.
    This zoning system is said to be a new approach that would add to
    more popular grid-based and even-more-popular administrative zone
    system. The authors put forth an R package that allows users to
    create this system, and give two examples of air quality, and
    traffic casualties using the ClockBoard system.

2.  This paper is relevant to JOSIS because it takes on a fundamental
    GIScience representation issue, and is driven by technology. It is
    pertinent to the journal and I think readers would enjoy it.

3.  Because this paper is a bit theoretical, there is not much empirical
    evaluation. Regarding evaluation, there is no user study done, but
    perhaps there does not need to be at this juncture. The example of
    the clock board viz in Figure 6 is very helpful and illustrative of
    what this method could do for geographers. For figure 7, could the
    authors add what the traffic deaths look like with the more
    traditional administrative boundaries? This would help as well.

4.  The limitations section left me a bit wanting—there are significant
    limitations that should be pointed out more clearly. First, curved
    administrative boundaries do not work well with our ‘straight line’
    bounding boxes—the ridge shape is a bit hard and is divorced from
    natural features we are used to seeing (albeit not with grids).
    Secondly, and relatedly, many administrative units that we use tend
    to follow waterways or roads, making them quite handy dividers. This
    method does not allow for this. Also, we get quite a bit of
    knowledge about the city form (like poly-centricity and the expanse
    of the urban downtown) from these administrative units—that is lost
    with this method. A strange artifact, as well, are cities that are
    halved by a water body, like Chicago. They only get a half a clock,
    whereas another inland city gets a whole clock. These limitations
    need to be stated more clearly.

5.  I am not quite certain that the ‘meeting up’ portion of this paper
    serves as sufficient data for justifying this system, but perhaps
    others understood and were more convinced by it. It seems as though
    if you have city knowledge already it seems much easier to point out
    a landmark.

6.  Regarding significance, this paper is mid-level but I do find the
    paper to be very creative and original. the motivation for this work
    is well-founded and sufficient literature has been presented. I
    would suggest that authors include literature on bottom-up
    regionalization (that is, creating zones based on modularity
    partitioning of origin-destination networks) and
    ‘what-3-words’—pardon if I missed this. I would like to hear from
    more actual administrators who may use these new zones on what their
    opinion may be. It may help to interview a few.

7.  I suspect that the method will be useful, but in fewer cases than
    originally purported. One of the strongest features seems to be the
    earmarking system with the B3, F12, etc. which, as stated, is
    helpful to let the user know automatically how far from the city
    they are and what direction. This is a nice contribution. In
    addition, the arbitrary starting point of a grid is solved a bit by
    this method. Comparing across cities seems like a great use for this
    method.

8.  The presentation is generally good and clear to follow. Again, the
    limitations section should be more forthright, as this new method
    does have some significant drawbacks. I have a few recommendations:

9.  P 2: “…to represent lines of equal height, and…population density.”
    I found it odd to bring up contour lines when the authors are
    specifically talking about continuous space. I realize that these
    lines demarcate continuous space, but they are rarely used to
    actually do this. Please remove. At the same time, it is very
    undervalued that you cannot do table joins with the clockboard
    method, as you could when aggregating to existing units. (More for
    the limitations.)

10. P 3: OSM is also odd to bring up as ‘emerging datasets’—it doesn’t
    have any thematic data, which I think is a big selling point of your
    method. At least the case studies on pollution and traffic suggest
    so. Please substitute it.

11. P 3: Can you elaborate on reference \[21\], it sounds important.

12. P 3: Paragraph starting with “Pre-existing zoning systems” does not
    seem to belong here. It seems to need to come earlier.

13. P 4: “Modelling urban cities…” bullet point is quite vague and I’m
    not sure what it adds.

14. P 6: “The trueism is often reflected….” Census zones are way more
    popular than TAZes, I found this odd to mention TAZes instead.

15. Table 1: Please make it clearer that N. zones is cumulative.

16. —one part of ’o clock may need to be lowercased.

17. -P 8: does “Tokyo” call anything when it’s used as a variable in
    ClockBoard_Tokyo? Please clarify.

18. -Fig 8: Could you please provide a scale bar?

    # Reviewer C:

    This paper proposes a new process for subdividing metropolitan areas
    into monocentric, areally consistent regions to enable more easy
    cognition and orientation. I will provide comments below in the
    framework JOSIS provides.

    **Scientific and technical quality:** Is the submission technically
    sound? Are the submission's claims and conclusions adequately
    supported?

    The submission is technically comprehensive in terms of explaining
    the logics for deducing the rings and segments within each ring and
    how this would be comparable across cities. Fundamentally, this
    paper seems to be addressing the modifiable areal unit problem
    (MAUP) and makes an attempt to create generalized regions within the
    city. While I think the technical considerations of the MAUP is
    thoughtful, the submission’s main claims are not clear in terms of
    how this framework’s will resolve a broad range of use case issues
    in the current framing of this paper. Because I consider these
    issues to align more with “Evaluation” and “Significance” questions,
    I will address my main comments and concerns there.

19. One small point in this section: The authors did not explicitly
    state why the areal unit is problematic and it would be helpful for
    the reader to be explicit about stating this. The same holds true
    for authors’ mention of “continuous space” and why it is
    particularly important.

    **Evaluation:** Does the paper present an objective (experimental or
    theoretical) evaluation of its results? If not, how are the results
    evaluated, and is the evaluation convincing?

20. The authors state that “A number of approaches have tackled the
    question how to best divide up geographical space for analysis and
    visualization purposes, with a variety of applications.” (pg. 2),
    which seems to be one iteration of their objectives in this paper.
    On pg.4 of the paper, the authors seem to have another more specific
    set of criteria that drive the motivations or use cases for this new
    type of regionalization. It’s still not clear to me what is the
    primary motive for creating these zones are, as none of them seem to
    address the MAUP problem of regionalizing space.

21. While I think this may be beyond the scope of this paper, I think a
    true evaluation of the success of this framework would be something
    along the lines of a user survey in addition to explaining the
    technical rationale behind these spatial configurations. I see the
    main use case of the ClockBoard aligned with subjects like UX/UI
    design or a Lynchian study of how people make mental maps and
    navigate the city [1].

22. One aspect of the design of the framework that was unclear to me is
    the monocentric orientation of the city, with each region created
    based on distance from the city center. This type of spatial
    orientation seems mainly to apply to transit related fields or
    theoretical understandings where the distance to the “center of the
    city”. While I appreciate the importance of this type of analysis,
    it seems somewhat arbitrary and far from having “a variety of
    applications”. For instance, in most non-transit planning scenarios,
    the spatial configurations of certain types of communities (for ex:
    public housing) and their relationship to gentrifying areas is the
    primary way policy-makers think about the city. Another way to think
    about the city, for residents of a city, who might have a different
    mental map that is ego-centric, may be composed on landmarks around
    the city familiar to them.

23. A minor point regarding comparison across different cities: I don’t
    think the last paragraph on p.13 was clear in terms of what it is
    trying to show. It is not clear to me why the inclusion of the
    metropolitan region in this example shows the advantages of
    ClockBoard. Many urban administrative boundaries and maps only show
    certain areas because the broader metropolitan region is beyond its
    jurisdiction, which is not necessarily a limitation of
    administrative boundaries but the nature of governance systems.

    **Significance:** How important is the work reported? Does the
    submission address a challenging theoretical or practical issue?
    Does the work integrate ideas from, or have interesting implications
    across multiple disciplines?

24. The problem statement and the significance of this work is not quite
    clear to me: In the first paragraph, the authors seem to suggest
    that, because the process of creating areal units is contingent on
    the objective for creating the units, there is no one process that
    satisfies all possible objectives, which I don’t necessarily see as
    a technical problem but a governance or civic administration issue.
    Moreover, it is unclear why the authors choose to highlight the
    “blank slate” quality of this approach.

25. Fundamentally, the overall objective, target audience, and use cases
    are perhaps not what the authors suggest. The authors suggest a
    somewhat broad notion of “analysis” and “visualization”, but it
    seems to me that the ClockBoard proposal simultaneously proposes one
    way to address the MAUP problem that has a use case of navigating
    cities if one is not familiar with the city. It is difficult for me
    to image analysts working with these zones for inter-city comparison
    as the sample size is small. Thus, there is a discordance between
    the stated objective and what this framework produces.

    **Originality:** Does the submission address a new issue, present a
    new approach to an issue, or put forward a novel combination of
    existing ideas or techniques? Does the submission correctly situate
    itself within the context of existing research literature?

26. There is sufficient originality in this work to justify publication
    of the paper with edits to its framing. The paper mentions similar
    research and frameworks that are relevant. I think the authors
    should take care to limit the use cases and promises of this
    framework, for reasons previously mentioned.

    **Style and presentation:** Is the submission clearly written and
    logically structured? Does the submission provide adequate
    motivation and interesting conclusions? Are the results clearly
    described and critically evaluated?

27. A major issue with this paper is its structure in the introduction
    which I found very difficult to navigate given the diverse range of
    geographic aggregation issues (for ex: the section about lack
    consideration for point data in administrative boundaries), the
    “blank slate” nature of the framework, the “continuous space” issue,
    all of which seem somewhat tangentially related to the core
    questions at hand. Also, as I mentioned above, the objective of this
    paper is unclear.

28. Another major source of confusion is the use of the term ‘zones’ or
    ‘zoning’., In the urban context, it generally refers to a system of
    municipal land use regulation, which is then borne out in the
    specification of regions, and not necessarily the concept of
    discretizing space that addresses the MAUP problem suggested here,
    as I understand this paper.

29. Other minor stylistic notes:

    \- Should be ‘flexible’ (not ‘fexible’) in the abstract.

    \- pg.4 ‘miniminput’ should be ‘minimum input’ ?

    \- p.2 Not sure what ‘heigh’ is in reference to?

    **Scope and relevance to JOSIS:** Is the paper closely related to
    the themes of the journal? Is the content interesting to the journal
    readership? Is the submission written in a form readable for a
    multi-disciplinary audience?

30. With some reframing and reworking of the structure, I think this
    paper is appropriate for JOSIS and the content would be interesting
    to the journal’s readership. It presents applications that may be of
    interest to a general audience.

# References

[1] Kevin Lynch, *The Image of the City*, vol. 11 (Cambridge, MA: MIT
press, 1960).
