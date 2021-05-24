-- 01 Retrieve the start times of members' bookings
select bks.starttime
from cd.bookings bks
    join cd.members mems on mems.memid = bks.memid
where mems.firstname = 'David'
    and mems.surname = 'Farrell';
-- 02 Work out the start times of bookings for tennis courts
select bks.starttime as start,
    name
from cd.bookings bks
    join cd.facilities fcs on bks.facid = fcs.facid
where name like '%Tennis Court%'
    and starttime >= '2012-09-21'
    and starttime < '2012-09-22'
order by starttime;
-- 03 Produce a list of all members who have recommended another member
select firstname,
    surname
from cd.members
where memid in (
        select distinct recommendedby
        from cd.members
    )
order by surname,
    firstname;
-- 04 Produce a list of all members, along with their recommender
select a.firstname as memfname,
    a.surname as memsname,
    b.firstname as recfname,
    b.surname as recsname
from cd.members a
    left join cd.members b on a.recommendedby = b.memid
order by a.surname,
    a.firstname;
-- 05 Produce a list of all members who have used a tennis court
select distinct mems.firstname || ' ' || mems.surname as member,
    facs.name as facility
from cd.members mems
    join cd.bookings bks on mems.memid = bks.memid
    join cd.facilities facs on bks.facid = facs.facid
where facs.name like 'Tennis Court %'
order by member,
    facility;
-- 06 Produce a list of costly bookings
select mems.firstname || ' ' || mems.surname as member,
    facs.name as facility,
    case
        when mems.memid = 0 then bks.slots * facs.guestcost
        else bks.slots * facs.membercost
    end as cost
from cd.members mems
    join cd.bookings bks on mems.memid = bks.memid
    join cd.facilities facs on bks.facid = facs.facid
where bks.starttime >= '2012-09-14'
    and bks.starttime < '2012-09-15'
    and (
        (
            mems.memid = 0
            and bks.slots * facs.guestcost > 30
        )
        or (
            mems.memid != 0
            and bks.slots * facs.membercost > 30
        )
    )
order by cost desc;
-- 07 Produce a list of all members, along with their recommender, using no joins.
select distinct mems.firstname || ' ' || mems.surname as member,
    (
        select recs.firstname || ' ' || recs.surname as recommender
        from cd.members recs
        where recs.memid = mems.recommendedby
    )
from cd.members mems
order by member;
-- 08 Produce a list of costly bookings, using a subquery
select member,
    facility,
    cost
from (
        select mems.firstname || ' ' || mems.surname as member,
            facs.name as facility,
            case
                when mems.memid = 0 then bks.slots * facs.guestcost
                else bks.slots * facs.membercost
            end as cost
        from cd.members mems
            inner join cd.bookings bks on mems.memid = bks.memid
            inner join cd.facilities facs on bks.facid = facs.facid
        where bks.starttime >= '2012-09-14'
            and bks.starttime < '2012-09-15'
    ) as bookings
where cost > 30
order by cost desc;