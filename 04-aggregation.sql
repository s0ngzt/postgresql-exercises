-- 01 Count the number of facilities
select count(*) as count
from cd.facilities;
-- 02 Count the number of expensive facilities
select count(*) as count
from cd.facilities
where guestcost >= 10;
-- 03 Count the number of recommendations each member makes.
select recommendedby,
    count(*)
from cd.members
where recommendedby is not null
group by recommendedby
order by recommendedby;
-- 04 List the total slots booked per facility
select facid,
    sum(slots) as "Total Slots"
from cd.bookings
group by facid
order by facid;
-- 05 List the total slots booked per facility in a given month
select facid,
    sum(slots) as "Total Slots"
from cd.bookings
where starttime >= '2012-09-01'
    and starttime < '2012-10-01'
group by facid
order by sum(slots);
-- 06 List the total slots booked per facility per month
select facid,
    extract(
        month
        from starttime
    ) as month,
    sum(slots) as "Total Slots"
from cd.bookings
where extract(
        year
        from starttime
    ) = 2012
group by facid,
    month
order by facid,
    month;
-- 07 Find the count of members who have made at least one booking
select count(*)
from (
        SELECT DISTINCT memid
        from cd.bookings
    ) as mems;
-- simpler statement
select count(distinct memid)
from cd.bookings;
-- 08 List facilities with more than 1000 slots booked
select facid,
    sum(slots) as "Total Slots"
from cd.bookings
group by facid
having sum(slots) > 1000
order by facid;
-- 09 Find the total revenue of each facility
select facs.name,
    sum(
        slots * case
            when memid = 0 then facs.guestcost
            else facs.membercost
        end
    ) as revenue
from cd.bookings bks
    join cd.facilities facs on bks.facid = facs.facid
group by facs.name
order by revenue;
-- 10 Find facilities with a total revenue less than 1000
select name,
    revenue
from (
        select facs.name,
            sum(
                case
                    when memid = 0 then slots * facs.guestcost
                    else slots * membercost
                end
            ) as revenue
        from cd.bookings bks
            join cd.facilities facs on bks.facid = facs.facid
        group by facs.name
    ) as agg
where revenue < 1000
order by revenue;
-- 11 Output the facility id that has the highest number of slots booked
select facid,
    sum(slots) as "Total Slots"
from cd.bookings
group by facid
order by sum(slots) desc
LIMIT 1;
-- 12 List the total slots booked per facility per month, part 2
select facid,
    extract(
        month
        from starttime
    ) as month,
    sum(slots) as slots
from cd.bookings
where starttime >= '2012-01-01'
    and starttime < '2013-01-01'
group by rollup(facid, month)
order by facid,
    month;
-- 13 List the total hours booked per named facility
select facs.facid,
    facs.name,
    trim(
        to_char(sum(bks.slots) / 2.0, '9999999999999999D99')
    ) as "Total Hours"
from cd.bookings bks
    join cd.facilities facs on facs.facid = bks.facid
group by facs.facid,
    facs.name
order by facs.facid;
-- 14 List each member's first booking after September 1st 2012
select mems.surname,
    mems.firstname,
    mems.memid,
    min(bks.starttime) as starttime
from cd.bookings bks
    join cd.members mems on mems.memid = bks.memid
where starttime >= '2012-09-01'
group by mems.surname,
    mems.firstname,
    mems.memid
order by mems.memid;
-- 15 Produce a list of member names, with each row containing the total member count
select (
        select count(*)
        from cd.members
    ) as count,
    firstname,
    surname
from cd.members
order by joindate;
-- use over()
select count(*) over(),
    firstname,
    surname
from cd.members
order by joindate;
-- 16 Produce a numbered list of members
select row_number() over(
        order by joindate
    ),
    firstname,
    surname
from cd.members
order by joindate;
-- 17 Output the facility id that has the highest number of slots booked, again
select facid,
    total
from (
        select facid,
            sum(slots) total,
            rank() over (
                order by sum(slots) desc
            ) rank
        from cd.bookings
        group by facid
    ) as ranked
where rank = 1;
-- 18 Rank members by (rounded) hours used
select firstname,
    surname,
    ((sum(bks.slots) + 10) / 20) * 10 as hours,
    rank() over (
        order by ((sum(bks.slots) + 10) / 20) * 10 desc
    ) as rank
from cd.bookings bks
    join cd.members mems on bks.memid = mems.memid
group by mems.memid
order by rank,
    surname,
    firstname;
-- 19 Find the top three revenue generating facilities
select name,
    rank
from (
        select facs.name as name,
            rank() over (
                order by sum(
                        case
                            when memid = 0 then slots * facs.guestcost
                            else slots * membercost
                        end
                    ) desc
            ) as rank
        from cd.bookings bks
            join cd.facilities facs on bks.facid = facs.facid
        group by facs.name
    ) as subq
where rank <= 3
order by rank;
-- 20 Classify facilities by value
select name,
    case
        when class = 1 then 'high'
        when class = 2 then 'average'
        else 'low'
    end revenue
from (
        select facs.name as name,
            ntile(3) over (
                order by sum(
                        case
                            when memid = 0 then slots * facs.guestcost
                            else slots * membercost
                        end
                    ) desc
            ) as class
        from cd.bookings bks
            join cd.facilities facs on bks.facid = facs.facid
        group by facs.name
    ) as subq
order by class,
    name;
-- 21 Calculate the payback time for each facility
select facs.name as name,
    facs.initialoutlay /(
        (
            sum(
                case
                    when memid = 0 then slots * facs.guestcost
                    else slots * membercost
                end
            ) / 3
        ) - facs.monthlymaintenance
    ) as months
from cd.bookings bks
    join cd.facilities facs on bks.facid = facs.facid
group by facs.facid
order by name;
-- 22 Calculate a rolling average of total revenue (to do)